// @dart=2.9

//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:olaclick/resources/app_config.dart';
import 'package:olaclick/src/features/inappwebview/inAppWebViewScreen.dart';
import 'package:olaclick/src/features/pushnotifications/pushNotificationService.dart';
import 'package:olaclick/src/provider/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LanguageProvider appLanguage = LanguageProvider();
  //FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    PushNotificationService.messagesStream.listen((message) {
      if (message.length > 0) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    //notifier to send data by provider
    print("app env" + AppConfig.of(context).appTitle.toString());
    return ChangeNotifierProvider<LanguageProvider>(
      create: (_) => appLanguage,
      child: Consumer<LanguageProvider>(builder: (context, model, child) {
        final provider = Provider.of<LanguageProvider>(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConfig.of(context).appTitle,
          initialRoute: 'home',
          routes: {
            'home': (_) => InAppWebViewScreen(
                url: AppConfig.of(context).url,
                urlAPI: AppConfig.of(context).urlAPI),
          },
          locale: provider.appLocal,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        );
      }),
    );
  }
}
