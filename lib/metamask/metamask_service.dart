import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
// import 'package:walletconnect_secure_storage/walletconnect_secure_storage.dart';
import 'dart:async';

class MetaMaskService {
  static final MetaMaskService _instance = MetaMaskService._internal();

  factory MetaMaskService() => _instance;

  MetaMaskService._internal();

  WalletConnect? _connector;
  StreamSubscription? _sessionSubscription;
  String? _walletAddress;
  Web3Client? _web3client;
  final String _rpcUrl = "https://mainnet.infura.io/v3/YOUR_INFURA_KEY"; // Replace with your Infura key

  bool get isConnected => _walletAddress != null;
  String? get walletAddress => _walletAddress;

  Future<bool> init() async {
    _connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'Your App Name',
        description: 'Your app description',
        url: 'https://yourapp.com',
        icons: ['https://yourapp.com/icon.png'],
      ),
      // sessionStorage: WalletConnectSecureStorage(),
    );

    _web3client = Web3Client(_rpcUrl, Client());

    // // Listen for session updates
    // _sessionSubscription = _connector!.on('connect', (session) {
    //   if (session.accounts.isNotEmpty) {
    //     _walletAddress = session.accounts[0];
    //   }
    // });

    // Listen for session disconnection
    _connector!.on('disconnect', (payload) {
      _walletAddress = null;
    });

    return true;
  }

  Future<String?> connectWallet() async {
    if (_connector == null) await init();

    if (_connector!.connected) {
      return _walletAddress;
    }

    try {
      // Create a new session
      final session = await _connector!.connect(
        chainId: 1,
        onDisplayUri: (uri) async {
          final metamaskUri = Uri.parse('metamask://wc?uri=${Uri.encodeComponent(uri)}');
          if (await canLaunchUrl(metamaskUri)) {
            await launchUrl(metamaskUri, mode: LaunchMode.externalApplication);
          } else {
            // Fallback to regular URL which might open in browser
            final fallbackUrl = Uri.parse('https://metamask.app.link/wc?uri=${Uri.encodeComponent(uri)}');
            await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
          }
        },
      );

      _walletAddress = session.accounts[0];
      return _walletAddress;
    } catch (e) {
      debugPrint('Error connecting to wallet: $e');
      return null;
    }
  }

  Future<void> disconnect() async {
    if (_connector == null) return;
    if (_connector!.connected) {
      await _connector!.killSession();
    }
    _walletAddress = null;
  }

  Future<String?> sendTransaction({
    required String toAddress,
    required double amount,
    required String currency,
  }) async {
    if (_walletAddress == null) {
      await connectWallet();
      if (_walletAddress == null) return null;
    }

    final ethAmount = EtherAmount.fromUnitAndValue(
        EtherUnit.ether,
        BigInt.from(amount * 1000000000000000000) // Convert to Wei
    );

    try {
      // Create transaction parameters
      final transaction = {
        'from': _walletAddress,
        'to': toAddress,
        'value': '0x${ethAmount.getInWei.toRadixString(16)}',
        'gas': '0x${BigInt.from(21000).toRadixString(16)}',
      };

      // Send transaction through WalletConnect
      // final txHash = await _connector!.sendTransaction(transaction);
      final txHash = "await _connector!.sendTransaction(transaction)";

      return txHash;
    } catch (e) {
      debugPrint('Error sending transaction: $e');
      return null;
    }
  }

  void dispose() {
    _sessionSubscription?.cancel();
    _web3client?.dispose();
    // _connector?.dispose();
  }
}