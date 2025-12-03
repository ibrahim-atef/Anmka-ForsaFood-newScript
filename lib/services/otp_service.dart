import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Result of OTP verification
enum VerifyResult {
  success,
  expired,
  invalid,
  blocked,
  error,
}

/// Result of sending OTP
enum SendResult {
  success,
  rateLimited,
  error,
}

  /// OTP Service for WhySMS API integration
  /// TODO: Move API token to secure storage or server-side in production
class OtpService {
  static const String _apiEndpoint = 'https://bulk.whysms.com/api/v3/sms/send';
  // TODO: SECURITY - Move this token to environment variables or secure storage
  // DO NOT commit API tokens to public repositories in production
  // API Token from WhySMS (trial account)
  static const String _apiToken = '903|woRMlkcS8d669iRvxWPfxeVIW3MkJhmtjCO6IrAH02dceff0';
  static const String _senderId = 'WhySMS Test';
  static const String _firestoreCollection = 'phoneOtps';
  
  final Dio _dio = Dio();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // In-memory fallback storage (for testing only)
  // TODO: Remove this and use Firestore only in production
  static final Map<String, Map<String, dynamic>> _inMemoryStore = {};
  
  OtpService() {
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    // Don't set Authorization header here - we'll set it per request
    // to try different authentication methods
    _dio.options.baseUrl = 'https://bulk.whysms.com';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Normalize phone number to E.164 format
  /// If phone doesn't start with +, assumes +20 (Egypt) and adds it
  String normalizePhone(String phone, {String? countryCode}) {
    phone = phone.replaceAll(RegExp(r'[^\d+]'), ''); // Remove non-digit/non-plus chars
    
    if (phone.startsWith('+')) {
      return phone;
    }
    
    // If no country code provided, assume +20 for Egypt (or use countryCode parameter)
    if (countryCode != null && countryCode.isNotEmpty) {
      // Remove leading + if present
      countryCode = countryCode.replaceFirst('+', '');
      return '+$countryCode$phone';
    }
    
    // Default to Egypt +20
    return '+20$phone';
  }

  /// Format phone number for WhySMS API (digits only, no + sign)
  /// WhySMS API requires phone numbers without + or any special characters
  String _formatPhoneForApi(String phone) {
    // Remove all non-digit characters including +
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Generate a 6-digit OTP
  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP via WhySMS API
  Future<SendResult> sendOtp(String phone, {String? countryCode}) async {
    try {
      final normalizedPhone = normalizePhone(phone, countryCode: countryCode);
      debugPrint('OtpService: Normalized phone: $normalizedPhone');
      
      // Check rate limiting
      final rateLimitResult = await _checkRateLimit(normalizedPhone);
      if (rateLimitResult != null) {
        return rateLimitResult;
      }
      
      // Generate OTP
      final otp = _generateOtp();
      debugPrint('OtpService: Generated OTP: $otp');
      
      // Store OTP in Firestore (or in-memory fallback)
      try {
        await _storeOtpInFirestore(normalizedPhone, otp);
      } catch (e) {
        debugPrint('OtpService: Firestore error, using in-memory storage: $e');
        _storeOtpInMemory(normalizedPhone, otp);
      }
      
      // Send SMS via WhySMS API
      try {
        // Format phone for WhySMS API (digits only, no + sign)
        final apiPhoneNumber = _formatPhoneForApi(normalizedPhone);
        
        final requestData = {
          'recipient': apiPhoneNumber, // Use phone without + for WhySMS API
          'sender_id': _senderId,
          'type': 'plain',
          'message': 'Your verification code is: $otp',
        };
        
        debugPrint('OtpService: Sending SMS to WhySMS API...');
        debugPrint('OtpService: Endpoint: $_apiEndpoint');
        debugPrint('OtpService: Token: ${_apiToken.substring(0, 10)}...');
        debugPrint('OtpService: Normalized phone (for storage): $normalizedPhone');
        debugPrint('OtpService: API phone (digits only): $apiPhoneNumber');
        debugPrint('OtpService: Request data: $requestData');
        
        // Try with Bearer token first (standard OAuth format)
        try {
          final response = await _dio.post(
            _apiEndpoint, // Use full URL instead of relative path
            data: requestData,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $_apiToken',
              },
              validateStatus: (status) {
                return status! < 500; // Don't throw exceptions for status codes < 500
              },
            ),
          );
          
          debugPrint('OtpService: Response status: ${response.statusCode}');
          debugPrint('OtpService: Response data: ${response.data}');
          
          // Check if response indicates success or error
          final responseData = response.data;
          if (responseData is Map && responseData['status'] == 'error') {
            debugPrint('OtpService: API returned error: ${responseData['message']}');
            // If unauthenticated, try alternative auth methods
            if (responseData['message']?.toString().toLowerCase().contains('unauthenticated') == true) {
              debugPrint('OtpService: Unauthenticated with Bearer, trying alternative auth methods...');
              // Continue to alternative methods below
            } else {
              return SendResult.error;
            }
          } else if (response.statusCode == 200 || response.statusCode == 201) {
            // Check if response indicates success
            if (responseData is Map && responseData['status'] == 'success') {
              debugPrint('OtpService: SMS sent successfully to $normalizedPhone');
              return SendResult.success;
            } else if (responseData is Map && responseData['status'] == null) {
              // Some APIs don't return status field, just check if no error
              debugPrint('OtpService: SMS sent successfully to $normalizedPhone');
              return SendResult.success;
            } else if (responseData is Map && responseData['status'] == 'error') {
              // Continue to try alternative methods
            } else {
              debugPrint('OtpService: Unexpected response format: $responseData');
              return SendResult.error;
            }
          }
          
          // Try alternative authentication methods
          debugPrint('OtpService: Trying alternative authentication methods...');
          
          // Method 2: Token without Bearer prefix
          try {
            final response = await _dio.post(
              _apiEndpoint,
              data: requestData,
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': '$_apiToken',
                },
                validateStatus: (status) => status! < 500,
              ),
            );
            
            debugPrint('OtpService: Method 2 (Token only) response: ${response.data}');
            final responseData = response.data;
            if (responseData is Map && responseData['status'] == 'success') {
              debugPrint('OtpService: SMS sent successfully (Token only)');
              return SendResult.success;
            }
          } catch (e2) {
            debugPrint('OtpService: Method 2 failed');
          }
          
          // Method 3: X-API-Key header
          try {
            final response = await _dio.post(
              _apiEndpoint,
              data: requestData,
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'X-API-Key': _apiToken,
                },
                validateStatus: (status) => status! < 500,
              ),
            );
            
            debugPrint('OtpService: Method 3 (X-API-Key) response: ${response.data}');
            final responseData = response.data;
            if (responseData is Map && responseData['status'] == 'success') {
              debugPrint('OtpService: SMS sent successfully (X-API-Key)');
              return SendResult.success;
            }
          } catch (e3) {
            debugPrint('OtpService: Method 3 failed');
          }
          
