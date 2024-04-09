import 'package:flutter/material.dart';

/// A tab to display in a [DotNavigationBar]
class CustomAppBarNav1 {
  /// An icon to display.
  final Widget icon;

  /// A primary color to use for this tab.
  final Color? selectedColor;

  /// The color to display when this tab is not selected.
  final Color? unselectedColor;

 ///bgd colors for the nav bar
  final Color? backgroundColor;
  CustomAppBarNav1({
    required this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
  });
}
