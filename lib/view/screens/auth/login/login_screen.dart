import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/auth/login_controller.dart';
import 'package:hyip_lab/data/repo/auth/login_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text-field/custom_text_field.dart';
import 'package:hyip_lab/view/components/will_pop_widget.dart';
import 'package:hyip_lab/view/screens/auth/login/widget/social_login_section.dart';

import '../../../../data/controller/common/theme_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LoginRepo(apiClient: Get.find()));
    Get.put(LoginController(loginRepo: Get.find()));

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LoginController>().remember = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopWidget(
      nextRoute: '',
      child: Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        body: GetBuilder<LoginController>(
          builder: (controller) => SingleChildScrollView(
            child: Column(
              children: [
                // Header Section with Animated Background
                _buildHeader(size),

                // Form Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Get.find<ThemeController>().darkTheme
                              ? MyColor.cardBgColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: MyColor.getPrimaryColor().withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: _buildLoginForm(controller),
                      ),
                    ),
                  ),
                ),

                // Social Login Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SocialLoginSection(),
                  ),
                ),

                // Sign Up Option
                const SizedBox(height: 25),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSignUpOption(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      height: size.height * 0.32,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MyColor.getPrimaryColor(),
            MyColor.getPrimaryColor().withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getPrimaryColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Header Background Pattern
          Positioned(
            right: -40,
            top: -40,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -50,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Header Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  // App Logo or Icon
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: MyColor.getPrimaryColor(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Welcome Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      MyStrings.welcomeBack.tr,
                      style: interRegularHeader4.copyWith(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtitle
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        MyStrings.subTittle,
                        textAlign: TextAlign.center,
                        style: interRegularDefault.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(LoginController controller) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MyStrings.signIn.tr,
            style: interRegularHeader4.copyWith(
              fontSize: 24,
              color: MyColor.getTextColor(),
            ),
          ),
          const SizedBox(height: 25),

          // Email Field
          CustomTextField(
            needOutlineBorder: true,
            controller: controller.emailController,
            labelText: MyStrings.usernameOrEmail.tr,
            hintText: MyStrings.usernameOrEmailHint.tr,
            onChanged: (value) {},
            focusNode: controller.emailFocusNode,
            nextFocus: controller.passwordFocusNode,
            textInputType: TextInputType.emailAddress,
            inputAction: TextInputAction.next,
            prefixIcon: Icon(
              Icons.person_outline,
              color: MyColor.getPrimaryColor().withOpacity(0.7),
            ),
            hasShadow: true,
            validator: (value) {
              if (value!.isEmpty) {
                return MyStrings.fieldErrorMsg.tr;
              } else {
                return null;
              }
            },
          ),

          const SizedBox(height: 20),

          // Password Field
          CustomTextField(
            needOutlineBorder: true,
            labelText: MyStrings.password.tr,
            hintText: MyStrings.passwordHint.tr,
            controller: controller.passwordController,
            focusNode: controller.passwordFocusNode,
            onChanged: (value) {},
            isShowSuffixIcon: true,
            isPassword: true,
            textInputType: TextInputType.text,
            inputAction: TextInputAction.done,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: MyColor.getPrimaryColor().withOpacity(0.7),
            ),
            hasShadow: true,
            validator: (value) {
              if (value!.isEmpty) {
                return MyStrings.fieldErrorMsg.tr;
              } else {
                return null;
              }
            },
          ),

          const SizedBox(height: 15),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember Me
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        activeColor: MyColor.getPrimaryColor(),
                        checkColor: Colors.white,
                        value: controller.remember,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: BorderSide(
                          width: 1.5,
                          color: controller.remember
                              ? MyColor.getPrimaryColor()
                              : MyColor.getFieldDisableBorderColor(),
                        ),
                        onChanged: (value) {
                          controller.changeRememberMe();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    MyStrings.rememberMe.tr,
                    style: interRegularDefault.copyWith(
                      color: MyColor.getTextColor(),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Forgot Password
              TextButton(
                onPressed: () {
                  controller.clearTextField();
                  Get.toNamed(RouteHelper.forgetPasswordScreen);
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  MyStrings.forgotPassword.tr,
                  style: interRegularDefault.copyWith(
                    color: MyColor.getPrimaryColor(),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Login Button
          controller.isSubmitLoading
              ? const Center(child: RoundedLoadingBtn())
              : SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  controller.loginUser();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.getButtonColor(),
                foregroundColor: MyColor.getButtonTextColor(),
                elevation: 5,
                shadowColor: MyColor.getPrimaryColor().withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                MyStrings.signIn.toUpperCase().tr,
                style: interMediumMediumLarge.copyWith(
                  fontSize: 16,
                  color: MyColor.getButtonTextColor(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          MyStrings.noAccount.tr,
          style: interRegularLarge.copyWith(
            color: MyColor.getTextColor2(),
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: () {
            Get.offAndToNamed(RouteHelper.registrationScreen);
          },
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            MyStrings.signUp.tr,
            style: interMediumMediumLarge.copyWith(
              color: MyColor.getPrimaryColor(),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}