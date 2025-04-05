import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'dart:math' as math;
import '../../../data/controller/common/theme_controller.dart';

enum IconAnimationType {
  rotate,
  bounce,
  none
}

class CardWithRoundIcon extends StatefulWidget {
  final VoidCallback? onPressed;
  final String icon;
  final String titleText;
  final String trailText;
  final Color? backgroundColor;
  final Color titleColor;
  final Color trailColor;
  final IconAnimationType iconAnimationType;

  const CardWithRoundIcon({
    super.key,
    this.onPressed,
    required this.titleText,
    required this.trailText,
    required this.icon,
    this.backgroundColor,
    this.titleColor = MyColor.colorWhite,
    this.trailColor = MyColor.primaryColor,
    this.iconAnimationType = IconAnimationType.rotate,
  });

  @override
  State<CardWithRoundIcon> createState() => _CardWithRoundIconState();
}

class _CardWithRoundIconState extends State<CardWithRoundIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _bounceAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Initialize the controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: widget.iconAnimationType == IconAnimationType.bounce);

    // Initialize animations
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 3 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 6.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(CardWithRoundIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconAnimationType != widget.iconAnimationType) {
      _animationController
        ..stop()
        ..repeat(reverse: widget.iconAnimationType == IconAnimationType.bounce);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedIcon() {
    Widget iconWidget = Container(
      height: 45,
      width: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MyColor.primaryColor.withOpacity(0.15),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: MyColor.primaryColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: widget.icon.contains("svg")
          ? SvgPicture.asset(
        widget.icon,
        height: 22,
        width: 22,
        color: MyColor.primaryColor,
      )
          : Image.asset(
        widget.icon,
        color: MyColor.primaryColor,
        height: 22,
        width: 22,
      ),
    );

    switch (widget.iconAnimationType) {
      case IconAnimationType.rotate:
        return AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            );
          },
          child: iconWidget,
        );
      case IconAnimationType.bounce:
        return AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_bounceAnimation.value),
              child: child,
            );
          },
          child: iconWidget,
        );
      case IconAnimationType.none:
      default:
        return iconWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Get.find<ThemeController>().darkTheme;
    final cardColor = isDarkTheme
        ? (widget.backgroundColor ?? MyColor.cardBgColor)
        : Colors.white;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        // Ensure opacity stays within valid range
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: clampedValue,
            child: Transform.scale(
              scale: _isPressed ? 0.98 : 1.0,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkTheme
                  ? MyColor.getBorderColor()
                  : MyColor.getBorderColor(),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: MyColor.primaryColor.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: MyColor.primaryColor.withOpacity(0.15),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Icon Container
              _buildAnimatedIcon(),
              const SizedBox(height: Dimensions.space15),
              // Title Text with Extra Bold Style
              Text(
                widget.titleText,
                style: interSemiBoldSmall.copyWith(
                  color: MyColor.getTextColor(),
                  fontWeight: FontWeight.w900, // Extra bold text
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: Dimensions.space5),
              // Trail Text
              Text(
                widget.trailText,
                style: interRegularLarge.copyWith(
                  fontSize: Dimensions.fontDefault,
                  color: MyColor.getTextColor1(),
                  height: 1.4,
                  fontWeight: FontWeight.w600, // Semi-bold for trail text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}