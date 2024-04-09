import 'dart:async';
import 'dart:convert';

import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/chat_box_screen.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/screens/newspaper_screen.dart';
import 'package:dashboard/screens/translation_screen.dart';
import 'package:dashboard/screens/speed_screen.dart';
import '../../screens/weather_screen.dart';

class CustomBottomBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const CustomBottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChange,
  }) : super(key: key);
  @override
  _CustomBottomBarState createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  Map<String, String> interfaceData = {};
  Timer? _debounceTimer;

  String? langSession = '';
  Map<String, String> data = {};
  @override
  void initState() {
    super.initState();
    SessionManager.getLangInterface().then((value) async {
      print('Gía trị của session là: $value');
      String? temp = await value;
      setState(() {
        langSession = temp;
      });
      if (langSession == null || langSession == '') {
        await loadData('en');
        await loadinterfaceData('en');
        print('SS null');
      } else {
        print('SS khong null');
        await loadData(langSession!);
        await loadinterfaceData(langSession!);
      }
    });
  }

  Future<void> loadData(String name) async {
    try {
      // Đọc nội dung file JSON từ assets
      String jsonString =
          await rootBundle.loadString('lang/TranslateLang/$name.json');
      // Hiển thị nội dung JSON đã giải mã
      print("Decoded JSON: $jsonString");
      // Chuyển đổi JSON thành Map<String, String>
      Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        data = jsonData.cast<String, String>();
      });
    } catch (error) {
      print("Error loading JSON: $error");
    }
  }

  Future<void> loadinterfaceData(String name) async {
    try {
      // Đọc nội dung file JSON từ assets
      String jsonString =
          await rootBundle.loadString('lang/InterfaceLang/$name.json');
      // Hiển thị nội dung JSON đã giải mã
      print("Decoded JSON: $jsonString");
      // Chuyển đổi JSON thành Map<String, String>
      Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        interfaceData = jsonData.cast<String, String>();
        print(interfaceData);
      });
    } catch (error) {
      print("Error loading JSON: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
        padding: EdgeInsets.only(
            bottom: screenWidth * 0.07,
            left: screenWidth * 0.03,
            right: screenWidth * 0.03),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 1),
              ),
            ],
            color: ColorConstant.whiteA700,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
              bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
            child: GNav(
              backgroundColor: ColorConstant.whiteA700,
              color: ColorConstant.blueNew,
              activeColor: ColorConstant.whiteA700,
              tabBackgroundColor: ColorConstant.blueNew,
              gap: screenWidth * 0.02,
              padding: EdgeInsets.all(screenWidth * 0.03),
              selectedIndex: widget.selectedIndex,
              tabs: [
                GButton(
                  icon: Icons.home_rounded,
                  iconSize: screenWidth * 0.07,
                ),
                GButton(
                  icon: Icons.translate_rounded,
                  iconSize: screenWidth * 0.07,
                ),
                GButton(
                  icon: Icons.newspaper_rounded,
                  iconSize: screenWidth * 0.07,
                ),
                GButton(
                  icon: Icons.cloud_rounded,
                  iconSize: screenWidth * 0.07,
                ),
                GButton(
                  icon: Icons.person_rounded,
                  iconSize: screenWidth * 0.07,
                ),
              ],
              onTabChange: (index) {
                if (index != widget.selectedIndex) {
                  print(
                      '11111111111111111111111111111111111111111111111 $index');
                  widget.onTabChange(index);
                  switch (index) {
                    case 0:
                      if (widget.selectedIndex != 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }

                      break;
                    case 1:
                      if (widget.selectedIndex != 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TranslationScreen()),
                        );
                      }

                      break;
                    case 2:
                      if (widget.selectedIndex != 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewsPaperScreen()),
                        );
                      }
                      break;
                    case 3:
                      if (widget.selectedIndex != 3) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WeatherScreen()),
                        );
                      }
                      break;
                    case 4:
                      if (widget.selectedIndex != 4) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage()),
                        );
                      }
                      break;
                  }
                }
              },
            ),
          ),
        ));
  }

  String shortenText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength - 3) + '...';
    }
  }
}
