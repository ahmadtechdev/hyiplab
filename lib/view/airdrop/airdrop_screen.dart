import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../core/helper/shared_preference_helper.dart';
import '../../core/utils/style.dart';
import '../../core/utils/url.dart';
import '../../data/controller/common/theme_controller.dart';


class AirdropScreen extends StatefulWidget {
  const AirdropScreen({Key? key}) : super(key: key);

  @override
  State<AirdropScreen> createState() => _AirdropScreenState();
}

class _AirdropScreenState extends State<AirdropScreen> with TickerProviderStateMixin {
  int tapCount = 0;
  int pendingCmcToSync = 0;
  int totalCmcCollected = 0;
  bool isAnimating = false;
  bool showReward = false;
  bool dailyCheckInClaimed = false;
  bool isLoading = true;
  String checkInMessage = '';

  // Date tracking for daily rewards
  String? lastCheckInDate;

  // Controllers for various animations
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late AnimationController _confettiController;

  // Lists to track particle animations
  final List<ParticleModel> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Add entrance animation
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });

    // Fetch CMC data from API first, then check daily reward
    _fetchCmcData().then((_) {
      _checkDailyReward();
    });
  }

  // New method to fetch CMC data from API
  Future<void> _fetchCmcData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPreferenceHelper.accessTokenKey) ?? '';

      final response = await http.get(
        Uri.parse(UrlContainer.baseUrl + UrlContainer.getCmcEndPoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data'] != null && data['data']['cmc'] != null) {
          setState(() {
            tapCount = data['data']['cmc'];
            totalCmcCollected = data['data']['cmc'];
          });

          // Update SharedPreferences with the new values
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('cmc_tap_count', tapCount);
          await prefs.setInt('total_cmc_collected', totalCmcCollected);

          print('Successfully loaded CMC data: $tapCount');
        } else {
          print('Invalid API response format');
          // Fall back to stored values
          await _loadData();
        }
      } else {
        print('API error: ${response.statusCode}');
        // Fall back to stored values
        await _loadData();
      }
    } catch (e) {
      print('Error fetching CMC data: $e');
      // Fall back to stored values
      await _loadData();
    }
  }

  Future<void> _checkDailyReward() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    lastCheckInDate = prefs.getString('last_check_in_date');

    setState(() {
      dailyCheckInClaimed = lastCheckInDate == today;
      isLoading = false;
    });

    if (!dailyCheckInClaimed) {
      setState(() {
        checkInMessage = 'Claim your daily 5 CMC bonus!';
      });
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load stored counts
    setState(() {
      tapCount = prefs.getInt('cmc_tap_count') ?? 0;
      pendingCmcToSync = prefs.getInt('pending_cmc_sync') ?? 0;
      totalCmcCollected = prefs.getInt('total_cmc_collected') ?? 0;
      lastCheckInDate = prefs.getString('last_check_in_date');

      // Check if daily reward is available
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      dailyCheckInClaimed = lastCheckInDate == today;

      isLoading = false;
    });

    // If daily reward not claimed yet today, show message
    if (!dailyCheckInClaimed) {
      setState(() {
        checkInMessage = 'Claim your daily 5 CMC bonus!';
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cmc_tap_count', tapCount);
    await prefs.setInt('pending_cmc_sync', pendingCmcToSync);
    await prefs.setInt('total_cmc_collected', totalCmcCollected);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    _confettiController.dispose();
    _saveData(); // Save data when leaving the screen
    super.dispose();
  }

  Future<void> _claimDailyBonus() async {
    if (dailyCheckInClaimed) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Record that daily bonus was claimed
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setString('last_check_in_date', today);

      // Add 5 CMC and show animation
      setState(() {
        tapCount += 5;
        totalCmcCollected += 5;
        dailyCheckInClaimed = true;
        checkInMessage = '';
        showReward = true;
      });

      // Send API request for daily bonus
      await _sendCmcToServer(5);
      print('Successfully sent daily 5 CMC to server');

      _confettiController.forward(from: 0.0);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showReward = false;
          });
        }
      });
    } catch (e) {
      print('Failed to claim daily bonus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to claim daily bonus: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendCmcToServer(int amount) async {
    try {
      // Get auth token from your auth provider or local storage
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharedPreferenceHelper.accessTokenKey) ?? '';

      print("check");
      print(token);

      final response = await http.post(
        Uri.parse(UrlContainer.baseUrl + UrlContainer.airDropEndPoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cmc': amount,
        }),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Success - update pending count
          setState(() {
            pendingCmcToSync -= amount;
          });
          await _saveData();
        } else {
          // API returned error
          throw Exception(data['message'] ?? 'Failed to sync CMC');
        }
      } else {
        // HTTP error
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // If API fails, we'll try again next time
      print('Error syncing CMC: $e');
      // Don't update pendingCmcToSync so we'll try again later
      rethrow;
    }
  }
  void _handleTap() {
    HapticFeedback.mediumImpact();

    setState(() {
      tapCount++;
      totalCmcCollected++;

      // Generate random particles
      _generateParticles();
      isAnimating = true;

      // Show reward animation at milestone taps (every 50 taps)
      if (tapCount % 50 == 0) {
        showReward = true;
        _confettiController.forward(from: 0.0);

        // Send 50 CMC to server
        _sendCmcToServer(50).then((_) {
          print('Successfully sent 50 CMC to server');
        }).catchError((e) {
          print('Failed to send CMC to server: $e');
          // Optionally show error to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sync CMC. Will retry next time.'),
              duration: Duration(seconds: 2),
            ),
          );
        });

        // Hide reward overlay after animation
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showReward = false;
            });
          }
        });
      }
    });

    // Play tap animations
    _pulseController.forward(from: 0.0);
    _bounceController.forward(from: 0.0);

    // Reset animation state
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          isAnimating = false;
        });
      }
    });
  }

  void _generateParticles() {
    // Clear old particles
    _particles.clear();

    // Generate new particles with theme-aware colors
    for (int i = 0; i < 20; i++) {
      bool isDarkTheme = Get.find<ThemeController>().darkTheme;

      // Choose colors based on theme
      final List<Color> darkThemeColors = [
        MyColor.primaryColor,
        MyColor.purpleAcccent.withOpacity(0.8),
        Colors.white,
        MyColor.highPriorityPurpleColor,
      ];

      final List<Color> lightThemeColors = [
        MyColor.lPrimaryColor,
        MyColor.purpleAcccent.withOpacity(0.8),
        MyColor.lTextColor,
        MyColor.titleColor,
      ];

      final List<Color> particleColors = isDarkTheme ? darkThemeColors : lightThemeColors;

      _particles.add(
        ParticleModel(
          position: Offset.zero,
          color: particleColors[_random.nextInt(particleColors.length)],
          size: _random.nextDouble() * 15 + 5,
          velocity: Offset(
            (_random.nextDouble() * 2 - 1) * 5,
            (_random.nextDouble() * 2 - 1) * 5,
          ),
          remainingLife: 1.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme
    final bool isDarkTheme = Get.find<ThemeController>().darkTheme;

    // Theme-aware colors
    final Color backgroundColor = isDarkTheme
        ? MyColor.backgroundColor
        : MyColor.lScreenBgColor;

    final Color cardBgColor = isDarkTheme
        ? MyColor.cardBgColor
        : MyColor.lScreenBgColor1;

    final Color primaryColor = isDarkTheme
        ? MyColor.primaryColor
        : MyColor.lPrimaryColor;

    final Color textColor = isDarkTheme
        ? MyColor.colorWhite
        : MyColor.lTextColor;

    final Color labelColor = isDarkTheme
        ? MyColor.labelTextColor
        : MyColor.lTextColor.withOpacity(0.7);

    final Color shadowColor = isDarkTheme
        ? primaryColor.withOpacity(0.3)
        : MyColor.titleColor.withOpacity(0.2);

    final Color progressBgColor = isDarkTheme
        ? MyColor.cardPrimaryColor
        : MyColor.textFieldDisableBorderColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor,
                  cardBgColor,
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.space15,
                    vertical: Dimensions.space20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: textColor,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _bounceController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + _bounceController.value * 0.2,
                            child: Text(
                              'CMC: $tapCount',
                              style: interBoldHeader1.copyWith(
                                color: primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                      isLoading
                          ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      )
                          : const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Check-in banner (only show if not claimed)
                if (!dailyCheckInClaimed && checkInMessage.isNotEmpty)
                  GestureDetector(
                    onTap: _claimDailyBonus,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                      padding: const EdgeInsets.all(Dimensions.space10),
                      decoration: BoxDecoration(
                        color: isDarkTheme
                            ? primaryColor.withOpacity(0.2)
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            color: primaryColor,
                          ),
                          const SizedBox(width: Dimensions.space10),
                          Expanded(
                            child: Text(
                              checkInMessage,
                              style: interSemiBoldDefault.copyWith(
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Text(
                            'Claim Now',
                            style: interBoldDefault.copyWith(
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: Dimensions.space20),

                // Main content - Tap area
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Instructions text
                        Text(
                          'Tap repeatedly to collect CMC!',
                          style: interSemiBoldLarge.copyWith(
                            color: labelColor,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: Dimensions.space10),

                        // Total collected
                        Text(
                          'Total collected: $totalCmcCollected',
                          style: interRegularDefault.copyWith(
                            color: labelColor,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: Dimensions.space30),

                        // Tap area with animations - Always on top and accessible
                        GestureDetector(
                          onTap: _handleTap,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Particle effects on tap
                              if (isAnimating)
                                CustomPaint(
                                  painter: ParticlePainter(_particles),
                                  size: const Size(200, 200),
                                ),

                              // Rotating background circle
                              AnimatedBuilder(
                                animation: _rotationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotationController.value * 2 * math.pi,
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: [
                                            primaryColor.withOpacity(0.5),
                                            (isDarkTheme
                                                ? MyColor.purpleAcccent
                                                : MyColor.naturalLight).withOpacity(0.3),
                                            primaryColor.withOpacity(0.5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Pulsing effect on tap
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cardBgColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.5 + _pulseController.value * 0.5),
                                          blurRadius: 20 + _pulseController.value * 30,
                                          spreadRadius: 5 + _pulseController.value * 15,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // Main tap circle
                              AnimatedBuilder(
                                animation: _scaleController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scaleController.value,
                                    child: // This is the modified section of the AirdropScreen where the CMC coin size is increased
// Replace the existing code with this section when you find the coin image in the main tap circle area

// Find this part in your existing code (around line 600-620):
                                      Container(
                                        width: 160,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              primaryColor,
                                              isDarkTheme
                                                  ? MyColor.cardPrimaryColor
                                                  : MyColor.lTextColor.withOpacity(0.4),
                                            ],
                                            radius: 0.8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: shadowColor,
                                              blurRadius: 15,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Replace this Image widget with the one below:
                                              Image.asset(
                                                'assets/images/cmc_coin.png',
                                                width: 100, // Increased from 60 to 100
                                                height: 100, // Increased from 60 to 100
                                                fit: BoxFit.contain, // Added to ensure proper scaling
                                              ),
                                              // Reduced the spacing to accommodate larger image
                                              const SizedBox(height: Dimensions.space5),
                                              Text(
                                                'TAP!',
                                                style: interBoldLarge.copyWith(
                                                  color: isDarkTheme
                                                      ? Colors.white
                                                      : Colors.white,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: Dimensions.space40),

                        // Progress indicator
                        // In the progress indicator widget, replace with:
                        SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                                child: LinearProgressIndicator(
                                  value: (tapCount % 50) / 50,
                                  backgroundColor: progressBgColor,
                                  color: primaryColor,
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: Dimensions.space10),
                              Text(
                                'Next reward: ${50 - (tapCount % 50)} taps',
                                style: interRegularDefault.copyWith(
                                  color: labelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confetti animation overlay - Does not block taps
          if (showReward)
            Positioned.fill(
              child: IgnorePointer(
                // Important: This makes the confetti layer ignore touch events
                // so users can continue tapping through the animation
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ConfettiPainter(
                        _confettiController.value,
                        colors: isDarkTheme
                            ? [
                          MyColor.primaryColor,
                          MyColor.purpleAcccent,
                          Colors.white,
                          MyColor.greenSuccessColor,
                        ]
                            : [
                          MyColor.lPrimaryColor,
                          MyColor.naturalLight,
                          MyColor.titleColor,
                          MyColor.greenP,
                        ],
                      ),
                      size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                    );
                  },
                ),
              ),
            ),

          // Reward message - Positioned to not interfere with tapping
          if (showReward)
            Positioned(
              top: 100, // Position at top so it doesn't block the main tap area
              left: 0,
              right: 0,
              child: IgnorePointer( // Ignore pointer so taps go through to the button
                child: AnimatedOpacity(
                  opacity: showReward ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.space20),
                      decoration: BoxDecoration(
                        color: isDarkTheme
                            ? MyColor.cardBgColor.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.celebration,
                            size: 50,
                            color: primaryColor,
                          ),
                          const SizedBox(height: Dimensions.space10),
                          Text(
                            dailyCheckInClaimed ? 'CMC Milestone!' : 'Daily Bonus!',
                            style: interBoldHeader1.copyWith(
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: Dimensions.space5),
                          Text(
                            dailyCheckInClaimed
                                ? 'You reached ${tapCount} CMC!'
                                : 'You claimed 5 CMC daily bonus!',
                            style: interRegularLarge.copyWith(
                              color: labelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Particle model for tap effects
class ParticleModel {
  Offset position;
  Color color;
  double size;
  Offset velocity;
  double remainingLife;

  ParticleModel({
    required this.position,
    required this.color,
    required this.size,
    required this.velocity,
    required this.remainingLife,
  });
}

// Particle painter for tap effects
class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.remainingLife)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size * particle.remainingLife,
        paint,
      );

      // Update particle position
      particle.position += particle.velocity;
      // Decrease particle life
      particle.remainingLife -= 0.02;
    }

    // Remove dead particles
    particles.removeWhere((particle) => particle.remainingLife <= 0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Confetti painter for reward animation
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final Random random = Random();

  ConfettiPainter(this.progress, {required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final count = 100;

    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (0.2 + 0.8 * progress * random.nextDouble());
      final particleSize = 5.0 + random.nextDouble() * 10;
      final opacity = 1.0 - (progress * random.nextDouble());

      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = colors[random.nextInt(colors.length)].withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final shapeType = random.nextInt(3);

      switch (shapeType) {
        case 0: // Circle
          canvas.drawCircle(Offset(x, y), particleSize, paint);
          break;
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: particleSize, height: particleSize),
            paint,
          );
          break;
        case 2: // Triangle
          final path = Path();
          path.moveTo(x, y - particleSize);
          path.lineTo(x + particleSize, y + particleSize);
          path.lineTo(x - particleSize, y + particleSize);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}