import 'package:dashboard/screens/newspaper_screen.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/screens/speed_screen.dart';
import 'package:dashboard/screens/translation_screen.dart';

class AppRoutes {
  static const String speedtotextScreen = '/speed_screen';

  static const String translationScreen = '/translation_screen';

 static const String newspaperScreen = '/newspaper_screen';

  static Map<String, WidgetBuilder> routes = {
    speedtotextScreen: (context) => SpeedScreen(),
    translationScreen: (context) => TranslationScreen(),
     newspaperScreen: (context) => NewsPaperScreen(),
  };
}
