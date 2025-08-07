import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/SensorData.dart';
import '../services/db_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  List<SensorData> _sensorData = [];
  DateTime filterDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (kIsWeb) {
      final now = DateTime.now();
      final random = Random();

      final fakeData = List.generate(50, (i) {
        final timestamp = now.subtract(Duration(hours: random.nextInt(240)));
        return SensorData(
          id: i,
          timestamp: timestamp,
          neck: random.nextInt(30) - 15,
          leftShoulder: random.nextInt(30) - 15,
          rightShoulder: random.nextInt(30) - 15,
          upperBack: random.nextInt(30) - 15,
          midBack: random.nextInt(30) - 15,
          lowerBack: random.nextInt(30) - 15,
          leftHip: random.nextInt(30) - 15,
          rightHip: random.nextInt(30) - 15,
          postureClass: ['Good', 'Slouched', 'Leaning'][random.nextInt(3)],
        );
      });

      setState(() {
        _sensorData = fakeData;
      });
    } else {
      final data = await DBService().getAllSensorData();
      setState(() {
        _sensorData = data;
      });
    }
  }


  List<SensorData> get _filteredData {
    return _sensorData.where((data) {
      final d = data.timestamp;
      return d.isBefore(filterDate.add(const Duration(days: 1))) &&
          d.isAfter(filterDate.subtract(const Duration(days: 10)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final avgPerDay = _aggregateAverageByDay();
    final postureCount = _countPostureClass();
    final usageTime = _generateRandomUsage();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Report"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: filterDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  filterDate = picked;
                });
              }
            },
          )
        ],
      ),
      body: _sensorData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          const Text("Average Deviation per Day", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                barGroups: avgPerDay.entries.take(10).toList().asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        color: Colors.blue,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < avgPerDay.length) {
                          return Text(
                            DateFormat.Md().format(avgPerDay.entries.toList()[index].key),
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
                alignment: BarChartAlignment.spaceAround,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Posture Class Distribution", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: postureCount.entries.map((e) {
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    title: "${e.key}\n(${e.value})",
                    color: _randomColor(),
                    radius: 120,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text("Daily Usage Time", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: usageTime.entries.toList().asMap().entries.map((e) =>
                        FlSpot(e.key.toDouble(), e.value.value.inMinutes.toDouble())
                    ).toList(),
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    color: Colors.teal,
                    belowBarData: BarAreaData(show: false),
                  )
                ],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int i = value.toInt();
                        if (i < usageTime.length) {
                          return Text(DateFormat.Md().format(usageTime.entries.toList()[i].key), style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, double> _aggregateAverageByDay() {
    final map = <DateTime, List<int>>{};
    for (var item in _filteredData) {
      final date = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      final avg = [
        item.neck,
        item.leftShoulder,
        item.rightShoulder,
        item.upperBack,
        item.midBack,
        item.lowerBack,
        item.leftHip,
        item.rightHip,
      ].map((e) => e.abs()).reduce((a, b) => a + b) ~/ 8;
      map.putIfAbsent(date, () => []).add(avg);
    }

    return map.map((k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length));
  }

  Map<String, int> _countPostureClass() {
    final map = <String, int>{};
    for (var item in _filteredData) {
      map[item.postureClass] = (map[item.postureClass] ?? 0) + 1;
    }
    return map;
  }

  Map<DateTime, Duration> _generateRandomUsage() {
    final now = DateTime.now();
    return Map.fromIterable(
      List.generate(10, (i) => now.subtract(Duration(days: i))),
      key: (e) => e,
      value: (_) => Duration(minutes: 30 + Random().nextInt(60)),
    );
  }

  Color _randomColor() {
    final r = Random();
    return Color.fromRGBO(r.nextInt(256), r.nextInt(256), r.nextInt(256), 1);
  }
}
