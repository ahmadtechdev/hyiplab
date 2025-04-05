import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/data/controller/common/theme_controller.dart';

class MyColor{

  static const Color primaryColor = Color(0xFF8A7FC8); // Modern purple that serves as main accent

  // Dark theme colors
  static const Color backgroundColor = Color(0xFF1F1A32); // Deep purple dark background
  static const Color splashBgColor = primaryColor;
  static const Color appBarColor = Color(0xFF2C2541); // Slightly lighter dark purple for appbar

  static const Color fieldEnableBorderColor = primaryColor;
  static const Color fieldDisableBorderColor = Color(0xFF3D355C); // Mid-dark purple for disabled borders
  static const Color fieldFillColor = Color(0xFF352D4D); // Mid-tone purple for fields
  static const Color headingTextColor = Color(0xFFF2F0FF); // Off-white with purple tint for headings
  static const Color colorBlackFaq = Color(0xFF9992AD); // Muted purple-gray for secondary text
  static const Color grayColor3 = Color(0xFFF6F0FF); // Very light purple-gray

  /// card color
  static const Color cardPrimaryColor = Color(0xFF26213B); // Deep purple for cards
  static const Color cardSecondaryColor = Color(0xFF3D355C); // Lighter purple for secondary cards
  static const Color cardBorderColor = Color(0xFF3D355C); // Same as secondary for consistency
  static const Color cardBgColor = Color(0xFF2C2541); // Same as appbar for consistency

  /// text color
  static const Color primaryTextColor = Color(0xFFFFFFFF); // White text
  static const Color secondaryTextColor = primaryColor; // Purple accent text
  static const Color smallTextColor = Color(0xFFE7E4F0); // Very light purple-white
  static const Color labelTextColor = Color(0xFFBBB2D9); // Light purple-gray
  static const Color hintTextColor = Color(0xFF7A6F9B); // Medium purple-gray
  static const Color colorRed = Color(0xFFE05263); // Modern red (retained)

  static const Color colorWhite = Color(0xFFFFFFFF); // White
  static const Color colorBlack = Color(0xFF262234); // Not pure black, but dark purple-black
  static const Color colorGrey = Color(0xFF9992AD); // Purple-gray
  static const Color transparentColor = Colors.transparent;

  /// bottom navbar
  static const Color bottomNavBgColor = Color(0xFF2C2541); // Dark purple for navigation
  static const Color borderColor = Color(0xFF3D355C); // Consistent with other borders

  /// shimmer color
  static const Color shimmerBaseColor = Color(0xFF2A263D); // Dark purple for shimmer
  static const Color shimmerSplashColor = Color(0xFF4C4575); // Lighter purple for shimmer
  static const Color red = Color(0xFFE05263); // Modern red (retained)
  static const Color green = Color(0xFF4CAF8D); // Modern green (retained)

  // light theme color
  static const Color lScreenBgColor1 = Color(0xFFE9E2F5); // Light lavender purple
  static const Color lScreenBgColor = Color(0xFFF5EDFF); // Very light purple
  static const Color lTextColor = Color(0xFF483D6B); // Dark purple for text in light mode
  static const Color lPrimaryColor = Color(0xFF8A7FC8); // Matching primary color for consistency
  static const Color delteBtnTextColor = Color(0xFF8E4046); // Muted red for delete text (retained)
  static const Color delteBtnColor = Color(0xFFFDDFDF); // Very light red for delete background (retained)
  static const Color textFieldDisableBorderColor = Color(0xFFD4CBEA); // Light purple border
  static const Color titleColor = Color(0xFF3C3358); // Dark purple for titles
  static const Color naturalDark = Color(0xFF6D6B8F); // Dark natural purple color
  static const Color naturalLight = Color(0xFFB2A7D6); // Light natural purple color
  static const Color ticketDetails = Color(0xFF5D5980); // Purple-gray for ticket details

  /// set color for theme
  static const Color iconColor = Color(0xFF8A7FC8); // Same as primary for consistency
  static const Color activeBadgeColor = Color(0xFF8A7FC8); // Same as primary for consistency

  // All the getter methods remain unchanged, only the color constants above are updated

  static Color getActiveBadgeBGColor() {
    return Get.find<ThemeController>().darkTheme ? activeBadgeColor : activeBadgeColor;
  }

  static Color getLabelTextColor(){
    return Get.find<ThemeController>().darkTheme ? labelTextColor : lTextColor.withValues(alpha:0.6);
  }

