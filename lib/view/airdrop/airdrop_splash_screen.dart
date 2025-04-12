import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/data/controller/common/theme_controller.dart';
import 'airdrop_screen.dart';

class AirdropSplashScreen extends StatefulWidget {
  const AirdropSplashScreen({Key? key}) : super(key: key);

  @override
  State<AirdropSplashScreen> createState() => _AirdropSplashScreenState();
}

class _AirdropSplashScreenState extends State<AirdropSplashScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();

    // Scale animation controller
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Rotation animation controller
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _scaleController.forward();

    // Navigate to AirdropScreen after delay
    Timer(const Duration(milliseconds: 2500), () {
      setState(() {
        _animationComplete = true;
      });

      // Give a moment for the exit animation to start
      Timer(const Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, animation, __) {
              return FadeTransition(
                opacity: animation,
                child: const AirdropScreen(),
              );
            },
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme
    final bool isDarkTheme = Get.find<ThemeController>().darkTheme;

    // Theme-aware colors
    final Color backgroundColor = isDarkTheme
        ? MyColor.backgroundColor
        : MyColor.lScreenBgColor;

    final Color primaryColor = isDarkTheme
        ? MyColor.primaryColor
        : MyColor.lPrimaryColor;

    final Color textColor = isDarkTheme
        ? MyColor.colorWhite
        : MyColor.lTextColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              isDarkTheme ? MyColor.cardBgColor : MyColor.lScreenBgColor1,
            ],
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            opacity: _animationComplete ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Stack(  // Replace Column with Stack
              alignment: Alignment.center,
              children: [
                // Animated rotating background
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * 3.14159,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              primaryColor.withOpacity(0.6),
                              (isDarkTheme
                                  ? MyColor.purpleAcccent
                                  : MyColor.naturalLight).withOpacity(0.4),
                              primaryColor.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Logo and text with scale animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo image
                      Image.asset(
                        'assets/images/logo/logo.png',
                        width: 120,
                        height: 120,
                      ),

                      const SizedBox(height: Dimensions.space20),

                      // Text
                      Text(
                        'CMC Airdrop',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: Dimensions.space10),

                      Text(
                        'Tap to collect CMC Coin',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}