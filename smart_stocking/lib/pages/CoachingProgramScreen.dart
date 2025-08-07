import 'dart:math';
import 'package:flutter/material.dart';

import 'MissionListScreen.dart';

class CoachingProgramScreen extends StatelessWidget {
  const CoachingProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fake data
    final String habit = "Make a good neck posture habit";
    final String progressText = "In progress: Day ${Random().nextInt(7) + 1}";
    final int usageMin = Random().nextInt(60) + 1;
    final int poorRate = Random().nextInt(50);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Coaching program"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MissionListScreen(programName: habit, fromProgramCard: false,),
                  ),
                );
              },
              child: _buildActiveMissionCard(habit, progressText),
            ),
            const SizedBox(height: 16),
            _buildTodayMissionCard(usageMin, poorRate),
            const SizedBox(height: 16),
            const Text(
              "Coaching program",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              "Keep completing the missions to form and maintain good posture habits.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MissionListScreen(
                            programName: "Make a good neck posture habit",
                            fromProgramCard: true,),
                        ),
                      );
                    },
                    child: _buildProgramCard("21d", "Easy",
                        "Make a good\nneck posture habit", Icons.accessibility),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MissionListScreen(
                            programName: "Maintain good posture habit",
                            fromProgramCard: true,),
                        ),
                      );
                    },
                    child: _buildProgramCard("5d", "Hard",
                        "Maintain good\nposture habit", Icons.chair),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMissionCard(String habit, String progress) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.accessibility, size: 36, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(habit, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.close, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.3,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
            ),
            const SizedBox(height: 8),
            Text(progress, style: const TextStyle(color: Colors.teal)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMissionCard(int usageMin, int poorRate) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Today's mission", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Mission result", style: TextStyle(color: Colors.teal)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 36, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• Usage   ${usageMin}m"),
                      Text("• Poor rate   ${poorRate}%"),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: Colors.teal, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(String duration, String difficulty, String title, IconData icon) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(duration, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: difficulty == "Easy" ? Colors.green[100] : Colors.red[100],
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      color: difficulty == "Easy" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Icon(icon, size: 36, color: Colors.teal),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
