import 'dart:async';
import 'dart:convert';

import 'package:dashboard/app_export.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/utils/image_constant.dart';
import 'package:dashboard/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckNetWorkScreen extends StatefulWidget {
  const CheckNetWorkScreen({super.key});
  @override
  State<CheckNetWorkScreen> createState() => _CheckNetWorkScreenState();
}

class _CheckNetWorkScreenState extends State<CheckNetWorkScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Timer? _debounceTimer;

    String? langSession = '';
    Map<String, String> interfaceData = {};
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
    void initState() {
      super.initState();
      _debounceTimer = Timer(Duration(milliseconds: 2000), () {});
      SessionManager.getLangInterface().then((value) async {
        print('Gía trị của session là: $value');
        String? temp = await value;
        setState(() {
          langSession = temp;
        });
        if (langSession == null || langSession == '') {
          await loadinterfaceData('en');
          print('SS null');
        } else {
          print('SS khong null');
          await loadinterfaceData(langSession!);
        }
      });
    }

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomImageView(
              imagePath: ImageConstant.notWifi,
              width: 150.0 * screenWidth / 250.0,
              height: 150 * screenWidth / 250.0,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: screenWidth * 0.05,
            ),
            Text(
              'No internet connection',
              style: TextStyle(fontSize: screenWidth * 0.05),
            ),
            SizedBox(
              height: screenWidth * 0.02,
            ),
            Text(
              'Please check your internet connection',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            SizedBox(
              height: screenWidth * 0.02,
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Try again',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(ColorConstant.blueNew)),
            )
          ],
        ),
      ),
    
    );
  }
}

