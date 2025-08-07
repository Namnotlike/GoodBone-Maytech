import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wordpress_app/config/language_config.dart';
import 'package:wordpress_app/main-blue.dart';
import 'package:wordpress_app/services/app_service.dart';
import 'app.dart';
import 'constants/constant.dart';
import 'models/SensorData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // await Firebase.initializeApp();

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    Directory directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
  }
  await Hive.openBox(Constants.bookmarkTag);
  await Hive.openBox(Constants.resentSearchTag);
  await Hive.openBox(Constants.notificationTag);
  LanguageConfig.setLocaleMessagesForTimeAgo();
  AppService.setDisplayToHighRefreshRate();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  if(!kIsWeb) {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  }
  SensorData.startSensorDataSimulation();
  // FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(EasyLocalization(
    supportedLocales: LanguageConfig.supportedLocales,
    path: 'assets/translations',
    fallbackLocale: LanguageConfig.fallbackLocale,
    startLocale: LanguageConfig.startLocale,
    // child: FlutterBlueApp(),
    child: const FlutterApp(),
  ));
}
