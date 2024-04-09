import 'package:dashboard/screens/camera_screen.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar_nav.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar_nav1.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/widgets/app_bar/appbar_subtitle.dart';
import 'package:dashboard/screens/chat_box_screen.dart';
import 'package:dashboard/screens/speed_screen.dart';
import 'package:dashboard/screens/translation_screen.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titleKey;
  int currentPageItem;
  Widget? leading1;
  CustomAppBar({
    Key? key,
    required this.titleKey,
    required this.currentPageItem,
    required this.leading1,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState(); 

  @override
  Size get preferredSize => const Size.fromHeight(115);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(appBar: _appBar(context)),
    );
  }

  PreferredSize _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(128),
      child: Container(
        // margin: const EdgeInsets.only(top: 5),
        // padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: _boxDecoration(),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(context),
              _tabBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        // BackButton(color: ColorConstant.whiteA700,),
        Container(
          padding: EdgeInsets.only(left: screenWidth*0.02),
          child: widget.leading1,
        ),

        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: AppbarSubtitle(
              text: widget.titleKey,
              // margin: EdgeInsets.only(left: screenWidth * 0.15),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.05),
          child: CustomImageView(
            width: screenWidth * 0.13,
            height: screenWidth * 0.13,
            imagePath: ImageConstant.logo,
          ),
        )
      ],
    );
  }

  void _handleIndexChanged(int index) {
    setState(() {
      if (index != widget.currentPageItem) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TranslationScreen()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SpeedScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
            break;
        }
      }
    });
  }

  Widget _tabBar(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return CustomAppBarNav(
      dotIndicatorColor: null,
      backgroundColor: ColorConstant.blueNew,
      selectedItemColor: ColorConstant.blueNew,
      currentIndex: widget.currentPageItem,
      margin: EdgeInsets.zero,
      paddingR:
          EdgeInsets.only(left: screenWidth * 0.2, right: screenWidth * 0.2),
      marginR: EdgeInsets.zero,
      unselectedItemColor: ColorConstant.whiteA700,
      onTap: _handleIndexChanged,
      items: [
        /// Home
        CustomAppBarNav1(
          icon: Image.asset(ImageConstant.ttt,
              color: widget.currentPageItem == 0
                  ? ColorConstant.blueNew
                  : ColorConstant.whiteA700),
        ),

        /// Likes
        CustomAppBarNav1(
          icon: Image.asset(ImageConstant.stt,
              color: widget.currentPageItem == 1
                  ? ColorConstant.blueNew
                  : ColorConstant.whiteA700),
        ),

        /// Search
        CustomAppBarNav1(
          icon: Image.asset(ImageConstant.cmr,
              color: widget.currentPageItem == 2
                  ? ColorConstant.blueNew
                  : ColorConstant.whiteA700),
        ),
      ],
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(10),
      ),
      color: ColorConstant.blueNew,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Size _appBarHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.2; // Chiều cao của AppBar là 20% chiều cao màn hình
    return Size.fromHeight(appBarHeight);
  }
}
