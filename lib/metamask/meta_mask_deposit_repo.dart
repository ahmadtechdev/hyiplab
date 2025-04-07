import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/method.dart' as method;
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class MetaMaskDepositRepo {
  final ApiClient apiClient;

  MetaMaskDepositRepo({required this.apiClient});

  Future<dynamic> saveMetaMaskDeposit({
    required double amount,
    required String currency,
    required String walletAddress,
    required String transactionHash,
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.depositInsertUrl}';

    Map<String, dynamic> param = {
      'method_code': 'metamask',
      'amount': amount.toString(),
      'currency': currency,
      'wallet_address': walletAddress,
      'transaction_hash': transactionHash,
    };

    ResponseModel response = await apiClient.request(
        url,
        method.Method.postMethod,
        param,
        passHeader: true
    );

    if (kDebugMode) {
      print(response.responseJson);
      print(response.statusCode);
    }

    if (response.statusCode == 200) {
      dynamic model = jsonDecode(response.responseJson);

      if (model['status'] == 'success') {
        return model;
      } else {
        CustomSnackBar.showCustomSnackBar(
            errorList: model['message']['error'] ?? ['Unknown error occurred'],
            msg: [],
            isError: true
        );
        return model;
      }
    } else {
      return {'status': 'error', 'message': {'error': ['Server error']}};
    }
  }
}