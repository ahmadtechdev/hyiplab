import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_images.dart';
import 'package:hyip_lab/core/utils/util.dart';
import 'package:hyip_lab/data/controller/common/theme_controller.dart';
import 'package:hyip_lab/data/controller/localization/localization_controller.dart';
import 'package:hyip_lab/data/controller/splash/splash_controller.dart';
import 'package:hyip_lab/data/repo/auth/general_setting_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    final controller = Get.put(SplashController(repo: Get.find(),localizationController: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      MyUtils.splashScreenUtils();
      controller.gotoNextPage();
    });
  }

  @override
  void dispose() {
    ThemeController themeController = ThemeController(sharedPreferences: Get.find());
    MyUtils.allScreensUtils(themeController.darkTheme);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.6; // 60% of screen width

    return SafeArea(
        child: GetBuilder<SplashController>(
          builder: (controller) => Scaffold(
            // Using light background color for better contrast with purple logo
            backgroundColor: controller.noInternet
                ? MyColor.colorWhite
                : MyColor.lScreenBgColor, // Using light purple background from your color scheme
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with increased size but not exceeding width
                  Image.asset(
                    MyImages.appLogo,
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  // Optional: Add app name or loading indicator
                  Text(
                    "ClicksMax",
                    style: TextStyle(
                      color: MyColor.lTextColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}