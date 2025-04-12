import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_images.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/dashboard/dashboard_controller.dart';
import 'package:hyip_lab/view/components/text/small_text.dart';

class HomeTopSection extends StatefulWidget {
  const HomeTopSection({Key? key}) : super(key: key);

  @override
  State<HomeTopSection> createState() => _HomeTopSectionState();
}

class _HomeTopSectionState extends State<HomeTopSection> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
      builder: (controller) => Padding(
        padding: Dimensions.screenPaddingHV,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.userAccountScreen);
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage(MyImages.userImage),
                    radius: 20,
                  ),
                  const SizedBox(width: Dimensions.space15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.username, style: interRegularLarge.copyWith(color: MyColor.getTextColor())),
                      const SizedBox(height: Dimensions.space5),
                      SmallText(text: controller.email, textStyle: interRegularSmall.copyWith(color: MyColor.getTextColor1()))
                    ],
                  )
                ],
              ),
            ),
            // Animated Notification Button
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        InkWell(
                          onTap: () {
                            // Navigate to notification screen
                            Get.toNamed(RouteHelper.airdrop);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? MyColor.cardPrimaryColor
                                  : MyColor.colorWhite,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: MyColor.getPrimaryColor().withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                              border: Border.all(
                                color: MyColor.getPrimaryColor().withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.air_rounded,
                              color: MyColor.getPrimaryColor(),
                              size: 24,
                            ),
                          ),
                        ),
                        // Notification indicator
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: MyColor.colorRed,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? MyColor.backgroundColor
                                    : MyColor.colorWhite,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}