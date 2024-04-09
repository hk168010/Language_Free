import 'package:dashboard/widgets/app_bar/custom_app_bar_nav.dart';
import 'package:flutter/material.dart';

class CustomAppBarNavBody extends StatelessWidget {
  const CustomAppBarNavBody({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.curve,
    required this.duration,
    required this.selectedItemColor,
    required this.theme,
    required this.unselectedItemColor,
    required this.onTap,
    required this.itemPadding,
    required this.dotIndicatorColor,
    required this.enablePaddingAnimation,
    this.splashBorderRadius,
    this.splashColor,
  }) : super(key: key);

  final List<CustomAppBarNav1> items;
  final int currentIndex;
  final Curve curve;
  final Duration duration;
  final Color? selectedItemColor;
  final ThemeData theme;
  final Color? unselectedItemColor;
  final Function(int index) onTap;
  final EdgeInsets itemPadding;
  final Color? dotIndicatorColor;
  final bool enablePaddingAnimation;
  final Color? splashColor;
  final double? splashBorderRadius;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final item in items)
          TweenAnimationBuilder<double>(
            tween: Tween(
              end: items.indexOf(item) == currentIndex ? 1.0 : 0.0,
            ),
            curve: curve,
            duration: duration,
            builder: (context, t, _) {
              final _selectedColor = item.selectedColor ??
                  selectedItemColor ??
                  theme.primaryColor;

              final _unselectedColor = item.unselectedColor ??
                  unselectedItemColor ??
                  theme.iconTheme.color;

              final backgroundColor = items.indexOf(item) == currentIndex
                  ? Colors.white // Màu nền trắng khi mục được chọn
                  : Colors.transparent; // Màu nền trong suốt khi mục không được chọn

              return Material(
                color: Color.lerp(Colors.transparent, backgroundColor, t),
                borderRadius: BorderRadius.circular(splashBorderRadius ?? 8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onTap.call(items.indexOf(item)),
                  focusColor: splashColor ?? _selectedColor.withOpacity(0.1),
                  highlightColor:
                      splashColor ?? _selectedColor.withOpacity(0.1),
                  splashColor: splashColor ?? _selectedColor.withOpacity(0.1),
                  hoverColor: splashColor ?? _selectedColor.withOpacity(0.1),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: itemPadding -
                            (enablePaddingAnimation
                                ? EdgeInsets.only(
                                    right: 0,
                                    left:0, )
                                : EdgeInsets.zero),
                        child: Row(
                          children: [
                            IconTheme(
                              data: IconThemeData(
                                color: Color.lerp(
                                    _unselectedColor, _selectedColor, t),
                                size: 24,
                              ),
                              child: item.icon,
                            ),
                          ],
                        ),
                      ),
                      // ClipRect(
                      //   child: SizedBox(
                      //     height: 45,
                      //     child: Align(
                      //       alignment: Alignment.bottomCenter,
                      //       widthFactor: t,
                      //       child: Padding(
                      //         padding: EdgeInsetsDirectional.only(
                      //           bottom: itemPadding.bottom/0.95,
                      //             start: itemPadding.right / 0.82,
                      //             end: itemPadding.right),
                      //         child: DefaultTextStyle(
                      //           style: TextStyle(
                      //             color: Color.lerp(
                      //                 _selectedColor.withOpacity(0.0),
                      //                 _selectedColor,
                      //                 t),
                      //             fontWeight: FontWeight.w600,
                      //           ),
                      //           child: Container(
                      //             width: 20,
                      //             height: 1.5,
                      //             color: dotIndicatorColor != null
                      //                 ? dotIndicatorColor
                      //                 : _selectedColor,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}