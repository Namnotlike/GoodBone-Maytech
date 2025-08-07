import 'dart:async';
import 'dart:math';

import '../sqllite/database_helper.dart';

class SensorService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Random _random = Random();
  late Timer _timer;

  Map<String, int> sensorValues = {
    "neck": 0,
    "upperBack": 0,
    "midBack": 0,
    "lowerBack": 0,
    "leftShoulder": 0,
    "rightShoulder": 0,
    "leftHip": 0,
    "rightHip": 0,
  };

  void startSensorUpdates() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      _updateSensorValues();
      await _dbHelper.insertSensorData(sensorValues);
    });
  }

  void stopSensorUpdates() {
    _timer.cancel();
  }

  void _updateSensorValues() {
    sensorValues.updateAll((key, value) => _random.nextInt(21) - 10);
  }
}