  static Color getInputTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorBlack;
  }

  static Color getHintTextColor(){
    return Get.find<ThemeController>().darkTheme ? hintTextColor : colorBlack;
  }

  static Color getButtonColor(){
    return  primaryColor ;
  }

  static Color getAppbarTitleColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : lPrimaryColor;
  }

  static Color getButtonTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorBlack : colorWhite;
  }

  static Color getPrimaryColor(){
    return  primaryColor ;
  }

  static Color getAppbarBgColor() {
    return Get.find<ThemeController>().darkTheme ? appBarColor : colorWhite;
  }

  static Color getScreenBgColor(){
    return Get.find<ThemeController>().darkTheme ? backgroundColor : lScreenBgColor1;
  }

  static Color getScreenBgColor1(){
    return Get.find<ThemeController>().darkTheme ? backgroundColor : colorWhite;
  }

  static Color getCardBg(){
    return Get.find<ThemeController>().darkTheme ? cardBgColor : colorWhite;
  }

  static Color getBottomNavBg(){
    return Get.find<ThemeController>().darkTheme ? bottomNavBgColor : primaryColor;
  }

  static Color getBottomNavIconColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorGrey;
  }

  static Color getBottomNavSelectedIconColor(){
    return Get.find<ThemeController>().darkTheme ? primaryColor : colorWhite;
  }

  static Color getTextFieldTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : lPrimaryColor;
  }

  static Color getTextFieldLabelColor(){
    return Get.find<ThemeController>().darkTheme ? labelTextColor : lTextColor;
  }

  static Color getTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorBlack;
  }

  static Color getTextColor1(){
    return Get.find<ThemeController>().darkTheme ? Colors.white.withValues(alpha:0.75) : lTextColor;
  }

  static Color getTextFieldBg(){
    return Get.find<ThemeController>().darkTheme ? transparentColor : transparentColor;
  }

  static Color getTextFieldHintColor(){
    return Get.find<ThemeController>().darkTheme ? hintTextColor : colorGrey;
  }

  static Color getPrimaryTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorBlack;
  }

  static Color getSecondaryTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite.withValues(alpha:0.8) : colorBlack.withValues(alpha:0.8);
  }

  static Color getDialogBg(){
    return Get.find<ThemeController>().darkTheme ? cardBgColor : colorWhite;
  }

  static Color getStatusColor(){
    return Get.find<ThemeController>().darkTheme ? primaryColor : lPrimaryColor;
  }

  static Color getFieldDisableBorderColor(){
    return Get.find<ThemeController>().darkTheme ? fieldDisableBorderColor : colorGrey.withValues(alpha:0.3);
  }

  static Color getFieldEnableBorderColor(){
    return Get.find<ThemeController>().darkTheme ? primaryColor : lPrimaryColor;
  }

  static Color getTextColor2(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorGrey;
  }

  static Color getTextColor3(){
    return Get.find<ThemeController>().darkTheme ? getLabelTextColor() : getLabelTextColor();
  }

  static Color getBottomNavColor(){
    return Get.find<ThemeController>().darkTheme ? bottomNavBgColor : colorWhite;
  }

  static Color getUnselectedIconColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorGrey.withValues(alpha:0.6);
  }

  static Color getSelectedIconColor(){
    return Get.find<ThemeController>().darkTheme ? getTextColor() : getTextColor();
  }

  static Color getPendingStatueColor(){
    return Get.find<ThemeController>().darkTheme ? Colors.grey : Colors.orange;
  }

  static Color getBorderColor(){
    return Get.find<ThemeController>().darkTheme ? Colors.grey.withValues(alpha:.3) : Colors.grey.withValues(alpha:.3);
  }

  static Color getTextFieldDisableBorder(){
    return textFieldDisableBorderColor;
  }

  static Color getHeadingTextColor() {
    return Get.find<ThemeController>().darkTheme ? headingTextColor: titleColor;
  }


  static Color getErrorColor(){
    return Get.find<ThemeController>().darkTheme ? colorRed : Color(0xFFE05263).withOpacity(0.8);
  }

  //support ticket
  static const Color purpleAcccent = Color(0xFF9D8BFF); // Updated to match our purple scheme
  static const Color bodyTextColor = Color(0xFF9E9E9E);

  static Color getTicketDetailsColor() {
    return ticketDetails;
  }
  static Color getGreyColor() {
    return MyColor.colorGrey;
  }
  static Color getGreyText(){
    return  MyColor.colorBlack.withValues(alpha:0.5);
  }

  static const Color pendingColor = Color(0xFFfcb44f);
  static const Color highPriorityPurpleColor = Color(0xFF8A7FC8); // Updated to match primary color
  static const Color bgColorLight = Color(0xFFF5F2FF); // Light purple background
  static const Color closeRedColor = Color(0xFFE05263); // Maintained for consistency
  static const Color greenSuccessColor = greenP;
  static const Color redCancelTextColor = Color(0xFFE05263); // Maintained for consistency
  static const Color greenP = Color(0xFF4CAF8D); // Maintained for consistency
}