          // Method 4: api-key header (lowercase)
          try {
            final response = await _dio.post(
              _apiEndpoint,
              data: requestData,
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'api-key': _apiToken,
                },
                validateStatus: (status) => status! < 500,
              ),
            );
            
            debugPrint('OtpService: Method 4 (api-key) response: ${response.data}');
            final responseData = response.data;
            if (responseData is Map && responseData['status'] == 'success') {
              debugPrint('OtpService: SMS sent successfully (api-key)');
              return SendResult.success;
            }
          } catch (e4) {
            debugPrint('OtpService: Method 4 failed');
          }
          
          // Method 5: Token in request body
          try {
            final bodyWithToken = {
              ...requestData,
              'api_token': _apiToken,
            };
            
            final response = await _dio.post(
              _apiEndpoint,
              data: bodyWithToken,
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                validateStatus: (status) => status! < 500,
              ),
            );
            
            debugPrint('OtpService: Method 5 (token in body) response: ${response.data}');
            final responseData = response.data;
            if (responseData is Map && responseData['status'] == 'success') {
              debugPrint('OtpService: SMS sent successfully (token in body)');
              return SendResult.success;
            }
          } catch (e5) {
            debugPrint('OtpService: Method 5 failed');
          }
          
          debugPrint('OtpService: All authentication methods failed');
          return SendResult.error;
        } on DioException catch (e) {
          debugPrint('OtpService: DioException details:');
          debugPrint('OtpService: Type: ${e.type}');
          debugPrint('OtpService: Message: ${e.message}');
          debugPrint('OtpService: Error: ${e.error}');
          debugPrint('OtpService: Request path: ${e.requestOptions.path}');
          debugPrint('OtpService: Request data: ${e.requestOptions.data}');
          
          if (e.response != null) {
            debugPrint('OtpService: Response status: ${e.response?.statusCode}');
            debugPrint('OtpService: Response data: ${e.response?.data}');
            debugPrint('OtpService: Response headers: ${e.response?.headers}');
          }
          
          // If unauthenticated (401 or error message contains unauthenticated), try without Bearer prefix
          final isUnauthenticated = e.response?.statusCode == 401 || 
              (e.response?.data is Map && 
               e.response?.data['message']?.toString().toLowerCase().contains('unauthenticated') == true);
          
          if (isUnauthenticated) {
            debugPrint('OtpService: Authentication failed, trying without Bearer prefix...');
            
            try {
              final response = await _dio.post(
                _apiEndpoint, // Use full URL
                data: requestData,
                options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': '$_apiToken', // Token without Bearer prefix
                  },
                  validateStatus: (status) {
                    return status! < 500;
                  },
                ),
              );
              
              debugPrint('OtpService: Retry response status: ${response.statusCode}');
              debugPrint('OtpService: Retry response data: ${response.data}');
              
              final retryData = response.data;
              if (retryData is Map && retryData['status'] == 'error') {
                debugPrint('OtpService: Retry also failed: ${retryData['message']}');
                return SendResult.error;
              }
              
              if (response.statusCode == 200 || response.statusCode == 201) {
                if (retryData is Map && retryData['status'] == 'success') {
                  debugPrint('OtpService: SMS sent successfully (without Bearer) to $normalizedPhone');
                  return SendResult.success;
                } else if (retryData is Map && retryData['status'] == null) {
                  debugPrint('OtpService: SMS sent successfully (without Bearer) to $normalizedPhone');
                  return SendResult.success;
                }
              }
              
              debugPrint('OtpService: Retry failed with status ${response.statusCode}');
              debugPrint('OtpService: Response: ${response.data}');
            } catch (e2) {
              debugPrint('OtpService: Both auth methods failed');
              debugPrint('OtpService: Retry error: $e2');
              if (e2 is DioException) {
                debugPrint('OtpService: Retry DioException type: ${e2.type}');
                debugPrint('OtpService: Retry error message: ${e2.message}');
                debugPrint('OtpService: Retry error: ${e2.error}');
              }
            }
          }
          
          debugPrint('OtpService: SMS API DioException: ${e.type}');
          debugPrint('OtpService: Error message: ${e.message}');
          debugPrint('OtpService: Response: ${e.response?.data}');
          debugPrint('OtpService: Status code: ${e.response?.statusCode}');
          
          if (e.response != null) {
            debugPrint('OtpService: Response headers: ${e.response?.headers}');
            debugPrint('OtpService: Full error response: ${e.response}');
          }
          
          return SendResult.error;
        }
        
        return SendResult.error;
      } catch (e, stackTrace) {
        debugPrint('OtpService: Unexpected exception: $e');
        debugPrint('OtpService: Stack trace: $stackTrace');
        return SendResult.error;
      }
    } catch (e) {
      debugPrint('OtpService: sendOtp error: $e');
      return SendResult.error;
    }
  }

  /// Store OTP in Firestore
  Future<void> _storeOtpInFirestore(String phone, String otp) async {
    try {
      await _firestore.collection(_firestoreCollection).doc(phone).set({
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'attempts': 0,
        'resendCount': 0,
      }, SetOptions(merge: false));
    } catch (e) {
      debugPrint('OtpService: Firestore write error: $e');
      rethrow;
    }
  }

  /// Store OTP in memory (fallback for testing)
  void _storeOtpInMemory(String phone, String otp) {
    _inMemoryStore[phone] = {
      'otp': otp,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'attempts': 0,
      'resendCount': 0,
    };
  }

  /// Check rate limiting before sending OTP
  Future<SendResult?> _checkRateLimit(String phone) async {
    try {
      final doc = await _firestore.collection(_firestoreCollection).doc(phone).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final createdAt = data['createdAt'] as Timestamp?;
        final resendCount = data['resendCount'] ?? 0;
        
        if (createdAt != null) {
          final now = DateTime.now();
          final created = createdAt.toDate();
          final diff = now.difference(created);
          
          // Check if less than 60 seconds passed and resend count >= 3
          if (diff.inSeconds < 60 && resendCount >= 3) {
            return SendResult.rateLimited;
          }
          
          // Check if blocked
          if (data['blockedUntil'] != null) {
            final blockedUntil = (data['blockedUntil'] as Timestamp).toDate();
            if (now.isBefore(blockedUntil)) {
              return SendResult.rateLimited;
            }
          }
        }
      }
      
      return null; // No rate limit
    } catch (e) {
      // If Firestore fails, check in-memory
      if (_inMemoryStore.containsKey(phone)) {
        final data = _inMemoryStore[phone]!;
        final createdAt = DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int);
        final resendCount = data['resendCount'] ?? 0;
        final diff = DateTime.now().difference(createdAt);
        
        if (diff.inSeconds < 60 && resendCount >= 3) {
          return SendResult.rateLimited;
        }
      }
      
      return null; // Allow sending if check fails
    }
  }

  /// Verify OTP
  Future<VerifyResult> verifyOtp(String phone, String otp, {String? countryCode}) async {
    try {
      final normalizedPhone = normalizePhone(phone, countryCode: countryCode);
      
      // Get OTP data from Firestore (or in-memory)
      Map<String, dynamic>? otpData;
      
      try {
        final doc = await _firestore.collection(_firestoreCollection).doc(normalizedPhone).get();
        if (doc.exists) {
          otpData = doc.data();
        }
      } catch (e) {
        debugPrint('OtpService: Firestore read error, checking in-memory: $e');
        if (_inMemoryStore.containsKey(normalizedPhone)) {
          otpData = _inMemoryStore[normalizedPhone];
        }
      }
      
      if (otpData == null) {
        debugPrint('OtpService: No OTP found for $normalizedPhone');
        return VerifyResult.expired;
      }
      
      // Check if blocked
      if (otpData['blockedUntil'] != null) {
        final blockedUntil = Timestamp.fromDate(
          DateTime.fromMillisecondsSinceEpoch(otpData['blockedUntil'] as int)
        );
        if (DateTime.now().isBefore(blockedUntil.toDate())) {
          return VerifyResult.blocked;
        }
      }
      
      // Check expiration (5 minutes)
      DateTime createdAt;
      if (otpData['createdAt'] is Timestamp) {
        createdAt = (otpData['createdAt'] as Timestamp).toDate();
      } else {
        createdAt = DateTime.fromMillisecondsSinceEpoch(otpData['createdAt'] as int);
      }
      
      final now = DateTime.now();
      final diff = now.difference(createdAt);
      
      if (diff.inMinutes > 5) {
        debugPrint('OtpService: OTP expired for $normalizedPhone');
        return VerifyResult.expired;
      }
      
      // Check attempts
      int attempts = otpData['attempts'] ?? 0;
      if (attempts >= 5) {
        // Block for 1 hour
        final blockedUntil = DateTime.now().add(const Duration(hours: 1));
        try {
          await _firestore.collection(_firestoreCollection).doc(normalizedPhone).update({
            'blockedUntil': Timestamp.fromDate(blockedUntil),
          });
        } catch (e) {
          if (_inMemoryStore.containsKey(normalizedPhone)) {
            _inMemoryStore[normalizedPhone]!['blockedUntil'] = blockedUntil.millisecondsSinceEpoch;
          }
        }
        return VerifyResult.blocked;
      }
      
      // Verify OTP
      final storedOtp = otpData['otp'] as String;
      if (storedOtp == otp) {
        // Success - delete OTP document
        try {
          await _firestore.collection(_firestoreCollection).doc(normalizedPhone).delete();
        } catch (e) {
          _inMemoryStore.remove(normalizedPhone);
        }
        debugPrint('OtpService: OTP verified successfully for $normalizedPhone');
        return VerifyResult.success;
      } else {
        // Increment attempts
        attempts++;
        try {
          await _firestore.collection(_firestoreCollection).doc(normalizedPhone).update({
            'attempts': attempts,
          });
        } catch (e) {
          if (_inMemoryStore.containsKey(normalizedPhone)) {
            _inMemoryStore[normalizedPhone]!['attempts'] = attempts;
          }
        }
        debugPrint('OtpService: Invalid OTP for $normalizedPhone (attempts: $attempts)');
        return VerifyResult.invalid;
      }
    } catch (e) {
      debugPrint('OtpService: verifyOtp error: $e');
      return VerifyResult.error;
    }
  }

  /// Resend OTP
  Future<SendResult> resendOtp(String phone, {String? countryCode}) async {
    try {
      final normalizedPhone = normalizePhone(phone, countryCode: countryCode);
      
      // Check if resend is allowed
      try {
        final doc = await _firestore.collection(_firestoreCollection).doc(normalizedPhone).get();
        
        if (doc.exists) {
          final data = doc.data()!;
          final createdAt = data['createdAt'] as Timestamp?;
          final resendCount = data['resendCount'] ?? 0;
          
          if (createdAt != null) {
            final now = DateTime.now();
            final created = createdAt.toDate();
            final diff = now.difference(created);
            
            // Check if less than 60 seconds passed
            if (diff.inSeconds < 60 && resendCount >= 3) {
              return SendResult.rateLimited;
            }
            
            // Increment resend count
            await _firestore.collection(_firestoreCollection).doc(normalizedPhone).update({
              'resendCount': resendCount + 1,
            });
          }
        }
      } catch (e) {
        // Check in-memory
        if (_inMemoryStore.containsKey(normalizedPhone)) {
          final data = _inMemoryStore[normalizedPhone]!;
          final createdAt = DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int);
          final resendCount = data['resendCount'] ?? 0;
          final diff = DateTime.now().difference(createdAt);
          
          if (diff.inSeconds < 60 && resendCount >= 3) {
            return SendResult.rateLimited;
          }
          
          _inMemoryStore[normalizedPhone]!['resendCount'] = resendCount + 1;
        }
      }
      
      // Resend OTP
      return await sendOtp(phone, countryCode: countryCode);
    } catch (e) {
      debugPrint('OtpService: resendOtp error: $e');
      return SendResult.error;
    }
  }

  /// Get remaining validity time for OTP
  Future<Duration?> getRemainingValidity(String phone, {String? countryCode}) async {
    try {
      final normalizedPhone = normalizePhone(phone, countryCode: countryCode);
      
      try {
        final doc = await _firestore.collection(_firestoreCollection).doc(normalizedPhone).get();
        if (doc.exists) {
          final data = doc.data()!;
          final createdAt = data['createdAt'] as Timestamp?;
          if (createdAt != null) {
            final created = createdAt.toDate();
            final expiry = created.add(const Duration(minutes: 5));
            final now = DateTime.now();
            if (now.isAfter(expiry)) {
              return null;
            }
            return expiry.difference(now);
          }
        }
      } catch (e) {
        if (_inMemoryStore.containsKey(normalizedPhone)) {
          final data = _inMemoryStore[normalizedPhone]!;
          final createdAt = DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int);
          final expiry = createdAt.add(const Duration(minutes: 5));
          final now = DateTime.now();
          if (now.isAfter(expiry)) {
            return null;
          }
          return expiry.difference(now);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('OtpService: getRemainingValidity error: $e');
      return null;
    }
  }

  /// Get remaining attempts
  Future<int> getRemainingAttempts(String phone, {String? countryCode}) async {
    try {
      final normalizedPhone = normalizePhone(phone, countryCode: countryCode);
      
      try {
        final doc = await _firestore.collection(_firestoreCollection).doc(normalizedPhone).get();
        if (doc.exists) {
          final attempts = doc.data()!['attempts'] ?? 0;
          return 5 - (attempts as int);
        }
      } catch (e) {
        if (_inMemoryStore.containsKey(normalizedPhone)) {
          final attempts = _inMemoryStore[normalizedPhone]!['attempts'] ?? 0;
          return 5 - (attempts as int);
        }
      }
      
      return 5;
    } catch (e) {
      return 5;
    }
  }
}
