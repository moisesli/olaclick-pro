import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class AppConfig extends InheritedWidget {
  final String appTitle;
  final String buildFlavor;
  final String url;
  final String urlAPI;
  final String version;
  final Widget child;

  AppConfig(
      {required this.child,
      required this.appTitle,
      required this.urlAPI,
      required this.buildFlavor,
      required this.url,
      required this.version})
      : super(child: child);

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
