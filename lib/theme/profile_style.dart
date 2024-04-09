import 'package:dashboard/app_export.dart';
import 'package:flutter/material.dart';

class ProfileThemes {
  static final primary = Colors.blue;
  static final primaryColor = Colors.blue.shade300;

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: ColorConstant.buttoncolor,
    primaryColorDark: primaryColor,
    colorScheme: ColorScheme.dark(primary: primary),
    dividerColor: Colors.white,
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: ColorConstant.primary,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(primary: primary),
    dividerColor: Colors.black,
  );
}
