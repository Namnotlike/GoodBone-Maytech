 import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../config/config.dart';
import 'CoachingProgramScreen.dart';
import 'MonthlyReportScreen.dart';
import 'PostureReportScreen.dart';

class PostureDashboardScreen extends StatefulWidget {
  const PostureDashboardScreen({super.key});

  @override
  State<PostureDashboardScreen> createState() => _PostureDashboardScreenState();
}

class _PostureDashboardScreenState extends State<PostureDashboardScreen> {
  int poorPosturePercent = 10;
  String postureStatus = "EXCELLENT";
  Duration usageTime = const Duration(hours: 5, minutes: 24);
  int notificationCount = 5;
  final _audioPlayer = AudioPlayer();
  bool isAlertShown = false;
  bool isAlerting = false;
  bool enableVibration = true;


  int batteryLevel = 50;
  bool hasShownBatteryAlert = false;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {
        poorPosturePercent = Random().nextInt(100);
        postureStatus = poorPosturePercent > 60
            ? "BAD"
            : poorPosturePercent > 30
            ? "WARNING"
            : poorPosturePercent > 10
            ? "GOOD"
            : "EXCELLENT";
      });

      if ((postureStatus == "BAD" || postureStatus == "WARNING") && !isAlerting && enableVibration) {
        _startAlert();
      } else if (postureStatus != "BAD" && postureStatus != "WARNING" && isAlerting && enableVibration) {
        _stopAlert();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    });

    Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        batteryLevel = max(1, batteryLevel - Random().nextInt(5));

        if (batteryLevel < 20 && !hasShownBatteryAlert) {
          hasShownBatteryAlert = true;
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Low Battery"),
                content: const Text("Device battery is below 20%. Please charge soon."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  )
                ],
              ),
            );
          }
        } else if (batteryLevel >= 20) {
          hasShownBatteryAlert = false;
        }
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Dashboard"),
            _buildBatteryWidget(), // Gắn pin tại đây
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const SizedBox(height: 5),
          Center(
            child: Text("Today", style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 10),
          _buildCircularPostureGauge(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconLabel(
                icon: Icons.access_time,
                label: "Total usage",
                value: _formatDuration(usageTime),
              ),
              _buildIconLabel(
                icon: Icons.notifications,
                label: "Notifications",
                value: "$notificationCount times",
              ),
            ],
          ),
          const SizedBox(height: 0),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;

                // Giữ nguyên 2 cột
                int crossAxisCount = 2;

                // Tăng aspect ratio để làm card "lùn" lại
                double aspectRatio = screenWidth > 600 ? 2.2 : 1.2;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  shrinkWrap: true,
                  children: [
                    _buildCard(
                      icon: Icons.fitness_center,
                      label: "Coaching Program",
                      subtitle: "Check improvement rate",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CoachingProgramScreen()),
                        );
                      },
                    ),
                    _buildCard(
                      icon: Icons.bar_chart,
                      label: "Monthly Report",
                      subtitle: "Check Now >",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: Colors.blue,
      //   unselectedItemColor: Colors.grey,
      //   currentIndex: 0,
      //   onTap: (index) {},
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
      //     BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Program"),
      //     BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
      //   ],
      // ),
    );
  }

  Widget _buildCircularPostureGauge() {
    Color gaugeColor;
    switch (postureStatus) {
      case "BAD":
        gaugeColor = Colors.red;
        break;
      case "GOOD":
        gaugeColor = Colors.blue;
        break;
      case "WARNING" :
        gaugeColor = Colors.orange;
        break;
      default:
        gaugeColor = Colors.green;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, 280.0);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PostureReportScreen()),
            );
          },
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: poorPosturePercent / 100,
                    strokeWidth: 18,
                    backgroundColor: Colors.grey[300],
                    color: gaugeColor,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Your posture today?"),
                    Text(
                      postureStatus,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: gaugeColor,
                      ),
                    ),
                    Text("Poor posture $poorPosturePercent%"),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Vibration Alert : ", style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 10),
                          Switch(
                            value: enableVibration,
                            onChanged: (value) async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(value ? "Enable Vibration Alert?" : "Disable Vibration Alert?"),
                                  content: Text(
                                    value
                                        ? "When enabled, the device will vibrate when bad posture is detected."
                                        : "Disabling this will stop vibration alerts even when posture is bad.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );

                              if (result == true) {
                                setState(() {
                                  enableVibration = value;
                                });
                              }
                            },
                            activeColor: Colors.teal,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconLabel({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.blueAccent),
        const SizedBox(height: 8),
        Text(label),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 10,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.teal),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return "${hours}h ${minutes}m";
  }

  void _startAlert() async {
    isAlerting = true;

    // Rung liên tục
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
    }

    // Phát âm thanh
    //_audioPlayer.play(AssetSource(Config.warningSound));

    // Hiển thị dialog nếu chưa hiển thị
    if (!isAlertShown) {
      isAlertShown = true;
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Bad Posture warning"),
          content: Text("You are sitting in the wrong position!\n${_getRandomWrongPosition()}\nPlease adjust."),
          actions: [
            TextButton(
              onPressed: () {
                _stopAlert();
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }


  final List<String> wrongPositions = [
    "Slouching forward while sitting.",
    "Leaning too far back.",
    "Head looking downward too much.",
    "Sliding down the chair.",
    "Twisting your spine.",
    "Uneven shoulders detected.",
    "Sitting at the edge of the seat.",
    "No back support while sitting.",
    "Incorrect arm positioning.",
    "Poor neck alignment.",
  ];

  String _getRandomWrongPosition() {
    final random = Random();
    return wrongPositions[random.nextInt(wrongPositions.length)];
  }

  void _stopAlert() {
    isAlerting = false;
    isAlertShown = false;
    Vibration.cancel();
    _audioPlayer.stop();
  }

  Widget _buildBatteryWidget() {
    final batteryColor = batteryLevel < 20 ? Colors.red : Colors.green;
    return Row(
      children: [
        Icon(Icons.battery_full, color: batteryColor),
        const SizedBox(width: 4),
        Text(
          "$batteryLevel%",
          style: TextStyle(color: batteryColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

}
