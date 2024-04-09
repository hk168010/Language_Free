import 'package:flutter/material.dart';

class AppThemeProvider extends ChangeNotifier {
 late ThemeData _currentTheme;

  ThemeData get currentTheme => _currentTheme;

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}