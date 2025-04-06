// earn_game_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_color.dart';

import '../../../data/controller/game/game_controller.dart';

class EarnGameScreen extends StatelessWidget {
  EarnGameScreen({super.key});
  final EarnGameController controller = Get.put(EarnGameController());

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
                ElevatedButton(
                  onPressed: controller.claimReward,
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
                Text(
                  "✅ Reward Claimed",
                  style: TextStyle(
                    fontSize: 18,
                    color: MyColor.greenSuccessColor,
                    fontWeight: FontWeight.bold,
                  ),
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
}