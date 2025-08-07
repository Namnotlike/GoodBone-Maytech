import 'package:flutter/material.dart';

import '../models/app_config_model.dart';
import '../models/category.dart';
import '../services/wordpress_service.dart';

class ConfigBloc extends ChangeNotifier {
  late ConfigModel? _configs;
  ConfigModel? get configs => _configs;

  late List<Category> _homeCategories = [];
  List<Category> get homeCategories => _homeCategories;

  Future<bool> getConfigsData() async {
    bool hasData = true;
    _configs = ConfigModel(
        homeCategories: [1],
        supportEmail: "Info@goodbone.com",
        priivacyPolicyUrl: "https://goodbonesmedical.com/privacy-policy/",
        fbUrl: "",
        youtubeUrl: "",
        instagramUrl: "",
        twitterUrl: "",
        blockedCategories: [],
        menubarEnabled: false,
        logoPositionCenter: false,
        popularPostEnabled: true,
        featuredPostEnabled: true,
        welcomeScreenEnabled: false,
        commentsEnabled: false,
        loginEnabled: false,
        multiLanguageEnabled: false,
        customAdsEnabled: false,
        customAdAssetUrl: "",
        customAdDestinationUrl: "",
        customAdPlacements: [],
        postIntervalCount: 0,
        admobEnabled: false,
        bannerAdsEnabled: false,
        interstitialAdsEnabled: false,
        clickAmount: 3,
        postDetailsLayout: "",
        nativeAdsEnabled: false,
        nativeAdPlacements: [],
        onBoardingEnbaled: false,
        socialEmbedPostsEnabled: false,
        videoTabEnabled: false,
        socialLoginsEnabled: false,
        threadsUrl: "",
        fbLoginEnabled: false);
    var newConfigs = await WordPressService().getConfigsFromAPI();
    if (newConfigs != null) {
      // _configs = newConfigs;
      hasData = true;
    }
    notifyListeners();
    return hasData;
  }
}
