import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/style.dart';

import '../../../data/controller/common/theme_controller.dart';
import '../text/label_text_with_instructions.dart';

class CustomTextField extends StatefulWidget {
  final String? instructions;
  final bool isShowInstructionWidget;
  final bool isRequired;
  final String? labelText;
  final String? hintText;
  final Function? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final FormFieldValidator? validator;
  final TextInputType? textInputType;
  final bool isEnable;
  final bool isPassword;
  final bool isShowSuffixIcon;
  final bool isIcon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onPrefixTap;
  final bool isSearch;
  final bool isCountryPicker;
  final TextInputAction inputAction;
  final bool needOutlineBorder;
  final bool needLabel;
  final bool readOnly;
  final bool needRequiredSign;
  final Color? disableColor;
  final int? maxLines;
  final VoidCallback? onTap;
  final bool isSquare;
  final bool hasShadow;
  final double borderRadius;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final Duration animationDuration;
  final bool showFloatingLabel;

  const CustomTextField({
    super.key,
    this.labelText,
    this.readOnly = false,
    required this.onChanged,
    this.hintText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.validator,
    this.textInputType,
    this.isEnable = true,
    this.isPassword = false,
    this.isShowSuffixIcon = false,
    this.isIcon = false,
    this.onSuffixTap,
    this.onPrefixTap,
    this.isSearch = false,
    this.isCountryPicker = false,
    this.inputAction = TextInputAction.next,
    this.needOutlineBorder = false,
    this.needLabel = true,
    this.needRequiredSign = false,
    this.disableColor,
    this.instructions,
    this.isShowInstructionWidget = false,
    this.isRequired = false,
    this.maxLines,
    this.onTap,
    this.isSquare = false,
    this.hasShadow = true,
    this.borderRadius = 15.0,
    this.fillColor,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showFloatingLabel = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
  bool obscureText = true;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.isSquare ? Dimensions.textToTextSpace : widget.borderRadius;
    final customFillColor = widget.fillColor ??
        (Get.find<ThemeController>().darkTheme ? MyColor.fieldFillColor : MyColor.lScreenBgColor);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.hasShadow ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isShowInstructionWidget)
            LabelTextInstruction(
              text: widget.labelText.toString(),
              isRequired: widget.isRequired,
              instructions: widget.instructions,
            ),
          if (widget.isShowInstructionWidget)
            const SizedBox(height: Dimensions.textToTextSpace),
          Container(
            decoration: widget.hasShadow ? BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? MyColor.getPrimaryColor().withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ) : null,
            child: TextFormField(
              readOnly: widget.readOnly,
              maxLines: widget.maxLines ?? 1,
              style: interRegularDefault.copyWith(color: MyColor.getTextColor()),
              textAlign: TextAlign.left,
              cursorColor: MyColor.getPrimaryColor(),
              controller: widget.controller,
              autofocus: false,
              textInputAction: widget.inputAction,
              enabled: widget.isEnable,
              focusNode: _focusNode,
              validator: widget.validator,
              keyboardType: widget.textInputType,
              obscureText: widget.isPassword ? obscureText : false,
              decoration: InputDecoration(
                errorMaxLines: 2,
                contentPadding: widget.contentPadding ??
                    EdgeInsets.symmetric(horizontal: 15, vertical: widget.needOutlineBorder ? 12 : 5),
                hintText: widget.hintText != null ? widget.hintText!.tr : '',
                hintStyle: interRegularSmall.copyWith(color: MyColor.getHintTextColor()),
                labelText: widget.showFloatingLabel ? widget.labelText?.tr : null,
                labelStyle: interRegularDefault.copyWith(
                  color: _isFocused
                      ? MyColor.getPrimaryColor()
                      : MyColor.getLabelTextColor(),
                ),
                fillColor: customFillColor,
                filled: true,
                prefixIcon: widget.prefixIcon,
                enabledBorder: widget.needOutlineBorder
                    ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: MyColor.getFieldDisableBorderColor(),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(radius),
                )
                    : UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.disableColor ?? MyColor.getFieldDisableBorderColor(),
                  ),
                ),
                focusedBorder: widget.needOutlineBorder
                    ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: MyColor.getPrimaryColor(),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(radius),
                )
                    : UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: MyColor.getFieldEnableBorderColor(),
                    width: 1.5,
                  ),
                ),
                errorBorder: widget.needOutlineBorder
                    ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: MyColor.getErrorColor(),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(radius),
                )
                    : UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: MyColor.getErrorColor(),
                  ),
                ),
                focusedErrorBorder: widget.needOutlineBorder
                    ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: MyColor.getErrorColor(),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(radius),
                )
                    : UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: MyColor.getErrorColor(),
                    width: 1.5,
                  ),
                ),
                suffixIcon: _buildSuffixIcon(),
              ),
              onFieldSubmitted: (text) => widget.nextFocus != null
                  ? FocusScope.of(context).requestFocus(widget.nextFocus)
                  : null,
              onChanged: (text) => widget.onChanged!(text),
              onTap: widget.onTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    } else if (widget.isShowSuffixIcon) {
      if (widget.isPassword) {
        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              key: ValueKey<bool>(obscureText),
              color: _isFocused ? MyColor.getPrimaryColor() : MyColor.hintTextColor,
              size: 20,
            ),
          ),
          onPressed: _toggle,
        );
      } else if (widget.isIcon) {
        return IconButton(
          onPressed: widget.onSuffixTap,
          icon: Icon(
            widget.isSearch
                ? Icons.search_outlined
                : widget.isCountryPicker
                ? Icons.arrow_drop_down_outlined
                : Icons.camera_alt_outlined,
            size: 25,
            color: _isFocused ? MyColor.getPrimaryColor() : MyColor.hintTextColor,
          ),
        );
      }
    }
    return null;
  }

  void _toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }
}