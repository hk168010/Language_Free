// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/accesslogs.dart';
import 'package:http/http.dart' as http;
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/utils/image_constant.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar1.dart';
import 'package:dashboard/widgets/app_bar/custom_bottom_app_bar.dart';
import 'package:dashboard/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with TickerProviderStateMixin {
  Map<String, String> interfaceData = {};
  int? userid; //ADDUID
  Timer? _debounceTimer;
  int _selectedIndex = 22;
  String? positions;
  String? langSession = '';
  String? token;
  @override
  void initState() {
    _initializeToken();
    super.initState();
    _debounceTimer = Timer(Duration(milliseconds: 2000), () {});
    // writeToFile("English", initData);
    // loadData('en');
    // readFromFile('English').then((data) {});
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
    _initialize();
    SessionManager.getUserid()
        .then((value) => {userid = int.tryParse(value ?? "@@")});
    print(userid);
  }

  //ADDUID
  String removePlusSign(String str) {
    return str.replaceAll('+', '');
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    AccessLogs();
  }

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  Future<bool> AccessLogs() async {
    final String apiUrl =
        'http://api-languagefree.cosplane.asia/api/AccessLogs';
    final int? userId = userid; //ADDUID
    final int pageId = 13;
    final String location = positions ?? 'Unknown Location';
    try {
      final Map<String, dynamic> requestData = {
        'userId': userId ?? 0,
        'pageId': pageId,
        'location': location,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bool accessGranted = responseData['accessGranted'] ?? false;
        return accessGranted;
      } else {
        print(
            'Failed to check access log, status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error calling API: $e');
      return false;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String? currentPosition = await getLocationFromCoordinates(
          position.latitude, position.longitude);
      if (currentPosition != null) {
        print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa $currentPosition');
        setState(() {
          positions = currentPosition;
        });
        await SessionManager.getUserid().then((value) {
          setState(() {
            userid = int.tryParse(value ?? "@@");
          });
        });
      } else {
        print('No position found.');
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<String?> getLocationFromCoordinates(
      double latitude, double longitude) async {
    String? addressname;

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        // Lấy thông tin vị trí từ placemark, ví dụ:
        String? country = placemark.country;
        String? country2 = placemark.subAdministrativeArea;
        String? country5 = placemark.thoroughfare;
        String? country7 = placemark.administrativeArea;
        addressname = ' $country5, $country2, $country7, $country';

        print('dia chi nha$addressname');
        print('dia chi quoc gia$country');
        print('dia chi quoc gia2$country2');
        print('dia chi quoc gia5$country5');
        print('dia chi quoc gia7$country7');
        return addressname;
      } else {
        // Không có thông tin placemark, trả về null hoặc thông tin vị trí mặc định
        return null;
      }
    } catch (e) {
      print("Error getting location from coordinates: $e");
      return null;
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar1(
        titleKey: '${interfaceData["au"]}',
        actions: [
          IconButton(
            icon: Icon(Icons.feedback_rounded),
            color: ColorConstant.whiteA700,
            onPressed: () {
              _showDialogFeedback();
            },
          ),
          Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              child: CustomImageView(
                width: 50,
                height: 50,
                imagePath: ImageConstant.logo,
              )),
        ],
        leading: IconButton(
          iconSize: 25.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: ColorConstant.whiteA700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.05, right: screenWidth * 0.05),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Column(children: [
                      CustomImageView(
                        width: 150 * screenWidth / 250,
                        height: 150 * screenWidth / 280,
                        svgPath: ImageConstant.logoHome,
                      ),
                      Text(
                        '${interfaceData["titleaus"]}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ColorConstant.gray),
                      )
                    ])),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      '${interfaceData["titleour"]}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: screenWidth * 0.05),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text.rich(
                        textAlign: TextAlign.justify,
                        TextSpan(children: [
                          TextSpan(
                            text: '${interfaceData["contentour"]}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ])),
                    SizedBox(height: screenWidth * 0.02),
                    CustomImageView(
                      width: 150 * screenWidth / 100,
                      height: 150 * screenWidth / 400,
                      imagePath: ImageConstant.logoGr,
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text('${interfaceData["titleteam"]}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.05)),
                    SizedBox(height: screenWidth * 0.02),
                    Text.rich(
                      textAlign: TextAlign.justify,
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${interfaceData["contentteam1"]}',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: '${interfaceData["contentteam2"]}',
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                                decorationColor: Colors.transparent),
                          ),
                          TextSpan(
                            text: '${interfaceData["contentteam3"]}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                  ]),
            ),
            Container(
              width: screenWidth,
              height: 150 * screenWidth / 180,
              color: ColorConstant.whiteA700,
              child: CustomImageView(
                width: screenWidth,
                height: 150 * screenWidth / 180,
                imagePath: ImageConstant.logofpt,
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.05, right: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: CustomImageView(
                      width: 50 * screenWidth / 300,
                      height: 50 * screenWidth / 400,
                      imagePath: ImageCountryConstant.Viet,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text('${interfaceData["logofpt1"]}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: screenWidth * 0.05)),
                  SizedBox(height: screenWidth * 0.02),
                  Text.rich(
                    textAlign: TextAlign.justify,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${interfaceData["contentfpt1"]}',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: '${interfaceData["contentfpt2"]}',
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.none,
                              decorationColor: Colors.transparent),
                        ),
                        TextSpan(
                          text: '${interfaceData["contentfpt3"]}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text('${interfaceData["contactus"]}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: screenWidth * 0.05)),
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 3,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 255, 255, 255)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Đặt bán kính theo mong muốn của bạn
                                ),
                              ),
                            ),
                            onPressed: () {
                              _showDialog(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: screenWidth * 0.02,
                                  bottom: screenWidth * 0.02),
                              child: Container(
                                width: screenWidth * 0.1,
                                height: screenWidth * 0.25,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: screenWidth * 0.1,
                                      height: screenWidth * 0.1,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          color: Colors.green.shade100),
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.green.shade900,
                                      ),
                                    ),
                                    SizedBox(height: screenWidth * 0.02),
                                    Container(
                                      child: Text(
                                        '${interfaceData["infous"]}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.green.shade900),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 3,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 255, 255, 255)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Đặt bán kính theo mong muốn của bạn
                                ),
                              ),
                            ),
                            onPressed: () {
                              _showDialog1(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: screenWidth * 0.02,
                                  bottom: screenWidth * 0.02),
                              child: Container(
                                width: screenWidth * 0.1,
                                height: screenWidth * 0.25,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: screenWidth * 0.1,
                                      height: screenWidth * 0.1,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          color: Colors.blue.shade100),
                                      child: Icon(
                                        Icons.email,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    SizedBox(height: screenWidth * 0.02),
                                    Container(
                                      child: Text(
                                        '${interfaceData["emailus"]}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.blue.shade900),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 3,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 255, 255, 255)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Đặt bán kính theo mong muốn của bạn
                                ),
                              ),
                            ),
                            onPressed: () {
                              _showDialog2(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: screenWidth * 0.02,
                                  bottom: screenWidth * 0.02),
                              child: Container(
                                width: screenWidth * 0.1,
                                height: screenWidth * 0.25,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: screenWidth * 0.1,
                                      height: screenWidth * 0.1,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          color: Colors.red.shade100),
                                      child: Icon(
                                        Icons.phone_in_talk,
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                    SizedBox(height: screenWidth * 0.02),
                                    Container(
                                      child: Text(
                                        '${interfaceData["callus"]}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.red.shade900),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.1),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
          selectedIndex: _selectedIndex,
          onTabChange: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.green.shade100),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.green.shade900,
                  size: screenWidth * 0.1,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.02, right: screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyen Thanh Huy',
                  style: AppStyle.txtPoppinsMedium18Black500_1,
                ),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: 'CE160121')),
                SizedBox(height: screenWidth * 0.01),
                Text('Nguyen Duc Tai',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: 'CE160859')),
                SizedBox(height: screenWidth * 0.01),
                Text('Le Anh Tuyen',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: 'CE150429')),
                SizedBox(height: screenWidth * 0.01),
                Text('Huynh Khanh',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: 'CE150703')),
                SizedBox(height: screenWidth * 0.01),
                Text('Quach Hoang Dao',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: 'CE150538')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog1(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.blue.shade100),
                child: Icon(
                  Icons.email,
                  color: Colors.blue.shade900,
                  size: screenWidth * 0.1,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.02, right: screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nguyen Thanh Huy',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(
                    name: TextEditingController(
                        text: 'HuyNTCE160121@fpt.edu.vn')),
                SizedBox(height: screenWidth * 0.01),
                Text('Nguyen Duc Tai',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(
                    name: TextEditingController(
                        text: 'TaiNDCE160859@fpt.edu.vn')),
                SizedBox(height: screenWidth * 0.01),
                Text('Le Anh Tuyen',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(
                    name: TextEditingController(
                        text: 'TuyenLACE150429@fpt.edu.vn')),
                SizedBox(height: screenWidth * 0.01),
                Text('Huynh Khanh',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(
                    name: TextEditingController(
                        text: 'KhanhHCE150703@fpt.edu.vn')),
                SizedBox(height: screenWidth * 0.01),
                Text('Quach Hoang Dao',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(
                    name: TextEditingController(
                        text: 'DaoQHCE150538@fpt.edu.vn')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.red.shade100),
                child: Icon(
                  Icons.phone_in_talk,
                  color: Colors.red.shade900,
                  size: screenWidth * 0.1,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.05, right: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nguyen Thanh Huy',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: '+84 392 549074')),
                SizedBox(height: screenWidth * 0.01),
                Text('Nguyen Duc Tai',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: '+84 939 765749')),
                SizedBox(height: screenWidth * 0.01),
                Text('Le Anh Tuyen',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: '+84 856 020525')),
                SizedBox(height: screenWidth * 0.01),
                Text('Huynh Khanh',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: '+84 83 2459954')),
                SizedBox(height: screenWidth * 0.01),
                Text('Quach Hoang Dao',
                    style: AppStyle.txtPoppinsMedium18Black500_1),
                SizedBox(height: screenWidth * 0.01),
                Textus(name: TextEditingController(text: '+84 86 8955614')),
              ],
            ),
          ),
        );
      },
    );
  }

  Textus({required TextEditingController name}) {
    _copy() {
      final Value = ClipboardData(text: name.text);
      Clipboard.setData(Value);
      print(Value);
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(children: [
      Container(
        padding: getPadding(
            top: screenWidth * 0.01,
            right: screenWidth * 0.02,
            left: screenWidth * 0.03,
            bottom: screenWidth * 0.01),
        height: MediaQuery.of(context).size.width > 150
            ? MediaQuery.of(context).size.height * 0.08
            : MediaQuery.of(context).size.width * 0.40,
        width: screenWidth * 0.8,
        decoration: BoxDecoration(
          color: ColorConstant.grey1,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      textAlign: TextAlign.start,
                      readOnly: true,
                      controller: name,
                      cursorHeight: screenHeight * 0.03,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: '${interfaceData["text"]}',
                        border: InputBorder.none,
                        labelStyle:
                            AppStyle.txtPoppinsMedium18Black900.copyWith(
                          color: ColorConstant.black900,
                        ),
                        hintStyle: AppStyle.txtPoppinsMedium15.copyWith(
                          color: ColorConstant.gray500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: screenWidth * 0.1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        child: IconButton(
                          icon: Icon(
                            Icons.copy,
                            color: ColorConstant.black900,
                            size: screenWidth * 0.07,
                          ),
                          onPressed: () {
                            _copy();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  void _showDialogFeedback() {
    String? _inputText;
    Future<void> postComment() async {
      final String apiUrl =
          'http://api-languagefree.cosplane.asia/api/Comments'; // Thay thế bằng đường dẫn thực tế của API của bạn
      final String comment = _inputText!;

      // Assuming user_id, page_id, and location are known values (you need to adapt this based on your app logic)
      final int? userId = userid; //ADDUID// Thay thế bằng ID người dùng thực tế
      final int pageId = 13; // Thay thế bằng ID trang thực tế
      final String location = positions ?? 'Unknown Location';

      final Comment newComment = Comment(
        userId: userId ?? 0,
        pageId: pageId,
        commentText: comment,
        location: location,
      );

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(newComment.toJson()),
        );

        if (response.statusCode == 200) {
          Flushbar(
            margin: EdgeInsets.all(15),
            borderRadius: BorderRadius.circular(8),
            message: '${interfaceData["yfwbt"]}',
            messageColor: Colors.black,
            boxShadows: [
              BoxShadow(
                color: Colors.green.shade800,
                offset: Offset(0.0, 1.0),
                blurRadius: 3.0,
              )
            ],
            icon: Icon(
              Icons.warning_rounded,
              size: 28.0,
              color: Colors.green[800],
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.white,
            leftBarIndicatorColor: Colors.green[800],
          ).show(context);
        } else {
          print(
              'Đã xảy ra lỗi khi đăng bình luận. Mã lỗi: ${response.statusCode}');
        }
      } catch (e) {
        print('Đã xảy ra lỗi: $e');
      }
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          double screenWidth = MediaQuery.of(context).size.width;
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.black,
                        ))
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.1, right: screenWidth * 0.1),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1.0,
                            color: ColorConstant
                                .greyNew2), // Đặt kích thước và màu cho đường viền dưới
                      ),
                    ),
                    child: Text(
                      '${interfaceData["fb"]}',
                      style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          color: ColorConstant.blueNew),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  _inputText = value;
                });
              },
              cursorColor: ColorConstant.black900,
              textAlign: TextAlign.left,
              maxLines: 10,
              style: TextStyle(color: ColorConstant.black900),
              decoration: InputDecoration(
                hintText: '${interfaceData["etyfb"]}',
                hintStyle: AppStyle.txtPoppinsSem16Blue,
                contentPadding: EdgeInsets.only(
                    left: screenWidth * 0.02, right: screenWidth * 0.02),
                filled: true, // Set filled to true
                fillColor: ColorConstant.whiteA700,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: [
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    postComment();

                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: screenWidth * 0.4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(screenWidth * 0.1)),
                        color: ColorConstant.blueNew),
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${interfaceData["sb"]}',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w300,
                              color: ColorConstant.whiteA700),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
