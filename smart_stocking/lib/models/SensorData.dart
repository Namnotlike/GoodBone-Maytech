import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../services/db_service.dart';

class SensorData {
  final int? id;
  final DateTime timestamp;
  final int neck;
  final int leftShoulder;
  final int rightShoulder;
  final int upperBack;
  final int midBack;
  final int lowerBack;
  final int leftHip;
  final int rightHip;
  final String postureClass;

  SensorData({
    this.id,
    required this.timestamp,
    required this.neck,
    required this.leftShoulder,
    required this.rightShoulder,
    required this.upperBack,
    required this.midBack,
    required this.lowerBack,
    required this.leftHip,
    required this.rightHip,
    required this.postureClass,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'neck': neck,
    'leftShoulder': leftShoulder,
    'rightShoulder': rightShoulder,
    'upperBack': upperBack,
    'midBack': midBack,
    'lowerBack': lowerBack,
    'leftHip': leftHip,
    'rightHip': rightHip,
    'postureClass': postureClass,
  };

  factory SensorData.fromMap(Map<String, dynamic> map) => SensorData(
    id: map['id'],
    timestamp: DateTime.parse(map['timestamp']),
    neck: map['neck'],
    leftShoulder: map['leftShoulder'],
    rightShoulder: map['rightShoulder'],
    upperBack: map['upperBack'],
    midBack: map['midBack'],
    lowerBack: map['lowerBack'],
    leftHip: map['leftHip'],
    rightHip: map['rightHip'],
    postureClass: map['postureClass'],
  );

  static SensorData generateRandomSensorData() {
    final rand = Random();
    int randomInRange() => rand.nextInt(21) - 10; // -10 → 10

    // Optional: random posture label
    final postureLabels = [
      'C1','C2','C3','C4','C5','C6',
      'C7','C8','C9','C10','C11','C12'
    ];
    final posture = postureLabels[rand.nextInt(postureLabels.length)];

    return SensorData(
      timestamp: DateTime.now(),
      neck: randomInRange(),
      leftShoulder: randomInRange(),
      rightShoulder: randomInRange(),
      upperBack: randomInRange(),
      midBack: randomInRange(),
      lowerBack: randomInRange(),
      leftHip: randomInRange(),
      rightHip: randomInRange(),
      postureClass: posture,
    );
  }

  static Timer? _sensorTimer;

  static void startSensorDataSimulation() {
    _sensorTimer?.cancel(); // đảm bảo không bị nhân đôi

    _sensorTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      final newData = generateRandomSensorData();
      if(!kIsWeb) {
        await DBService().insertSensorData(newData);
        print('✅ Inserted random data at ${newData.timestamp}');
      }
    });
  }

  void stopSensorSimulation() {
    _sensorTimer?.cancel();
  }

}
