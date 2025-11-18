// ignore: must_be_immutable
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/story_view/controller/story_controller.dart';
import 'package:customer/widget/story_view/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../widget/story_view/widgets/story_view.dart';

// ignore: must_be_immutable
class MoreStories extends StatefulWidget {
  final List<StoryModel> storyList;
  int index;

  MoreStories({super.key, required this.index, required this.storyList});

  @override
  MoreStoriesState createState() => MoreStoriesState();
}

class MoreStoriesState extends State<MoreStories> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  /// Get the actual duration of a video URL
  Future<Duration> _getVideoDuration(String videoUrl) async {
    try {
      final VideoPlayerController controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();
      return duration;
    } catch (e) {
      debugPrint('Error getting video duration: $e');
      // Return a default duration if we can't get the actual duration
      return const Duration(seconds: 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    // التحقق من أن الـ Story معتمد (approved) فقط
    if (widget.storyList[widget.index].status != 'approved') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "This story is not available",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Story is pending approval",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }
    
    // التحقق من أن الـ Story لم يمض عليه أكثر من 24 ساعة
    if (widget.storyList[widget.index].createdAt != null) {
      DateTime now = DateTime.now();
      DateTime twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
      DateTime storyDate = widget.storyList[widget.index].createdAt!.toDate();
      
      if (storyDate.isBefore(twentyFourHoursAgo)) {
        // إرجاع شاشة فارغة إذا كان الـ Story منتهي الصلاحية
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "This story has expired",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Stories expire after 24 hours",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<Duration>>(
            future: Future.wait(
              widget.storyList[widget.index].videoUrl.map((url) => _getVideoDuration(url))
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final durations = snapshot.data ?? [];
              
              return StoryView(
                storyItems: List.generate(
                  widget.storyList[widget.index].videoUrl.length,
                  (i) {
                    final duration = i < durations.length ? durations[i] : const Duration(seconds: 10);
                    return StoryItem.pageVideo(
                      widget.storyList[widget.index].videoUrl[i],
                      controller: storyController,
                      duration: duration, // استخدام المدة الفعلية للفيديو
                    );
                  },
                ).toList(),
              onComplete: () {
                debugPrint("--------->");
                debugPrint(widget.storyList.length.toString());
                debugPrint(widget.index.toString());
                if (widget.storyList.length - 1 != widget.index) {
                  setState(() {
                    widget.index = widget.index + 1;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              progressPosition: ProgressPosition.top,
              repeat: true,
              controller: storyController,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              });
            },
          ),
          Padding(
            padding:  EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top + 30,left: 16,right: 16),
            child: FutureBuilder(
                future: FireStoreUtils.getVendorById(widget.storyList[widget.index].vendorID.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Constant.loader();
                  } else {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data == null) {
                      return const SizedBox();
                    } else {
                      VendorModel vendorModel = snapshot.data!;
                      return InkWell(
                        onTap: () {
                          Get.to(const RestaurantDetailsScreen(), arguments: {"vendorModel": vendorModel});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: NetworkImageWidget(
                                imageUrl: vendorModel.photo.toString(),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vendorModel.title.toString(),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset("assets/icons/ic_star.svg"),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} reviews",
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: AppThemeData.warning300,
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                }),
          ),
        ],
      ),
    );
  }
}
