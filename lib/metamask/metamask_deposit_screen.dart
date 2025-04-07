import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text-field/custom_amount_text_field.dart';
import 'package:hyip_lab/view/components/text/label_text.dart';

import 'meta_mask_deposit_repo.dart';
import 'metamask_deposit_controller.dart';
import 'metamask_service.dart';

class MetaMaskDepositScreen extends StatefulWidget {
  const MetaMaskDepositScreen({Key? key}) : super(key: key);

  @override
  State<MetaMaskDepositScreen> createState() => _MetaMaskDepositScreenState();
}

class _MetaMaskDepositScreenState extends State<MetaMaskDepositScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(MetaMaskDepositController(
      metamaskService: MetaMaskService(),
      depositRepo: MetaMaskDepositRepo(apiClient: Get.find()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MetaMask Deposit',
          style: interRegularLarge.copyWith(
            color: MyColor.getTextColor(),
          ),
        ),
        backgroundColor: MyColor.getAppbarBgColor(),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: MyColor.getTextColor(),
          ),
        ),
      ),
      body: GetBuilder<MetaMaskDepositController>(
        builder: (controller) => controller.isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: MyColor.getPrimaryColor(),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.space15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Connection Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.space15),
                decoration: BoxDecoration(
                  color: MyColor.getCardBg(),
                  borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                  border: Border.all(color: MyColor.getPrimaryColor().withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wallet Status',
                          style: interRegularDefault.copyWith(
                            color: MyColor.getTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.space10,
                            vertical: Dimensions.space5,
                          ),
                          decoration: BoxDecoration(
                            color: controller.isWalletConnected
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimensions.defaultRadius / 2),
                          ),
                          child: Text(
                            controller.isWalletConnected ? 'Connected' : 'Not Connected',
                            style: interRegularSmall.copyWith(
                              color: controller.isWalletConnected ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (controller.isWalletConnected) ...[
                      const SizedBox(height: Dimensions.space10),
                      Text(
                        'Wallet Address:',
                        style: interRegularSmall.copyWith(
                          color: MyColor.getTextColor().withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.walletAddress ?? '',
                              style: interRegularDefault.copyWith(
                                color: MyColor.getTextColor(),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.copyWalletAddress(),
                            icon: Icon(
                              Icons.copy,
                              color: MyColor.getPrimaryColor(),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: Dimensions.space10),
                    controller.isWalletConnected
                        ? RoundedButton(
                      color: Colors.red.withOpacity(0.8),
                      text: 'Disconnect Wallet',
                      textColor: Colors.white,
                      press: () => controller.disconnectWallet(),
                    )
                        : RoundedButton(
                      color: MyColor.getButtonColor(),
                      text: 'Connect MetaMask',
                      textColor: MyColor.getButtonTextColor(),
                      press: () => controller.connectWallet(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.space25),

              // Deposit Form
              LabelText(text: 'Deposit Details'),
              const SizedBox(height: Dimensions.space15),
              CustomAmountTextField(
                labelText: 'Amount',
                hintText: 'Enter amount',
                inputAction: TextInputAction.done,
                controller: controller.amountController,
                currency: 'ETH',
                onChanged: (value) => controller.updateAmount(value),
              ),
              const SizedBox(height: Dimensions.space15),

              // Transaction Preview
              if (controller.amount > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.space15),
                  decoration: BoxDecoration(
                    color: MyColor.getCardBg(),
                    borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                    border: Border.all(color: MyColor.getPrimaryColor().withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Preview',
                        style: interRegularDefault.copyWith(
                          color: MyColor.getTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space15),
                      _buildInfoRow('Amount', '${controller.amount} ETH'),
                      _buildInfoRow('Network Fee (Est.)', '0.0005 ETH'),
                      _buildInfoRow('Total', '${controller.amount + 0.0005} ETH'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: Dimensions.space30),

              // Submit Button
              controller.submitLoading
                  ? const RoundedLoadingBtn()
                  : RoundedButton(
                color: MyColor.getButtonColor(),
                text: 'Pay with MetaMask',
                textColor: MyColor.getButtonTextColor(),
                press: controller.isWalletConnected && controller.amount > 0
                    ? () => controller.makePayment()
                    : () {},
                opacity: controller.isWalletConnected && controller.amount > 0 ? 1 : 0.5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.space10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: interRegularSmall.copyWith(
              color: MyColor.getTextColor().withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: interRegularDefault.copyWith(
              color: MyColor.getTextColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}