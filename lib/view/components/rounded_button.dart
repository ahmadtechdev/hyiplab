import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_color.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final Color color;
  final Color? textColor;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final double cornerRadius;
  final bool isOutlined;
  final Color borderColor;
  final bool isLoading;
  final Widget? child;
  final double opacity;

  const RoundedButton({
    Key? key,
    this.width=1,
    this.cornerRadius=6,
    required this.text,
    required this.press,
    this.isOutlined=false,
    this.horizontalPadding=35,
    this.verticalPadding=18,
    this.color = MyColor.primaryColor,
    this.textColor = MyColor.colorBlack,
    this.borderColor = MyColor.borderColor,
    this.isLoading = false,
    this.child,
    this.opacity = 1.0,
  }):super(key: key) ;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // final effectiveColor = color.withOpacity(opacity);

    return isOutlined? GestureDetector(
      onTap: press,
      child: Container(
          padding:  EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          width: size.width * width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              border: Border.all(color: borderColor),
              color: color
          ),
          child: Center(child: Text(text,style:TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)))),
    ): SizedBox(
      width: size.width * width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: ElevatedButton(
          onPressed: press,
          style: ElevatedButton.styleFrom(backgroundColor: color, shadowColor: MyColor.primaryColor, padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding), textStyle: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
          child: isLoading
              ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: textColor ?? MyColor.colorWhite))
              : Text(text.tr,style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  Widget newElevatedButton() {
    return ElevatedButton(
      onPressed: press,
      style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(opacity),
          shadowColor: MyColor.transparentColor,
          padding:  EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          textStyle: TextStyle(
              color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
      child: Text(
        text.tr,
        style: TextStyle(color: textColor),
      ),
    );
  }
}