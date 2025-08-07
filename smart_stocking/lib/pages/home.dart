import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:wordpress_app/blocs/category_bloc.dart';
import 'package:wordpress_app/blocs/config_bloc.dart';
import 'package:wordpress_app/blocs/notification_bloc.dart';
import 'package:wordpress_app/blocs/settings_bloc.dart';
import 'package:wordpress_app/blocs/user_bloc.dart';
import 'package:wordpress_app/blue-plus/screens/scan_screen.dart';
import 'package:wordpress_app/services/app_links_service.dart';
import 'package:wordpress_app/services/notification_service.dart';
import 'package:wordpress_app/tabs/home_tab.dart';
import 'package:wordpress_app/tabs/profile_tab.dart';
import 'package:wordpress_app/tabs/remote_tab.dart';
import 'package:wordpress_app/tabs/video_tab.dart';
import '../blocs/featured_bloc.dart';
import '../blocs/latest_articles_bloc.dart';
import '../blocs/popular_articles_bloc.dart';
import '../tabs/bookmark_tab.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  PageController? _pageController;

  final List<IconData> _iconList = [
    // Feather.home,
    Icons.control_camera,
    // Feather.heart,
    Feather.user
  ];

  final List<IconData> _iconListWithVideoTab = [
    Icons.control_camera,
    Icons.newspaper,
    Feather.heart,
    Feather.user
  ];

  final List<Widget> _tabs = [
    // ScanScreen(),
    const RemoteTab(),
    // const BookmarkTab(),
    const SettingPage(),
  ];

  // final List<Widget> _tabsAndroid = [
  //   const RemoteTab(),
  //   // HomeTab(
  //   //         configs: cb.configs!,
  //   //         homeCategories: cb.homeCategories,
  //   //         categoryTabs: _categoryTabs(cb),
  //   //       ),
  //   const BookmarkTab(),
  //   const SettingPage()
  // ];

  void _initData() async {
    final cb = context.read<CategoryBloc>();
    final nb = context.read<NotificationBloc>();
    final ub = context.read<UserBloc>();
    final sb = context.read<SettingsBloc>();
    final configs = context.read<ConfigBloc>().configs!;

    NotificationService()
        .initFirebasePushNotification(context)
        .then((_) => nb.checkSubscription());
    await AppLinksService().initUniLinks(context);
    cb.fetchData(configs.blockedCategories);
    sb.getPackageInfo();

    if (!ub.guestUser) {
      ub.getUserData();
    }
  }

  _fetchPostsData() async {
    Future.microtask(() {
      final configs = context.read<ConfigBloc>().configs!;
      if (configs.featuredPostEnabled) {
        context.read<FeaturedBloc>().fetchData();
      }
      if (configs.popularPostEnabled) {
        context.read<PopularArticlesBloc>().fetchData();
      }
      context.read<LatestArticlesBloc>().fetchData(configs.blockedCategories);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initData();
    _fetchPostsData();
    // onItemTapped(1);
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController!.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  Future _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      _pageController!.animateToPage(_selectedIndex,
          duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    } else {
      await SystemChannels.platform
          .invokeMethod<void>('SystemNavigator.pop', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cb = context.read<ConfigBloc>();
    return WillPopScope(
      onWillPop: () async => await _onWillPop(),
      child: UpgradeAlert(
        // upgrader: Upgrader(dialogStyle: UpgradeDialogStyle.cupertino),
        child: Scaffold(
          bottomNavigationBar: _bottonNavigationBar(context, cb),
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            allowImplicitScrolling: false,
            controller: _pageController,
            children: <Widget>[
              if (!kIsWeb) ...[
                const RemoteTab(),
                HomeTab(
                  configs: cb.configs!,
                  homeCategories: cb.homeCategories,
                  categoryTabs: _categoryTabs(cb),
                ),
                const BookmarkTab(),
                const SettingPage()
              ] else
                ..._tabs
            ],
          ),
        ),
      ),
    );
  }

  // List<Widget> _childrens(ConfigBloc cb) {
  //   if (Platform.isAndroid) {
  //     return _tabsAndroid;
  //   } else {
  //     return _tabs;
  //   }
  // }

  List<Tab> _categoryTabs(ConfigBloc cb) {
    return cb.homeCategories.map((e) => Tab(text: e.name)).toList()
      ..insert(0, Tab(text: 'explore'.tr()));
  }

  AnimatedBottomNavigationBar _bottonNavigationBar(
      BuildContext context, ConfigBloc cb) {
    return AnimatedBottomNavigationBar(
      icons: !kIsWeb ? _iconListWithVideoTab : _iconList,
      gapLocation: GapLocation.none,
      activeIndex: _selectedIndex,
      iconSize: 22,
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      activeColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      inactiveColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      splashColor: Theme.of(context).primaryColor,
      onTap: (index) => onItemTapped(index),
    );
  }
}
