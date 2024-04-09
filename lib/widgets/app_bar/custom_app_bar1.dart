import 'package:dashboard/utils/image_country_constant_1.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/app_localizations.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/widgets/app_bar/appbar_subtitle.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class CustomAppBar1 extends StatelessWidget implements PreferredSizeWidget {
  final String titleKey;
  Widget? leading;
  List<Widget>? actions;

  CustomAppBar1({
    Key? key,
    required this.titleKey,
    this.leading,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final appLocalizations = AppLocalizations.of(context);
    return PreferredSize(
      preferredSize: Size.fromHeight(200.0), // Set the preferred height here
      child: AppBar(
        backgroundColor:
            Colors.transparent, // Set background color to transparent
        leading: leading,
        automaticallyImplyLeading: false,
        actions: actions,
      
        flexibleSpace: Container(
          padding: EdgeInsets.only(bottom: screenWidth * 0.02, top: screenWidth * 0.02, left: screenWidth * 0.05, right: screenWidth * 0.05),
          decoration: BoxDecoration(
            color: ColorConstant.blueNew,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0),
            ),
          ),
        ),
        centerTitle: true,
        title: AppbarSubtitle(
          text: titleKey,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
