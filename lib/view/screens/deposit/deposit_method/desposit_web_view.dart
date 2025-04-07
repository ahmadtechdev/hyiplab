import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';

import '../../../../core/helper/shared_preference_helper.dart';

class DepositWebViewScreen extends StatefulWidget {
  const DepositWebViewScreen({Key? key}) : super(key: key);

  @override
  State<DepositWebViewScreen> createState() => _DepositWebViewScreenState();
}

class _DepositWebViewScreenState extends State<DepositWebViewScreen> {
  late WebViewController _webViewController;
  bool isLoading = true;
  String userId = '';
  String amount = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    // Get user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(SharedPreferenceHelper.userIdKey) ?? '';

    // Get amount from arguments or use default
    amount = Get.arguments['amount'] ?? '0';

    // Initialize WebView with user data
    _initWebView();
  }

  void _initWebView() {
    final String url = 'https://viserlab.girdonawah.com/deposit-now/$userId/$amount';
print(":check");
    print(url);
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(MyColor.getScreenBgColor())
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.getPrimaryColor(),
        title: Text(
          MyStrings.deposit.tr,
          style: TextStyle(color: MyColor.getAppbarBgColor()),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: MyColor.getTextColor(),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: MyColor.getPrimaryColor(),
              ),
            ),
        ],
      ),
      // Keep your app's bottom navigation bar here
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: MyColor.getBottomNavBg(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.account_balance_wallet, MyStrings.wallet.tr, 0),
          _navItem(Icons.history, MyStrings.history.tr, 1),
          _navItem(Icons.home, MyStrings.home.tr, 2),
          _navItem(Icons.person, MyStrings.profile.tr, 3),
          _navItem(Icons.settings, "Settings", 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () {
        // Handle navigation if needed
        if (index != 2) { // Assuming 2 is current screen
          Get.back(); // Go back from webview
          // Navigate to the selected tab
          // You might need proper navigation logic here
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: index == 2
                ? MyColor.getPrimaryColor()
                : MyColor.getTextColor().withOpacity(0.6),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: index == 2
                  ? MyColor.getPrimaryColor()
                  : MyColor.getTextColor().withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}