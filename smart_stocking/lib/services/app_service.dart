// ignore: avoid_web_libraries_in_flutter
import 'dart:io' show InternetAddress, Platform, SocketException;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:hive/hive.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:jiffy/jiffy.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:reading_time/reading_time.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordpress_app/blocs/settings_bloc.dart';
import 'package:wordpress_app/blocs/theme_bloc.dart';
import 'package:wordpress_app/config/config.dart';
import 'package:wordpress_app/models/app_config_model.dart';
import 'package:wordpress_app/models/article.dart';
import 'package:wordpress_app/utils/toast.dart';
import '../constants/constant.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditionally import 'dart:html' only on web
// You need to split web-only logic into separate file if needed
// Avoid direct usage to keep this file compatible across platforms

class AppService {
  Future<bool> checkInternet() async {
    bool internet = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('connected');
        internet = true;
      }
    } on SocketException catch (_) {
      debugPrint('not connected');
      internet = false;
    }
    return internet;
  }

  Future addToRecentSearchList(String newSerchItem) async {
    final hive = await Hive.openBox(Constants.resentSearchTag);
    hive.add(newSerchItem);
  }

  Future removeFromRecentSearchList(int selectedIndex) async {
    final hive = await Hive.openBox(Constants.resentSearchTag);
    hive.deleteAt(selectedIndex);
  }

  Future openLink(context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      openToast1("Can't launch the url");
    }
  }

  Future openEmailSupport(context, String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email.trim(),
      query: 'subject=About ${Config.appName}&body=',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      openToast1("Can't open the email app");
    }
  }

  Future sendCommentReportEmail(context, String postTitle, String comment, String postLink,
      String userName, String supportEmail) async {
    final String formattedComment = AppService.getNormalText(comment);
    final Uri uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query:
      'subject=${Config.appName} - Comment Report&body=$userName has reported on a comment on $postTitle.\nReported Comment: $formattedComment\nPost Link: $postLink',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      openToast1("Can't open the email app");
    }
  }

  Future openLinkWithCustomTab(BuildContext context, String url) async {
    try {
      if (kIsWeb) {
        // Use universal_html/html.dart for web-safe implementation
        // Or move this part to a separate file and import conditionally
        // html.window.open(url, '_blank');
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        await FlutterWebBrowser.openWebPage(
          url: url,
          customTabsOptions: CustomTabsOptions(
            colorScheme: context.read<ThemeBloc>().darkTheme!
                ? CustomTabsColorScheme.dark
                : CustomTabsColorScheme.light,
            instantAppsEnabled: true,
            showTitle: true,
            urlBarHidingEnabled: true,
          ),
          safariVCOptions: const SafariViewControllerOptions(
            barCollapsingEnabled: true,
            dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
            modalPresentationCapturesStatusBarAppearance: true,
          ),
        );
      }
    } catch (e) {
      openToast1('Cannot launch the URL');
      debugPrint(e.toString());
    }
  }

  Future launchAppReview(context) async {
    final SettingsBloc sb = Provider.of<SettingsBloc>(context, listen: false);
    LaunchReview.launch(
        androidAppId: sb.packageName, iOSAppId: Config.iOSAppID, writeReview: false);
  }

  static getNormalText(String text) {
    return HtmlUnescape().convert(parse(text).documentElement!.text);
  }

  static String getVimeoId(String videoUrl) {
    RegExp regExp = RegExp(
        r'(?:http|https)?:?\/\/?(?:www\.)?(?:player\.)?vimeo\.com\/(?:channels\/(?:\w+\/)?|groups\/(?:[^\/]*)\/videos\/|video\/|)(\d+)(?:|\/\?)');
    return regExp.firstMatch(videoUrl)!.group(1).toString();
  }

  static bool isEmailValid(email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static bool isNumber(quantity) {
    return RegExp(r"^[0-9]+")
        .hasMatch(quantity);
  }

  static String getTime(DateTime dateTime, BuildContext context) {
    final currentLocale = EasyLocalization.of(context)!.currentLocale;
    final data = timeago.format(dateTime, locale: currentLocale.toString());
    return data;
  }

  static String getDate(DateTime dateTime) {
    final date = Jiffy.parseFromDateTime(dateTime).yMMMd;
    return date;
  }

  static bool isVideoPost(Article article) {
    return article.videoPost! &&
        (article.videoUrl != '' || article.youtubeUrl != '' || article.viemoUrl != '');
  }

  static String getIds(List<int> ids) {
    return ids.isEmpty ? '0' : ids.join(',');
  }

  static String getReadingTime(String text) {
    return text == '' ? '' : readingTime(getNormalText(text)).msg;
  }

  static bool nativeAdVisible(String placement, ConfigModel configs) {
    return configs.admobEnabled &&
        configs.nativeAdsEnabled &&
        configs.nativeAdPlacements.contains(placement);
  }

  static bool customAdVisible(String placement, ConfigModel configs) {
    return !configs.nativeAdsEnabled &&
        configs.customAdsEnabled &&
        configs.customAdAssetUrl != '' &&
        configs.customAdPlacements.contains(placement);
  }

  static void setDisplayToHighRefreshRate() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        FlutterDisplayMode.setHighRefreshRate();
      } catch (e) {
        debugPrint('error on refresh rate');
      }
    }
  }
}
