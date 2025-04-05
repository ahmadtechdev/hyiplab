import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/auth/auth/registration_controller.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:country_picker/country_picker.dart';

class ModernRegistrationForm extends StatefulWidget {
  const ModernRegistrationForm({Key? key}) : super(key: key);

  @override
  State<ModernRegistrationForm> createState() => _ModernRegistrationFormState();
}

class _ModernRegistrationFormState extends State<ModernRegistrationForm> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedTextField(
                  controller: controller.fNameController,
                  focusNode: controller.firstNameFocusNode,
                  nextFocus: controller.lastNameFocusNode,
                  hintText: MyStrings.firstName.tr,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return MyStrings.enterYourFirstName.tr;
                    }
                    return null;
                  },
                  delay: 0,
                ),

                _buildAnimatedTextField(
                  controller: controller.lNameController,
                  focusNode: controller.lastNameFocusNode,
                  nextFocus: controller.emailFocusNode,
                  hintText: MyStrings.lastName.tr,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return MyStrings.enterYourLastName.tr;
                    }
                    return null;
                  },
                  delay: 100,
                ),

                // Country Selection Field
                _buildAnimatedCountryField(
                  controller: controller,
                  delay: 150,
                ),

                _buildAnimatedTextField(
                  controller: controller.emailController,
                  focusNode: controller.emailFocusNode,
                  nextFocus: controller.passwordFocusNode,
                  hintText: MyStrings.email.tr,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return MyStrings.enterYourEmail.tr;
                    } else if (!MyStrings.emailValidatorRegExp.hasMatch(value ?? '')) {
                      return MyStrings.invalidEmailMsg.tr;
                    }
                    return null;
                  },
                  delay: 200,
                ),

                _buildAnimatedTextField(
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocusNode,
                  nextFocus: controller.confirmPasswordFocusNode,
                  hintText: MyStrings.password.tr,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    return controller.validatePassword(value ?? '');
                  },
                  onChanged: (value) {
                    if (controller.checkPasswordStrength) {
                      controller.updateValidationList(value);
                    }
                  },
                  delay: 300,
                ),

                _buildAnimatedTextField(
                  controller: controller.cPasswordController,
                  focusNode: controller.confirmPasswordFocusNode,
                  nextFocus: controller.referralCodeFocusNode,
                  hintText: MyStrings.confirmPassword.tr,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) {
                    if (controller.passwordController.text.toLowerCase() !=
                        controller.cPasswordController.text.toLowerCase()) {
                      return MyStrings.kMatchPassError.tr;
                    }
                    return null;
                  },
                  delay: 400,
                ),

                _buildAnimatedTextField(
                  controller: controller.referralCodeController,
                  focusNode: controller.referralCodeFocusNode,
                  isLastField: true,
                  hintText: "${MyStrings.referralCode.tr} (${MyStrings.optional.tr})",
                  prefixIcon: Icons.group_add_outlined,
                  delay: 500,
                ),

                const SizedBox(height: 15),

                // Agree to Terms & Conditions
                Visibility(
                  visible: controller.needAgree,
                  child: _buildTcAgreement(controller),
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                _buildSignUpButton(controller),

                const SizedBox(height: 30),

                // Sign In Option
                _buildSignInOption(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCountryField({
    required RegistrationController controller,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: clampedValue, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MyColor.getPrimaryColor().withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                controller.countryController.text = "${country.name}:+${country.phoneCode}";
                controller.countryName = country.name;
                controller.countryCode = country.countryCode;
                controller.mobileCode = "+${country.phoneCode}";
                controller.update();
              },
              countryListTheme: CountryListThemeData(
                borderRadius: BorderRadius.circular(16),
                inputDecoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Start typing to search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: MyColor.getPrimaryColor().withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            );
          },
          child: TextFormField(
            controller: controller.countryController,
            focusNode: controller.countryNameFocusNode,
            enabled: false,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please select your country";
              }
              return null;
            },
            style: interRegularDefault.copyWith(
              color: MyColor.getInputTextColor(),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: "Select Your Country",
              hintStyle: interRegularDefault.copyWith(
                color: MyColor.getHintTextColor().withOpacity(0.6),
                fontSize: 15,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: MyColor.getPrimaryColor().withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.flag_outlined,
                    color: MyColor.getPrimaryColor(),
                    size: 22,
                  ),
                ),
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: MyColor.getHintTextColor().withOpacity(0.5),
                size: 24,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              filled: true,
              fillColor: MyColor.getCardBg(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MyColor.getCardBg(),
                  width: 1.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MyColor.getCardBg(),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MyColor.getPrimaryColor().withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MyColor.getErrorColor().withOpacity(0.8),
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MyColor.getErrorColor(),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isLastField = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: clampedValue, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MyColor.getPrimaryColor().withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword,
          keyboardType: keyboardType,
          textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          },
          onChanged: onChanged,
          validator: validator,
          style: interRegularDefault.copyWith(
            color: MyColor.getInputTextColor(),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: interRegularDefault.copyWith(
              color: MyColor.getHintTextColor().withOpacity(0.6),
              fontSize: 15,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: MyColor.getPrimaryColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  prefixIcon,
                  color: MyColor.getPrimaryColor(),
                  size: 22,
                ),
              ),
            ),
            suffixIcon: isPassword
                ? GestureDetector(
              onTap: () {
                // Toggle password visibility if needed
              },
              child: Icon(
                Icons.visibility_outlined,
                color: MyColor.getHintTextColor().withOpacity(0.5),
                size: 22,
              ),
            )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            filled: true,
            fillColor: MyColor.getCardBg(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: MyColor.getCardBg(),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: MyColor.getPrimaryColor().withOpacity(0.5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: MyColor.getErrorColor().withOpacity(0.8),
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: MyColor.getErrorColor(),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTcAgreement(RegistrationController controller) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: controller.agreeTC
                    ? MyColor.getPrimaryColor().withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: controller.agreeTC
                      ? MyColor.getPrimaryColor()
                      : MyColor.getFieldDisableBorderColor(),
                  width: 1.5,
                ),
              ),
              child: Checkbox(
                value: controller.agreeTC,
                checkColor: MyColor.getPrimaryColor(),
                activeColor: Colors.transparent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (bool? value) {
                  controller.updateAgreeTC();
                },
              ),
            ),
            Flexible(
              child: Row(
                children: [
                  Text(
                    MyStrings.iAgreeWith.tr,
                    style: interRegularDefault.copyWith(
                      color: MyColor.getTextColor2(),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 3),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(RouteHelper.privacyScreen);
                    },
                    child: Text(
                      MyStrings.policies.tr.toLowerCase(),
                      style: GoogleFonts.inter(
                        color: MyColor.getPrimaryColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: MyColor.getPrimaryColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton(RegistrationController controller) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + value * 0.2,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MyColor.getPrimaryColor().withOpacity(0.9),
              MyColor.getPrimaryColor(),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: MyColor.getPrimaryColor().withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: controller.submitLoading
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          )
              : InkWell(
            onTap: () {
              if (formKey.currentState!.validate()) {
                controller.signUpUser();
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: Text(
                MyStrings.signUp.toUpperCase().tr,
                style: interMediumMediumLarge.copyWith(
                  color: MyColor.getButtonTextColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInOption() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            MyStrings.alreadyAccount.tr,
            style: interRegularLarge.copyWith(
              color: MyColor.getTextColor2(),
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.find<RegistrationController>().clearAllData();
              Get.offAndToNamed(RouteHelper.loginScreen);
            },
            style: TextButton.styleFrom(
              foregroundColor: MyColor.getPrimaryColor(),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              MyStrings.signIn.tr,
              style: interRegularLarge.copyWith(
                color: MyColor.getPrimaryColor(),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}