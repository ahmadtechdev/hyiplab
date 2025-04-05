import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/plan_payment_method_screen/payment_method_controller.dart';
import 'package:hyip_lab/data/model/authorized/deposit/deposit_method_response_model.dart';
import 'package:hyip_lab/data/repo/deposit_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text-field/custom_amount_text_field.dart';
import 'package:hyip_lab/view/components/text/label_text.dart';
import 'package:hyip_lab/view/components/text/show_more.dart';
import '../../../../data/model/plan/plan_model.dart';
import 'widget/payment_method_info.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {


  @override
  void dispose() {
    Get.find<PaymentMethodController>().clearData();
    super.dispose();
  }

  @override
  void initState() {
    Plans p = Get.arguments;

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(DepositRepo(apiClient: Get.find()));
    final controller = Get.put(PaymentMethodController(repo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData(p);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentMethodController>(
      builder: (controller) => SafeArea(
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: CustomAppBar(
            title: "${MyStrings.confirmToInvestOn.tr} ${controller.plan.name.toString().tr}",
            isTitleCenter: true,
            isShowBackBtn: true,
            bgColor: MyColor.getAppbarBgColor(),
          ),
          body: controller.isLoading
            ? const CustomLoader()
            : SingleChildScrollView(
                child: Padding(
                  padding: Dimensions.screenPaddingHV,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: Dimensions.space30,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${MyStrings.invest.tr} : ", style: interBoldDefault.copyWith(color: MyColor.getTextColor())),
                              Text(controller.isFixed?controller.curSymbol + Converter.twoDecimalPlaceFixedWithoutRounding(controller.plan.fixedAmount ?? " "):
                                    "${controller.curSymbol + Converter.twoDecimalPlaceFixedWithoutRounding(controller.plan.minimum ?? " ")} - "
                                    "${controller.curSymbol + Converter.twoDecimalPlaceFixedWithoutRounding(controller.plan.maximum ?? " ")}",
                                style: interBoldDefault.copyWith(color: MyColor.getTextColor()),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: Dimensions.space5,
                          ),
                          Text(
                            "${MyStrings.interest.tr} : ${controller.interestAmount}",
                            style: interBoldDefault.copyWith(color: MyColor.getTextColor()),
                          ),
                          const SizedBox(
                            height: Dimensions.space5,
                          ),
                          Text(
                            "${controller.plan.interestValidity}",
                            style: interBoldDefault.copyWith(color: MyColor.getTextColor()),
                          ),
                          const SizedBox(
                            height: Dimensions.space5,
                          ),
                          Text(
                            "${controller.plan.totalReturn}",
                            style: interBoldDefault.copyWith(color: MyColor.getTextColor()),
                          ),
                          const SizedBox(
                            height: Dimensions.space10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      LabelText(text: MyStrings.payVia.tr, required: true),
                      const SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: 0),
                        decoration: BoxDecoration(color: MyColor.transparentColor, borderRadius: BorderRadius.circular(Dimensions.defaultRadius), border: Border.all(color: controller.paymentMethod?.id.toString() == '-1' ? MyColor.getFieldDisableBorderColor() : MyColor.getPrimaryColor(), width: 0.5)),
                        child: DropdownButton<Methods>(
                          hint: Text(MyStrings.selectOne.tr),
                          value: controller.paymentMethod,
                          elevation: 8,
                          icon: Icon(Icons.keyboard_arrow_down, color: controller.paymentMethod?.id.toString() == '-1' ? MyColor.getTextColor() : MyColor.getPrimaryColor()),
                          iconDisabledColor: Colors.red,
                          iconEnabledColor: MyColor.primaryColor,
                          dropdownColor: MyColor.getCardBg(),
                          isExpanded: true,
                          underline: Container(
                            height: 0,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (Methods? newValue) {
                            controller.setPaymentMethod(newValue);
                          },
                          items: controller.paymentMethodList.map((Methods method) {
                            return DropdownMenuItem<Methods>(
                              value: method,
                              child: Text(Converter.replaceUnderscoreWithSpace(method.name.toString()).tr, overflow: TextOverflow.ellipsis, style: interRegularDefault.copyWith(color: MyColor.getTextColor())),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomAmountTextField(
                        labelText: MyStrings.investAmount.tr,
                        currency: controller.currency,
                        hintText: '0.0',
                        readOnly: controller.isFixed,
                        inputAction: TextInputAction.done,
                        controller: controller.amountController,
                        onChanged: (value) {
                          if (value.toString().isEmpty) {
                            controller.changeInfoWidgetValue(0);
                          } else {
                            double amount = double.tryParse(value.toString()) ?? 0;
                            controller.changeInfoWidgetValue(amount);
                          }
                          return;
                        },
                      ),
                     Visibility(
                       visible:controller.plan.compoundInterest=='1',
                       child: Column(
                       children: [
                         const SizedBox(height: 20),
                         CustomAmountTextField(
                           labelText: MyStrings.compoundInterest,
                           hintText: "",
                           isRequired: false,
                           currency: MyStrings.times,
                           controller: controller.compoundInterestController,
                           onChanged: (value) {

                           },
                         ),
                       ],
                     )),
                      const SizedBox(height: Dimensions.space5,),
                      bottomHintRow(MyStrings.compoundText),
                      const SizedBox(height: 20),
                      Visibility(
                        visible: controller.isScheduleInvestOn == "1" ? true : false,
                        child: Column(
                          children: [
                            LabelText(text: MyStrings.autoSheduleInvest.tr, required: true),
                            const SizedBox(height: 8),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: 0),
                              decoration: BoxDecoration(color: MyColor.transparentColor, borderRadius: BorderRadius.circular(Dimensions.defaultRadius), border: Border.all(color: controller.paymentMethod?.id.toString() == '-1' ? MyColor.getFieldDisableBorderColor() : MyColor.getPrimaryColor(), width: 0.5)),
                              child: DropdownButton<String>(
                                hint: Text(MyStrings.selectOne.tr),
                                value: controller.investMethod,
                                elevation: 8,
                                icon: Icon(Icons.keyboard_arrow_down, color:  MyColor.getTextColor()),
                                iconDisabledColor: Colors.red,
                                iconEnabledColor: MyColor.primaryColor,
                                dropdownColor: MyColor.getCardBg(),
                                isExpanded: true,
                                underline: Container(
                                  height: 0,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String? newValue) {
                                  controller.setInvestMethod(newValue.toString());
                                },
                                items: controller.investMethodList.map((String method) {
                                  return DropdownMenuItem<String>(
                                    value: method,
                                    child: Text(Converter.replaceUnderscoreWithSpace(method.toString()).tr, overflow: TextOverflow.ellipsis, style: interRegularDefault.copyWith(color: MyColor.getTextColor())),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 5),
                            bottomHintRow(MyStrings.scheduleInvestText),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )),
                      Visibility(
                        visible: controller.investMethod.toLowerCase() == MyStrings.schedule.toLowerCase() ? true : false,
                        child: Column(
                          children: [
                            CustomAmountTextField(
                              labelText: MyStrings.scheduleFor,
                              hintText: "",
                              currency: MyStrings.times,
                              onChanged: (val) {},
                              controller: controller.sheduleForController,
                            ),
                            const SizedBox(height: Dimensions.space5,),
                            bottomHintRow(MyStrings.scheduleForText),
                            const SizedBox(
                              height: 20,
                            ),
                            CustomAmountTextField(
                              labelText: MyStrings.after,
                              hintText: "",
                              currency: MyStrings.hours,
                              onChanged: (val) {},
                              controller: controller.afterController
                            ),
                            const SizedBox(height: Dimensions.space5,),
                            bottomHintRow(MyStrings.afterText),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )),
                      controller.isShowPreview() ? const InfoWidget() : const SizedBox(),
                      const SizedBox(
                        height: 30,
                      ),
                      controller.submitLoading
                        ? const RoundedLoadingBtn()
                        : Center(
                            child: RoundedButton(
                              press: () {
                                controller.submitDeposit();
                              },
                              text: MyStrings.submit.tr,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
        ),
      ));
  }

  Widget bottomHintRow(String text){
    return  Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: const Icon(Icons.info_outline_rounded,size: 13,color: MyColor.primaryColor,)
        ),
        const SizedBox(width: Dimensions.space5),
        Expanded(child: ShowMore(text,textStyle: interRegularDefault.copyWith(color: MyColor.primaryColor,fontSize: Dimensions.space12)))
      ],
    );
  }
}
