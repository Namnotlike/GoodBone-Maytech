import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PostureReportScreen extends StatelessWidget {
  PostureReportScreen({super.key}) {
    _generateData();
  }

  final List<String> _hours = List.generate(
    10,
        (i) => "${DateTime.now().subtract(Duration(hours: 9 - i + 1)).hour}h",
  );

  final List<Map<String, double>> _data = [];

  final List<Color> colors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.red,
  ];

  final List<String> status = [
    "EXCELLENT",
    "GOOD",
    "WARNING",
    "BAD",
  ];

  void _generateData() {
    final random = Random();
    for (int i = 0; i < 10; i++) {
      double e = random.nextInt(15) + 0.0;
      double g = random.nextInt(17) + 0.0;
      double w = random.nextInt(15) + 0.0;
      double b = random.nextInt(13) + 0.0;
      double x = 60 - e - g- w - b;
      if (x > 0){
        e = e + x / 4;
        g = g + x / 4;
        w = w + x / 4;
        b = b + x / 4;
      }

      _data.add({
        "EXCELLENT": e,
        "GOOD": g,
        "WARNING": w,
        "BAD": b,
      });
    }
  }

  Map<String, double> _calculateTotals() {
    final total = {"EXCELLENT": 0.0, "GOOD": 0.0, "WARNING": 0.0, "BAD": 0.0};
    for (var d in _data) {
      for (var key in total.keys) {
        total[key] = total[key]! + (d[key] ?? 0.0);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();
    final totalUsage = totals.values.reduce((a, b) => a + b);
    final goodPosture = totals["EXCELLENT"]! + totals["GOOD"]!;
    final badPosture = totals["WARNING"]! + totals["BAD"]!;
    final postureToday = totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Posture Records"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Posture per Hour", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: List.generate(_data.length, (i) {
                    double bottom = 0;
                    final rods = <BarChartRodStackItem>[];

                    for (int j = 0; j < status.length; j++) {
                      final value = _data[i][status[j]]!.toDouble();
                      rods.add(
                        BarChartRodStackItem(bottom, bottom + value, colors[j]),
                      );
                      bottom += value;
                    }

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: 60, // tổng cộng luôn là 60
                          rodStackItems: rods,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        reservedSize: 28,
                        getTitlesWidget: (value, _) => Text("${value.toInt()}m", style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_hours[value.toInt()], style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) {
                return Row(
                  children: [
                    Container(width: 10, height: 10, color: colors[i]),
                    const SizedBox(width: 4),
                    Text(status[i], style: const TextStyle(fontSize: 12)),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _InfoRow(label: "Your posture today", value: postureToday),
                  _InfoRow(label: "Total usage", value: "${(totalUsage ~/ 60)}h ${totalUsage % 60}m"),
                  _InfoRow(
                    label: "Total bad posture",
                    value: "${(badPosture ~/ 60)}h ${badPosture % 60}m",
                    square1Color: Colors.red,
                    square2Color: Colors.orange,
                  ),
                  _InfoRow(
                    label: "Total good posture",
                    value: "${(goodPosture ~/ 60)}h ${goodPosture % 60}m",
                    square1Color: Colors.blue,
                    square2Color: Colors.green,
                  ),
                  _InfoRow(label: "Bad posture ratio", value: "${((badPosture / totalUsage) * 100).toStringAsFixed(1)}%"),
                  _InfoRow(label: "Time in good posture", value: "${goodPosture}m"),
                  _InfoRow(label: "Number of notifications", value: "${badPosture * 2} times"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? square1Color;
  final Color? square2Color;

  const _InfoRow({
    required this.label,
    required this.value,
    this.square1Color,
    this.square2Color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(label),
              if (square1Color != null) ...[
                const SizedBox(width: 6),
                _colorBox(square1Color!),
              ],
              if (square2Color != null) ...[
                const SizedBox(width: 4),
                _colorBox(square2Color!),
              ]
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.teal)),
        ],
      ),
    );
  }

  Widget _colorBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
