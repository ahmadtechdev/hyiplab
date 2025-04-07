class MetaMaskPaymentModel {
  final double amount;
  final String currency;
  final String walletAddress;
  final String? transactionHash;

  MetaMaskPaymentModel({
    required this.amount,
    required this.currency,
    required this.walletAddress,
    this.transactionHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount.toString(),
      'currency': currency,
      'wallet_address': walletAddress,
      'transaction_hash': transactionHash,
    };
  }
}