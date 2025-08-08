import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:wordpress_app/blocs/comment_bloc.dart';
import 'package:wordpress_app/blocs/config_bloc.dart';
import 'package:wordpress_app/blue-plus/screens/bluetooth_off_screen.dart';
import 'blocs/category_bloc.dart';
import 'blocs/featured_bloc.dart';
import 'blocs/latest_articles_bloc.dart';
import 'blocs/notification_bloc.dart';
import 'blocs/popular_articles_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'blocs/user_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'models/theme.dart';
import 'pages/splash.dart';
import 'widgets/web_max_width_wrapper.dart';

// final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
// final FirebaseAnalyticsObserver firebaseObserver =
//     FirebaseAnalyticsObserver(analytics: firebaseAnalytics);
final BluetoothAdapterStateObserver bluetoothAdapterStateObserver =
    BluetoothAdapterStateObserver();

class FlutterApp extends StatefulWidget {
  const FlutterApp({Key? key}) : super(key: key);

  @override
  State<FlutterApp> createState() => _FlutterAppState();
}

class _FlutterAppState extends State<FlutterApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    if(!kIsWeb) {
      _adapterStateStateSubscription =
          FlutterBluePlus.adapterState.listen((state) {
            _adapterState = state;
            setState(() {});
          });
    }
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const SplashPage()
        : kIsWeb ? const SplashPage() : BluetoothOffScreen(adapterState: _adapterState);
    return ChangeNotifierProvider<ThemeBloc>(
      create: (_) => ThemeBloc(),
      child: Consumer<ThemeBloc>(
        builder: (_, mode, child) {
          return MultiProvider(
              providers: [
                ChangeNotifierProvider<SettingsBloc>(
                    create: (context) => SettingsBloc()),
                ChangeNotifierProvider<CategoryBloc>(
                    create: (context) => CategoryBloc()),
                ChangeNotifierProvider<FeaturedBloc>(
                    create: (context) => FeaturedBloc()),
                ChangeNotifierProvider<LatestArticlesBloc>(
                    create: (context) => LatestArticlesBloc()),
                ChangeNotifierProvider<UserBloc>(
                    create: (context) => UserBloc()),
                ChangeNotifierProvider<NotificationBloc>(
                    create: (context) => NotificationBloc()),
                ChangeNotifierProvider<PopularArticlesBloc>(
                    create: (context) => PopularArticlesBloc()),
                ChangeNotifierProvider<CommentsBloc>(
                    create: (context) => CommentsBloc()),
                ChangeNotifierProvider<ConfigBloc>(
                    create: (context) => ConfigBloc()),
              ],
              child: MaterialApp(
                  builder: (context, child) {
                    return WebMaxWidthWrapper(child: child!);
                  },
                  debugShowCheckedModeBanner: false,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  navigatorObservers: [
                    // firebaseObserver,
                    bluetoothAdapterStateObserver
                  ],
                  locale: context.locale,
                  theme: ThemeModel().lightTheme,
                  darkTheme: ThemeModel().darkTheme,
                  themeMode:
                      mode.darkTheme == true ? ThemeMode.dark : ThemeMode.light,
                  home: screen));
        },
      ),
    );
  }
}

class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      if(!kIsWeb) {
        _adapterStateSubscription ??=
            FlutterBluePlus.adapterState.listen((state) {
              if (state != BluetoothAdapterState.on) {
                // Pop the current route if Bluetooth is off
                navigator?.pop();
              }
            });
      }
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
