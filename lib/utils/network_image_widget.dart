import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/responsive.dart';
import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? borderRadius;
  final Color? color;

  const NetworkImageWidget({
    super.key,
    this.height,
    this.width,
    this.fit,
    required this.imageUrl,
    this.borderRadius,
    this.errorWidget,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    print("🔍 NetworkImageWidget: Building with imageUrl: '$imageUrl'");
    
    // التحقق من أن imageUrl ليس null أو فارغ
    if (imageUrl.isEmpty || imageUrl == 'null' || imageUrl == '') {
      print("❌ NetworkImageWidget: Empty or null imageUrl, showing placeholder");
      print("🔍 NetworkImageWidget: Constant.placeholderImage = ${Constant.placeholderImage}");
      return Container(
        height: height ?? Responsive.height(8, context),
        width: width ?? Responsive.width(15, context),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
        ),
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[600],
          size: 40,
        ),
      );
    }

    print("🔍 NetworkImageWidget: Loading image from URL: $imageUrl");
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.fitWidth,
      height: height ?? Responsive.height(8, context),
      width: width ?? Responsive.width(15, context),
      color: color,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        print("🔍 NetworkImageWidget: Loading progress for $url");
        return Constant.loader();
      },
      errorWidget: (context, url, error) {
        print("❌ NetworkImageWidget: Error loading image $url: $error");
        return errorWidget ??
          Container(
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[200]!,
                  Colors.grey[300]!,
                ],
              ),
              borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "No Image",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
      },
    );
  }
}
