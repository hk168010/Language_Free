import 'dart:convert';
import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/DTO/accesslogs.dart';
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/models/message.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/utils/image_country_constant_1.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar1.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:avatar_glow/avatar_glow.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  int Indexer = 0;
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isProcessing = false;
  List<Message> msgs = [];
  bool _isRecording = false;
  String? selectedCountryLabel = "English";
  bool isTyping = false;
  Map<String, String> textData = {};
  late FlutterTts flutterTts;
  int countSpeech = 0;
  TextEditingController _textEditingController = TextEditingController();
  String _text = 'Press the button and start speaking';
  List<String> _tempReponse = [];
  bool _isListening = false;
  String result = '';
  List<Map<String, String>> countryList1 = [];
  bool _isResponse = false; //Fix
  bool _isResponseText = false; //Fix
  bool _isInitializing = false;
  String? selectedCountryValue = 'en_GB';
  Map<String, String> interfaceData = {};
  Timer? _debounceTimer;
  String? positions;
  String? langSession = '';
  Map<String, String> data = {};
  String? token;
  int? userid; //ADDUID
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
        selectedCountryLabel = '${data["en"]}';
      });
    } catch (error) {
      print("Error loading JSON: $error");
    }
  }
  //ADDUID
  String removePlusSign(String str) {
    return str.replaceAll('+', '');
  }

  Future<void> sendMsg() async {
    String text = controller.text;
    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
    final String apiKey = '';
    controller.clear();
    try {
      if (text.isNotEmpty) {
        _isResponseText = true;


        setState(() {
          msgs.insert(0, Message(true, text));
          isTyping = true;
        });

        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);

        var response = await http.post(
          Uri.parse('$apiUrl?key=$apiKey'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'contents': [
              {
                'parts': [
                  {
                    'text': text,
                  },
                ],
              },
            ],
          }),
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          setState(() {
            isTyping = false;

            String responseContent = data['candidates'][0]['content']['parts']
                    [0]['text']
                .toString()
                .trimLeft();

            // Tìm vị trí của dấu chấm sau đó cắt chuỗi tại đó
            int indexOfLastDot = responseContent.lastIndexOf('.');
            if (indexOfLastDot != -1) {
              responseContent =
                  responseContent.substring(0, indexOfLastDot + 1);
            }
            responseContent = responseContent.replaceAll('*', '');
            msgs.insert(0, Message(false, responseContent));

            _isResponseText = false;
          });

          scrollController.animateTo(0.0,
              duration: const Duration(seconds: 1), curve: Curves.easeOut);
        }
      }
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Some error occurred, please try again!")));
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
  void initState() {
    _initializeToken();
    super.initState();
    flutterTts = FlutterTts();
    

    _debounceTimer = Timer(Duration(milliseconds: 2000), () {});
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
    _initialize();
    SessionManager.getUserid()
        .then((value) => {userid = int.tryParse(value ?? "@@")});
    print(userid);
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
    final int pageId = 14;
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
  Future<String> _translateText(String text) async {
    if (text == 'Listening...') {
      setState(() {
        msgs.insert(0, Message(true, text));
        isTyping = true;
        isTyping = false;
        msgs.insert(0, Message(false, 'Cannot recognize the Language'));
      });
    }
    final String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
    final String apiKey = '';

    try {
      setState(() {
        msgs.insert(0, Message(true, text));
        isTyping = true;
      });
      var response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'contents': [
            {
              'parts': [
                {
                  'text': text,
                },
              ],
            },
          ],
        }),
      );

      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      Map<String, dynamic> data = jsonDecode(response.body);
      String responseContent = data['candidates'][0]['content']['parts'][0]
              ['text']
          .toString()
          .trimLeft();
      setState(() {
        isTyping = false;

        // Tìm vị trí của dấu chấm sau đó cắt chuỗi tại đó
        int indexOfLastDot = responseContent.lastIndexOf('.');
        if (indexOfLastDot != -1) {
          responseContent = responseContent.substring(0, indexOfLastDot + 1);
        }

        msgs.insert(0, Message(false, responseContent));
      });
      _isResponseText = false;
      print(
          "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaakkkkkkkkkkkkkkkkkkkkkkk $responseContent");
      return responseContent;
    } catch (e) {
      return "Error: $e";
    }
  }

  int randomIndex(int min, int max) {
    Random rand = new Random();
    return rand.nextInt(max - min) + min;
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
        titleKey: '${interfaceData["tc"]}',
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
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: ColorConstant.whiteA700,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageConstant
                .bgchatbot), // Thay đổi đường dẫn tới hình ảnh của bạn
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: screenWidth * 0.25,
            ),
            Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: msgs.length,
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (context, index) {
                    Message message = msgs[index];
                    String formattedTime = DateFormat('HH:mm')
                        .format(message.timestamp); // Format timestamp
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: isTyping && index == 0
                          ? Column(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: message.isSender ? 0.0 : 10.0,
                                        right: message.isSender ? 10.0 : 0.0,
                                      ),
                                      child: BubbleNormal(
                                        text: msgs[0].msg,
                                        isSender: message.isSender,
                                        color: message.isSender
                                            ? ColorConstant.blueNew
                                            : ColorConstant.whiteA700,
                                        textStyle:
                                            AppStyle.txtPoppinsMedium18White_1,
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                          left: message.isSender ? 0.0 : 30.0,
                                          right: message.isSender ? 30.0 : 0.0,
                                        ),
                                        child: Align(
                                            alignment: message.isSender
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Align(
                                              alignment: message.isSender
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                              child: Text(
                                                formattedTime,
                                                textAlign: TextAlign.left,
                                                style: AppStyle
                                                    .txtPoppinsNormal10Gray500,
                                              ),
                                            ))),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: CustomImageView(
                                      imagePath: ImageConstant.loading2,
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Column(
                              crossAxisAlignment: message.isSender
                                  ? CrossAxisAlignment
                                      .end // Align to the right if isSender is true
                                  : CrossAxisAlignment
                                      .start, // Align to the left if isSender is false
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: message.isSender ? 0.0 : 10.0,
                                    right: message.isSender ? 10.0 : 0.0,
                                  ),
                                  child: BubbleNormal(
                                      text: msgs[index].msg,
                                      isSender: message.isSender,
                                      color: message.isSender
                                          ? ColorConstant.blueNew
                                          : ColorConstant.whiteA700,
                                      textStyle: message.isSender
                                          ? AppStyle.txtPoppinsMedium18White_1
                                          : AppStyle.txtPoppinsMedium18Black_1),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: message.isSender ? 0.0 : 30.0,
                                    right: message.isSender ? 30.0 : 0.0,
                                  ),
                                  child: Text(
                                    formattedTime,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtPoppinsNormal10Gray500,
                                  ),
                                ),
                              ],
                            ),
                    );
                  }),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: screenWidth * 0.03,
                  right: screenWidth * 0.03,
                  top: screenWidth * 0.05,
                  bottom: screenWidth * 0.03),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: ColorConstant.whiteA700),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenWidth * 0.02,
                        bottom: screenWidth * 0.02,
                      ),
                      child: Container(
                        height: screenWidth * 0.15,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10, left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: controller,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (value) {
                                sendMsg();
                              },
                              textInputAction: TextInputAction.send,
                              showCursor: true,
                              enabled: !isProcessing,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: isProcessing
                                    ? '${interfaceData["pwa"]}'
                                    : '${interfaceData["tam"]}',
                                hintStyle: AppStyle.txtPoppinsNormal16Gray500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConstant.blueNew,
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstant.blueNew.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                   
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorConstant.blueNew,
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstant.blueNew.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isProcessing ? Icons.refresh : Icons.send,
                        color: ColorConstant.whiteA700,
                        size: 20,
                      ),
                      onPressed: () {
                        if (!isProcessing && !_isResponseText) {
                          sendMsg();
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
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
      final int? userId = userid; //ADDUID// Thay thế bằng ID người dùng thực tế
      final int pageId = 14; // Thay thế bằng ID trang thực tế
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
