// @dart=2.9

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olaclick/main.dart';
import 'package:olaclick/src/components/constants.dart';
import 'package:olaclick/src/features/pushnotifications/pushNotificationService.dart';
import 'package:olaclick/src/provider/language_provider.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
import 'resources/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.initializeApp();
  LanguageProvider appLanguage = LanguageProvider();
  await appLanguage.fetchLocale();

  Map appsFlyerOptions = {
    "afAppId": "com.olaclick.pro",
    "afDevKey": "JXSSKeSYyr9XfZMgfg4uUc",
    "disableAdvertisingIdentifier": false,
    "isDebug": true
  };

  AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);

  print("appflyer" + appsflyerSdk.toString());
  appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true);

  appsflyerSdk.onDeepLinking((res) {
    print("res on deeplink: " + res.toString());
  });

  var configuredApp = AppConfig(
    appTitle: "OlaClick Pro",
    buildFlavor: "Production",
    urlAPI: "https://api.olaclick.com",
    url:
        'https://panel.olaclick.com/?_flutter_appversion=$version&_flutter_printformatversion=$printFormatVersion',
    version: 'v$version',
    child: MyApp(),
  );
  //SENTRY
  // await SentryFlutter.init(
  //   (options) => options.dsn =
  //       'https://fd80925a0621470c8abc5b084d0a7060@o427203.ingest.sentry.io/5945198',
  //   appRunner: () => runApp(configuredApp),
  // );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    return runApp(configuredApp);
  });
}
