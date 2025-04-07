import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

import 'meta_mask_deposit_repo.dart';
import 'metamask_service.dart';

class MetaMaskDepositController extends GetxController {
  final MetaMaskService metamaskService;
  final MetaMaskDepositRepo depositRepo;

  MetaMaskDepositController({
    required this.metamaskService,
    required this.depositRepo,
  });

  // Form controller
  final TextEditingController amountController = TextEditingController();

  // State variables
  bool isLoading = false;
  bool submitLoading = false;
  bool isWalletConnected = false;
  String? walletAddress;
  double amount = 0.0;

  // Receiver address - Replace with your project's wallet address
  final String receiverAddress = '0x1296f86272209D61b7dDbdac49BB42050920D118';

  @override
  void onInit() {
    super.onInit();
    initMetaMask();
  }

  Future<void> initMetaMask() async {
    isLoading = true;
    update();

    await metamaskService.init();
    isWalletConnected = metamaskService.isConnected;
    walletAddress = metamaskService.walletAddress;

    isLoading = false;
    update();
  }

  Future<void> connectWallet() async {
    isLoading = true;
    update();

    try {
      walletAddress = await metamaskService.connectWallet();
      isWalletConnected = walletAddress != null;

      if (isWalletConnected) {
        CustomSnackBar.success(successList: ['Wallet connected successfully']);
      } else {
        CustomSnackBar.error(errorList: ['Failed to connect wallet']);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Error: ${e.toString()}']);
    }

    isLoading = false;
    update();
  }

  Future<void> disconnectWallet() async {
    isLoading = true;
    update();

    await metamaskService.disconnect();
    isWalletConnected = false;
    walletAddress = null;

    isLoading = false;
    update();
  }

  void updateAmount(String value) {
    if (value.isEmpty) {
      amount = 0;
    } else {
      amount = double.tryParse(value) ?? 0;
    }
    update();
  }

  void copyWalletAddress() {
    if (walletAddress != null) {
      Clipboard.setData(ClipboardData(text: walletAddress!));
      CustomSnackBar.success(successList: ['Wallet address copied to clipboard']);
    }
  }

  Future<void> makePayment() async {
    if (!isWalletConnected) {
      CustomSnackBar.error(errorList: ['Please connect your MetaMask wallet first']);
      return;
    }

    if (amount <= 0) {
      CustomSnackBar.error(errorList: ['Please enter a valid amount']);
      return;
    }

    submitLoading = true;
    update();

    try {
      final transactionHash = await metamaskService.sendTransaction(
        toAddress: receiverAddress,
        amount: amount,
        currency: 'ETH',
      );

      if (transactionHash != null) {
        // Save transaction to the server
        final response = await depositRepo.saveMetaMaskDeposit(
          amount: amount,
          currency: 'ETH',
          walletAddress: walletAddress!,
          transactionHash: transactionHash,
        );

        if (response['status'] == 'success') {
          amountController.clear();
          amount = 0;
          CustomSnackBar.success(successList: ['Payment successful!']);
        } else {
          CustomSnackBar.error(errorList: ['Payment processed but failed to save']);
        }
      } else {
        CustomSnackBar.error(errorList: ['Transaction failed or was cancelled']);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Error: ${e.toString()}']);
    }

    submitLoading = false;
    update();
  }

  @override
  void dispose() {
    amountController.dispose();
    metamaskService.dispose();
    super.dispose();
  }
}