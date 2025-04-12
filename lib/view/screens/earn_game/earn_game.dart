// earn_game_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';

import '../../../core/utils/url.dart';
import '../../../data/controller/dashboard/dashboard_controller.dart';
import '../../../data/controller/game/game_controller.dart';
import '../../../data/controller/investment/investment_controller.dart';
import '../../../data/repo/dashboard_repo.dart';
import '../../../data/repo/investment_repo/investment_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/show_custom_snackbar.dart';

class EarnGameScreen extends StatefulWidget {
  final String investmentId;

  const EarnGameScreen({Key? key, required this.investmentId}) : super(key: key);

  @override
  State<EarnGameScreen> createState() => _EarnGameScreenState();
}

class _EarnGameScreenState extends State<EarnGameScreen> {
  final EarnGameController controller = Get.put(EarnGameController());
  // final DashBoardController controller2 = Get.put(DashBoardController(dashboardRepo: null));
  bool isClaimingReward = false;
  late DashboardRepo dashboardRepo;
  @override
  void initState() {
    super.initState();
    controller.setInvestmentId(widget.investmentId);
    Get.put(DashboardRepo(apiClient: Get.find()));
    final controller2 = Get.put(DashBoardController(dashboardRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller2.loadActivePlan();
    });
    // Debug print
    print('EarnGameScreen initialized with investmentId: ${widget.investmentId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppBar(
        backgroundColor: MyColor.getPrimaryColor(),
        title: const Text("Memory Challenge"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goToHome,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return controller.gameStarted.value
                ? _buildGameScreen(context)
                : _buildStartScreen();
          }),
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Memory Challenge",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: MyColor.getPrimaryColor(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Match all pairs to earn rewards!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: MyColor.getTextColor(),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: controller.initGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.getPrimaryColor(),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              shadowColor: MyColor.getPrimaryColor().withOpacity(0.3),
            ),
            child: Text(
              "Start Game",
              style: TextStyle(
                fontSize: 18,
                color: MyColor.getButtonTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(BuildContext context) {
    return Column(
      children: [
        _buildGameHeader(),
        const SizedBox(height: 16),
        Expanded(child: _buildGameGrid()),
        Obx(() => controller.showRewardOption.value
            ? _buildRewardSection()
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildGameHeader() {
    return Obx(() {
      return Card(
        elevation: 8,
        shadowColor: MyColor.getPrimaryColor().withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: MyColor.getCardBg(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderItem("Time", controller.formatDuration()),
              _buildHeaderItem("Tries", "${controller.tries.value}"),
              _buildHeaderItem("Score", "${controller.score.value}"),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGameGrid() {
    return Obx(() {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.gameImg.length,
        itemBuilder: (context, index) {
          return _buildCard(index);
        },
      );
    });
  }

  Widget _buildCard(int index) {
    return Obx(() {
      final isHidden = controller.gameImg[index] == controller.hiddenCardPath;
      return GestureDetector(
        onTap: () => controller.onCardTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: MyColor.getCardBg(),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: MyColor.getBorderColor(),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isHidden
                  ? Container(
                key: ValueKey('hidden_$index'),
                decoration: BoxDecoration(
                  color: MyColor.getPrimaryColor().withOpacity(0.1),
                ),
                child: Icon(
                  Icons.question_mark,
                  size: 30,
                  color: MyColor.getPrimaryColor(),
                ),
              )
                  : Container(
                key: ValueKey('revealed_$index'),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(controller.gameImg[index]),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRewardSection() {
    return Obx(() {
      return Card(
        elevation: 8,
        shadowColor: MyColor.getPrimaryColor().withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: MyColor.getCardBg(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "🎉 Congratulations!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MyColor.getPrimaryColor(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You matched all pairs in ${controller.formatDuration()}!",
                style: TextStyle(
                  fontSize: 16,
                  color: MyColor.getTextColor(),
                ),
              ),
              const SizedBox(height: 16),
              if (!controller.rewardEarned.value)
                isClaimingReward
                    ? CircularProgressIndicator(
                  color: MyColor.greenSuccessColor,
                )
                    : ElevatedButton(
                  onPressed: () => _claimReward(widget.investmentId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.greenSuccessColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: MyColor.greenSuccessColor.withOpacity(0.3),
                  ),
                  child: const Text(
                    "Claim Your Reward",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (controller.rewardEarned.value)
                Column(
                  children: [
                    Text(
                      "✅ Reward Claimed",
                      style: TextStyle(
                        fontSize: 18,
                        color: MyColor.greenSuccessColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.getPrimaryColor(),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Return to Investments",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeaderItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: MyColor.getTextColor().withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MyColor.getPrimaryColor(),
          ),
        ),
      ],
    );
  }

  Future<void> _claimReward(String investmentId) async {
    // Set loading state
    setState(() {
      isClaimingReward = true;
    });

    try {
      // Get auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPreferenceHelper.accessTokenKey) ?? '';

      print("Sending reward request for investment ID: $investmentId");

      final response = await http.post(
        Uri.parse(UrlContainer.baseUrl + UrlContainer.earnAwardEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'investment_id': investmentId,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          controller.setRewardEarned(true);

          // Show success message
          CustomSnackBar.success(
              successList: data['message']['success'] != null && data['message']['success'].isNotEmpty
                  ? [data['message']['success'][0]]
                  : ['Reward successfully claimed!']
          );
          _refreshInvestmentData();
        } else {
          // Handle various API error responses
          String errorMessage = 'Failed to claim reward';

          if (data['message'] != null) {
            if (data['message']['error'] != null && data['message']['error'].isNotEmpty) {
              errorMessage = data['message']['error'][0];
            } else if (data['message'] is String) {
              errorMessage = data['message'];
            }
          }

          CustomSnackBar.error(errorList: [errorMessage]);
        }
      } else {
        // HTTP error
        CustomSnackBar.error(errorList: ['Server error: ${response.statusCode}']);
      }
    } catch (e) {
      print('Error claiming reward: $e');
      CustomSnackBar.error(errorList: ['Error: $e']);
    } finally {
      setState(() {
        isClaimingReward = false;
      });
    }
  }


  Future<void> _refreshInvestmentData() async {
    try {
      // Initialize repositories
      final apiClient = Get.find<ApiClient>();
      final investmentRepo = InvestmentRepo(apiClient: apiClient);
      final dashboardRepo = DashboardRepo(apiClient: apiClient);


      final investmentController = Get.put(InvestmentController(repo: investmentRepo));
      await investmentController.loadData(forceRefresh: true);


      final dashboardController = Get.put(DashBoardController(dashboardRepo: dashboardRepo));
      await dashboardController.loadActivePlan();

    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  // In EarnGameScreen where the reward is claimed
// After successful API response for claiming the reward:


}