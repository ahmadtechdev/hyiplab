import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_images.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/investment/investment_controller.dart';
import 'package:hyip_lab/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/divider/custom_divider.dart';
import 'package:hyip_lab/view/components/drop_dawn/custom_drop_down_field3.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';
import 'package:hyip_lab/view/components/text/default_text.dart';
import 'package:hyip_lab/view/components/text/label_text.dart';
import 'package:hyip_lab/view/components/text/small_text.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../data/controller/dashboard/dashboard_controller.dart';
import '../../earn_game/earn_game.dart';

class ActivePlanCard extends StatelessWidget {
  const ActivePlanCard({
    Key? key,
    this.eligibleForCapitalBack = false,
    required this.investmentId,
    required this.name,
    required this.nextReturn,
    required this.totalReturn,
    required this.invested,
    required this.message,
    required this.percent,
    this.isActive = true,
    this.hasCapital = false,
    this.canEarnReward = true,
    required this.earn, // Add this parameter to control if user can earn reward today
  }) : super(key: key);

  final String name;
  final String earn;
  final String nextReturn;
  final String totalReturn;
  final String invested;
  final String message;
  final bool isActive;
  final double percent;
  final bool hasCapital;
  final String investmentId;
  final bool eligibleForCapitalBack;
  final bool canEarnReward; // Flag to track if user already claimed reward today

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space10 + 2, horizontal: Dimensions.space15),
      decoration: BoxDecoration(color: MyColor.getCardBg(), borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$name - $message", style: interSemiBoldDefault.copyWith(color: MyColor.getTextColor())),
                    Row(
                      children: [
                        // Game reward button
                        // In the build method of ActivePlanCard:
// Game reward button
                        // In the build method of ActivePlanCard:
// Game reward button
                        // In the build method where the game button is created:
                        if (isActive)
                          InkWell(
                            onTap: () {
                              print('Earn value before launch: $earn'); // Debug print
                              _launchGameForReward(context, investmentId, earn == '0');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: earn == '0'
                                    ? MyColor.getPrimaryColor()
                                    : MyColor.getTextColor3().withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.videogame_asset,
                                    size: 17,
                                    color: MyColor.colorWhite,
                                  ),
                                  if (earn == '0')
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 8,
                                          color: MyColor.colorWhite,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Progress indicator
                        Visibility(
                          visible: isActive || eligibleForCapitalBack,
                          child: isActive
                              ? Row(
                            children: [
                              CircularPercentIndicator(
                                radius: 18.0,
                                lineWidth: 4.0,
                                percent: percent,
                                backgroundColor: MyColor.getTextColor(),
                                progressColor: MyColor.greenSuccessColor,
                              ),
                              const SizedBox(width: Dimensions.space10),
                            ],
                          )
                              : eligibleForCapitalBack
                              ? InkWell(
                            onTap: () {
                              CustomBottomSheet(
                                  backgroundColor: MyColor.getCardBg(),
                                  child: GetBuilder<InvestmentController>(builder: (controller) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              MyStrings.manageInvestCapital,
                                              style: interSemiBoldDefault.copyWith(color: MyColor.getTextColor()),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Get.back();
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: MyColor.getCardBg().withValues(alpha: .4)),
                                                child: Icon(
                                                  Icons.clear,
                                                  size: 17,
                                                  color: MyColor.getTextColor(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const CustomDivider(
                                          space: Dimensions.space20,
                                        ),
                                        const LabelText(text: MyStrings.investmentCapital),
                                        CustomDropDownTextField3(
                                            fillColor: MyColor.getCardBg().withValues(alpha: .2),
                                            selectedValue: controller.selectedInvestmentCapital,
                                            onChanged: (value) {
                                              controller.changeInvestmentCapitalType(value);
                                            },
                                            items: controller.investmentCapitalType.map<DropdownMenuItem<String>>((value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: Dimensions.fontDefault, color: MyColor.getTextColor()),
                                                ),
                                              );
                                            }).toList()),
                                        const SizedBox(height: Dimensions.space40 + Dimensions.space30),
                                        controller.isSubmitInvestmentLoading
                                            ? const RoundedLoadingBtn()
                                            : RoundedButton(
                                            text: MyStrings.submit,
                                            press: () {
                                              controller.submitInvestmentData(investmentId);
                                            }),
                                        const SizedBox(height: Dimensions.space20),
                                      ],
                                    );
                                  })).customBottomSheet(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.space10),
                              decoration:
                              const BoxDecoration(color: MyColor.primaryColor, shape: BoxShape.circle),
                              child: Image.asset(
                                MyImages.deposit,
                                height: 17,
                                width: 17,
                                color: MyColor.colorWhite,
                              ),
                            ),
                          )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.space5),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "${MyStrings.invested.tr}: ",
                        style: interRegularExtraSmall.copyWith(color: MyColor.getTextColor())),
                    TextSpan(
                        text: invested, style: interRegularExtraSmall.copyWith(color: MyColor.getPrimaryColor())),
                    TextSpan(
                        text: hasCapital ? " (${MyStrings.capitalBack})" : '',
                        style: interRegularExtraSmall.copyWith(color: MyColor.getTextColor())),
                  ]),
                ),
                const SizedBox(height: Dimensions.space15),
                SizedBox(
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SmallText(
                                  text: MyStrings.nextReturn,
                                  textStyle:
                                  interRegularExtraSmall.copyWith(color: MyColor.getTextColor3())),
                              const SizedBox(height: Dimensions.space5),
                              SmallText(
                                  text: nextReturn,
                                  textStyle: interRegularSmall.copyWith(color: MyColor.getTextColor()))
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SmallText(
                                  text: MyStrings.totalReturn,
                                  textStyle:
                                  interRegularExtraSmall.copyWith(color: MyColor.getTextColor3())),
                              const SizedBox(height: Dimensions.space5),
                              Expanded(
                                  child: Text(
                                    totalReturn,
                                    style: interRegularSmall.copyWith(color: MyColor.getTextColor()),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  void _launchGameForReward(BuildContext context, String investmentId, bool canPlay) {
    print('Can play status: $canPlay for investment ID: $investmentId');

    if (!canPlay) {
      // Show message if user already claimed reward today
      CustomSnackBar.success(successList: ['You already claimed your reward for now. Come back later!']);
      return;
    }

    // Navigate to game screen with investment ID and await the result
    Get.to(() => EarnGameScreen(investmentId: investmentId))?.then((value) {

    });
  }
}