import 'dart:math';
import 'package:flutter/material.dart';

import '../utils/toast.dart';

class MissionListScreen extends StatelessWidget {
  final String programName;
  final bool fromProgramCard; // true nếu từ _buildProgramCard

  const MissionListScreen({
    super.key,
    required this.programName,
    required this.fromProgramCard,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fakeMissions = List.generate(7, (index) {
      return {
        "day": index + 1,
        "usage": "${Random().nextInt(60) + 30}m ↑",
        "poorRate": "${Random().nextInt(40) + 10}% ↓",
        "exercise": index % 2 == 0 ? "Head Tilts" : "Head Nods",
        "sets": "${Random().nextInt(2) + 1} sets",
        "achieved": Random().nextBool(),
      };
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(programName),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: fakeMissions.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final item = fakeMissions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Day ${item["day"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!fromProgramCard) _buildInfo("Usage", item["usage"]),
                          if (!fromProgramCard) _buildInfo("Poor rate", item["poorRate"]),
                          _buildInfo("Exercise", "${item["exercise"]} (${item["sets"]})"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!fromProgramCard)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            item["achieved"] ? Icons.check_circle : Icons.cancel,
                            color: item["achieved"] ? Colors.teal : Colors.redAccent,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (fromProgramCard)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  openToast("Program \"$programName\" selected!");
                  Navigator.pop(context);
                },
                child: const Text("Choose", style: TextStyle(fontSize: 16)),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
