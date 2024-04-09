import 'package:flutter/material.dart';
import 'package:dashboard/app_export.dart';

// ignore: must_be_immutable
class AppbarSubtitle extends StatelessWidget {
  AppbarSubtitle({required this.text, this.margin, this.onTap});

  String text;

  EdgeInsetsGeometry? margin;

  Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppStyle.txtPoppinsMedium23White.copyWith(
            color: ColorConstant.whiteA700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
