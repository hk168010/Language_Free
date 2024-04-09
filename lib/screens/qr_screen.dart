import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/comment.dart';
import 'package:http/http.dart' as http;
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
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher_string.dart';

class QRScreen extends StatefulWidget {
  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int _selectedIndex = 20;
  Timer? _debounceTimer;
  String? langSession = '';
  String? positions;
  int? userid; //ADDUID
  String? token;
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
    _initializeToken();
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
    _initialize();
    SessionManager.getUserid()
        .then((value) => {userid = int.tryParse(value ?? "@@")});
    print(userid);
  }

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  //ADDUID
  String removePlusSign(String str) {
    return str.replaceAll('+', '');
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    AccessLogs();
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
    final int pageId = 16;
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: CustomAppBar1(
        titleKey: '${interfaceData["qrsb"]}',
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
      body: Stack(
        children: <Widget>[
          // QRView full screen
          Positioned.fill(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          // Rescan button at bottom center
          Padding(
            padding: EdgeInsets.only(
                bottom: screenWidth * 0.27,
                left: screenWidth * 0.02,
                right: screenWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Container(
                //     decoration: ShapeDecoration(
                //       color: ColorConstant.blueNew, // Màu nền của Ink
                //       shape: CircleBorder(), // Hình dạng của nút là hình tròn
                //     ),
                //     child: IconButton(
                //       onPressed: () {},
                //       icon: Icon(
                //         Icons.upload_file_rounded,
                //         color: ColorConstant.whiteA700,
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   width: screenWidth / 4,
                // ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(ColorConstant.blueNew),
                      shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              5.0), // Thay đổi giá trị border radius theo ý muốn của bạn
                        ),
                      ),
                    ),
                    onPressed: () {
                      // Resume scanning when the "Rescan" button is pressed
                      controller?.resumeCamera();
                      setState(() {
                        result =
                            null; // Reset the result to null for a new scan
                      });
                    },
                    child: Text(
                      '${interfaceData["rs"]}',
                      style: TextStyle(
                          color: ColorConstant.whiteA700,
                          fontSize: screenWidth * 0.04),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (result == null) {
        setState(() {
          result = scanData;
          _showDialog(result!.code!);
          // Pause scanning when the dialog is displayed
          controller.pauseCamera();
        });
      }
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // Show a dialog with an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              '${interfaceData["er"]}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  color: Colors.red),
            ),
            content: Text("${interfaceData["ltu"]} $url"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  '${interfaceData["cn"]}',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                      color: ColorConstant.black900),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _showDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.2),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          width: 1.0,
                          color: ColorConstant
                              .greyNew2), // Đặt kích thước và màu cho đường viền dưới
                    ),
                  ),
                  child: Text(
                    '${interfaceData["scn"]}',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: ColorConstant.blueNew),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
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
          content: Text(
            "$url",
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w300,
                color: ColorConstant.blueNew),
          ),
          actions: [
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  _launchURL(url);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(screenWidth * 0.1)),
                      color: ColorConstant.blueNew),
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.link,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: screenWidth * 0.02,
                      ),
                      Text(
                        '${interfaceData["otl"]}',
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
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
      final int pageId = 16; // Thay thế bằng ID trang thực tế
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
