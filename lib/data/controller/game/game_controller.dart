import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';

class EarnGameController extends GetxController {
  // Game state
  final RxList<String> gameImg = <String>[].obs;
  final RxInt tries = 0.obs;
  final RxInt score = 0.obs;
  final RxBool gameCompleted = false.obs;
  final RxBool showRewardOption = false.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxBool rewardEarned = false.obs;
  final RxBool gameStarted = false.obs;
  final RxBool isProcessing = false.obs; // Flag to prevent rapid clicking

  // Investment tracking
  final RxString investmentId = ''.obs;

  // Non-reactive variables
  late List<String> cardsList;
  List<Map<int, String>> matchCheck = [];
  Timer? gameTimer;
  DateTime? startTime;
  final String hiddenCardPath = 'assets/images/hidden.png';

  @override
  void onClose() {
    gameTimer?.cancel();
    super.onClose();
  }

  void setInvestmentId(String id) {
    investmentId.value = id;
  }

  void setRewardEarned(bool earned) {
    rewardEarned.value = earned;
  }

  void goToHome() {
    gameTimer?.cancel();
    Get.back();
  }

  void initGame() {
    cardsList = List.from(hardCards)..shuffle(Random());
    gameImg.value = List.filled(cardsList.length, hiddenCardPath);
    matchCheck.clear();

    tries.value = 0;
    score.value = 0;
    gameCompleted.value = false;
    rewardEarned.value = false;
    showRewardOption.value = false;
    elapsedSeconds.value = 0;
    isProcessing.value = false;
    startTime = DateTime.now();
    gameStarted.value = true;

    startTimer();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds.value++;
    });
  }

  void claimReward() {
    rewardEarned.value = true;
    gameTimer?.cancel();
  }

  void onCardTap(int index) {
    // Skip if game completed, card already matched, or processing is happening
    if (gameCompleted.value ||
        matchCheck.any((e) => e.containsKey(index)) ||
        gameImg[index] != hiddenCardPath ||
        isProcessing.value) {
      return;
    }

    gameImg[index] = cardsList[index];
    matchCheck.add({index: cardsList[index]});

    if (matchCheck.length == 2) {
      tries.value++;
      if (matchCheck[0].values.first == matchCheck[1].values.first) {
        // Match found
        score.value += 10;
        matchCheck.clear();

        // Check if all pairs are found
        if (!gameImg.contains(hiddenCardPath)) {
          gameCompleted.value = true;
          showRewardOption.value = true;
          gameTimer?.cancel();
        }
      } else {
        // No match
        score.value -= 2;

        // Set processing flag to prevent clicking during animation
        isProcessing.value = true;

        Future.delayed(const Duration(milliseconds: 500), () {
          // Only hide cards if they're still in the matchCheck list
          // (This prevents race conditions from rapid clicking)
          if (matchCheck.length == 2) {
            gameImg[matchCheck[0].keys.first] = hiddenCardPath;
            gameImg[matchCheck[1].keys.first] = hiddenCardPath;
            matchCheck.clear();
          }
          isProcessing.value = false;
        });
      }
    }
  }

  String formatDuration() {
    final seconds = elapsedSeconds.value;
    return "${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}";
  }

  // Hard level cards (12 pairs)
  final List<String> hardCards = [
    "assets/game/circle.png",
    "assets/game/deer.png",
    "assets/game/elephant.png",
    "assets/game/heart.png",
    "assets/game/lion.png",
    "assets/game/man.png",
    "assets/game/monkey.png",
    "assets/game/snake.png",
    "assets/game/star.png",
    "assets/game/tiger.png",
    "assets/game/triangle.png",
    "assets/game/woman.png",
    "assets/game/circle.png",
    "assets/game/deer.png",
    "assets/game/elephant.png",
    "assets/game/heart.png",
    "assets/game/lion.png",
    "assets/game/man.png",
    "assets/game/monkey.png",
    "assets/game/snake.png",
    "assets/game/star.png",
    "assets/game/tiger.png",
    "assets/game/triangle.png",
    "assets/game/woman.png",
  ];
}