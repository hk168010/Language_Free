import 'dart:async';
import 'dart:convert';
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/DTO/translatehistory.dart';
import 'package:dashboard/screens/translation_screen.dart';
import 'package:dashboard/theme/app_style.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/utils/color_constant.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HistoryScreen> {
  Map<String, String> interfaceData = {};
  Timer? _debounceTimer;
  String? positions;
  String? langSession = '';
  List<TranslationData> externalDataList = [];
  late TranslationData translationData;
  bool isLoading = true; // Variable to track loading state
  String? token;

  int? userid; //ADDUID
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

  Future<void> fetchTranslationHistory(int id) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
        Uri.parse(
            'http://api-languagefree.cosplane.asia/api/TranslationHistorys/$id'),
        headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> dataList = jsonDecode(response.body);
      final List<TranslationData> translationList =
          dataList.map((json) => TranslationData.fromJson(json)).toList();
      for (int i = translationList.length - 1; i >= 0; i--) {
        if (translationList[i].status == '2') {
          translationList.removeAt(i);
        }
      }
      setState(() {
        externalDataList = translationList;
      });
    } else {
      throw Exception('Failed to load translation history');
    }
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    await fetchTranslationHistory(userid ?? 0);
    AccessLogs();
    setState(() {
      isLoading = false; // Set loading state to false when data is fetched
    });
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
    final int pageId = 18;
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
      backgroundColor:
          Colors.transparent, // Set background color to transparent
      extendBodyBehindAppBar: true, // Extend body behind app bar
      extendBody: true, // Extend body behind bottom navigation bar
      appBar: CustomAppBar1(
        titleKey: '${interfaceData["fv"]}',
        actions: [
          IconButton(
            icon: Icon(Icons.feedback_rounded),
            color: ColorConstant.whiteA700,
            onPressed: () {
              _showDialogFeedback();
            },
          ),
        ],
        leading: IconButton(
          iconSize: 25.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TranslationScreen()),
            );
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: ColorConstant.whiteA700,
          ),
        ),
      ),
      body: isLoading
          ? Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blueAccent,
                ),
              ))
          : Container(
              padding: EdgeInsets.only(top: screenWidth * 0.2),
              color: Colors.white, // Đặt màu nền của ListView
              child: ListView.builder(
                itemCount: externalDataList
                    .length, // Thay đổi số lượng item theo nhu cầu
                padding: EdgeInsets.all(
                    screenWidth * 0.04), // Thêm padding cho ListView
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        color: Colors.grey[200],
                      ),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      externalDataList[index].sourceLanguage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyle
                                          .txtPoppinsMedium15WhiteA200
                                          .copyWith(
                                              fontSize: screenWidth * 0.05,
                                              color: ColorConstant.blueNew,
                                              fontWeight: FontWeight.w200),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.02,
                                    ),
                                    Icon(Icons.arrow_right_alt),
                                    SizedBox(
                                      width: screenWidth * 0.02,
                                    ),
                                    Text(
                                      externalDataList[index].targetLanguage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyle
                                          .txtPoppinsMedium15WhiteA200
                                          .copyWith(
                                              fontSize: screenWidth * 0.05,
                                              color: ColorConstant.blueNew,
                                              fontWeight: FontWeight.w200),
                                    ),
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {
                                      removeTranslationHistory(
                                          externalDataList[index]
                                              .translationId);
                                      // externalDataList.remove(externalDataList[index]);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ))
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.03),
                            Text(externalDataList[index].sourceText),
                            Text(
                              externalDataList[index].translatedText,
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 131, 131, 131)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> removeTranslationHistory(int id) async {
    print('55555555555555555555555555555$id');
    final apiUrl =
        'http://api-languagefree.cosplane.asia/api/TranslationHistorys/remove?id=$id';
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        Flushbar(
          margin: EdgeInsets.all(15),
          borderRadius: BorderRadius.circular(8),
          message: '${interfaceData["yhsdat"]}',
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
        await fetchTranslationHistory(userid ?? 0);
      } else {
        Flushbar(
          margin: EdgeInsets.all(15),
          borderRadius: BorderRadius.circular(8),
          message: '${interfaceData["error1"]}${response.reasonPhrase}',
          messageColor: Colors.black,
          boxShadows: [
            BoxShadow(
              color: Colors.red.shade800,
              offset: Offset(0.0, 1.0),
              blurRadius: 3.0,
            )
          ],
          icon: Icon(
            Icons.warning_rounded,
            size: 28.0,
            color: Colors.red[800],
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.white,
          leftBarIndicatorColor: Colors.red[800],
        ).show(context);
      }
    } catch (e) {
      Flushbar(
        margin: EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(8),
        message: '${interfaceData["error2"]}$e',
        messageColor: Colors.black,
        boxShadows: [
          BoxShadow(
            color: Colors.red.shade800,
            offset: Offset(0.0, 1.0),
            blurRadius: 3.0,
          )
        ],
        icon: Icon(
          Icons.warning_rounded,
          size: 28.0,
          color: Colors.red[800],
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.white,
        leftBarIndicatorColor: Colors.red[800],
      ).show(context);
    }
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
      final int pageId = 18; // Thay thế bằng ID trang thực tế
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
          Flushbar(
            margin: EdgeInsets.all(15),
            borderRadius: BorderRadius.circular(8),
            message: '${interfaceData["error3"]}${response.statusCode}',
            messageColor: Colors.black,
            boxShadows: [
              BoxShadow(
                color: Colors.red.shade800,
                offset: Offset(0.0, 1.0),
                blurRadius: 3.0,
              )
            ],
            icon: Icon(
              Icons.warning_rounded,
              size: 28.0,
              color: Colors.red[800],
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.white,
            leftBarIndicatorColor: Colors.red[800],
          ).show(context);
        }
      } catch (e) {
        Flushbar(
          margin: EdgeInsets.all(15),
          borderRadius: BorderRadius.circular(8),
          message: '${interfaceData["error4"]} $e',
          messageColor: Colors.black,
          boxShadows: [
            BoxShadow(
              color: Colors.red.shade800,
              offset: Offset(0.0, 1.0),
              blurRadius: 3.0,
            )
          ],
          icon: Icon(
            Icons.warning_rounded,
            size: 28.0,
            color: Colors.red[800],
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.white,
          leftBarIndicatorColor: Colors.red[800],
        ).show(context);
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
