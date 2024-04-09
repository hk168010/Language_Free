import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/theme/app_style.dart';
import 'package:dashboard/utils/color_constant.dart';
import 'package:dashboard/utils/image_constant.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar1.dart';
import 'package:dashboard/widgets/app_bar/custom_bottom_app_bar.dart';
import 'package:dashboard/widgets/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _selectedIndex = 21;
  Timer? _debounceTimer;
  String? positions;
  String? langSession = '';
  int? userid; //ADDUID
  Map<String, String> interfaceData = {};
  String? token;
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
    _initializeToken();
    super.initState();
    _debounceTimer = Timer(Duration(milliseconds: 2000), () {});
    _initialize();
    SessionManager.getUserid()
        .then((value) => {userid = int.tryParse(value ?? "@@")});
    print(userid);
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

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    AccessLogs();
  }

  //ADDUID
  String removePlusSign(String str) {
    return str.replaceAll('+', '');
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

  Future<bool> AccessLogs() async {
    final String apiUrl =
        'http://api-languagefree.cosplane.asia/api/AccessLogs';
    final int? userId = userid; //ADDUID
    final int pageId = 17;
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar1(
        titleKey: '${interfaceData["ug"]}',
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
        child: Column(children: [
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
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.02, right: screenWidth * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${interfaceData["mf"]}'),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["tt"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["img"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["co"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["tc"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["ns"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["wt"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["qrsb"]}')
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${interfaceData["ou"]}'),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["pf"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["au"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["fb"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["ug"]}')
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              SizedBox(
                                width: screenWidth * 0.04,
                              ),
                              Text('${interfaceData["fv"]}')
                            ],
                          ),
                          Text(''),
                          Text(''),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: screenWidth * 0.02),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          width: 1.0,
                          color: ColorConstant
                              .grey), // Đặt kích thước và màu cho đường viền dưới
                    ),
                  ),
                ),
                SizedBox(
                  height: screenWidth * 0.03,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.02, right: screenWidth * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. ${interfaceData["tt"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t1"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2. ${interfaceData["img"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t2"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '3. ${interfaceData["co"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t3"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '4. ${interfaceData["tc"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t4"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '5. ${interfaceData["ns"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t5"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '6. ${interfaceData["wt"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t6"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '7. ${interfaceData["qrsb"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t7"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '8. ${interfaceData["pf"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t8"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '9. ${interfaceData["au"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t9"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '10. ${interfaceData["fb"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t10"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '11. ${interfaceData["ug"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t11"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '12. ${interfaceData["fv"]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.05),
                          ),
                          SizedBox(
                            height: screenWidth * 0.02,
                          ),
                          Text(
                            '${interfaceData["t12"]}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: screenWidth * 0.04),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
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

  Widget _buildDot() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
    );
  }

  void _showDialogFeedback() {
    String? _inputText;
    Future<void> postComment() async {
      final String apiUrl =
          'http://api-languagefree.cosplane.asia/api/Comments'; // Thay thế bằng đường dẫn thực tế của API của bạn
      final String comment = _inputText!;

      // Assuming user_id, page_id, and location are known values (you need to adapt this based on your app logic)
      final int? userId =
          userid; //ADDUID // Thay thế bằng ID người dùng thực tế
      final int pageId = 15; // Thay thế bằng ID trang thực tế
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
