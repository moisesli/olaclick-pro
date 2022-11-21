// @dart=2.9

//import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olaclick/main.dart';
import 'package:olaclick/src/components/constants.dart';
import 'package:olaclick/src/features/pushnotifications/pushNotificationService.dart';
import 'package:olaclick/src/provider/language_provider.dart';

import 'resources/app_config.dart';
//import 'package:appsflyer_sdk/appsflyer_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.initializeApp();
  LanguageProvider appLanguage = LanguageProvider();
  await appLanguage.fetchLocale();

  var configuredApp = AppConfig(
    appTitle: "OlaClick Dev",
    buildFlavor: "Development",
    urlAPI: "https://api.olaclick.xyz",
    url:
        'https://panel.olaclick.xyz/?_flutter_appversion=$version&_flutter_printformatversion=$printFormatVersion',
    version: 'v$version',
    child: MyApp(),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    return runApp(configuredApp);
  });
}
