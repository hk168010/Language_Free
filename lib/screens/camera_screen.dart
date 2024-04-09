import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:camera/camera.dart';
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/DTO/settings.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/theme/app_style.dart';
import 'package:dashboard/utils/color_constant.dart';
import 'package:dashboard/utils/image_country_constant_1.dart';
import 'package:dashboard/utils/size_utils.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar.dart';
import 'package:dashboard/widgets/app_bar/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as mlkit;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  String? positions;
  Timer? _debounceTimer;
  final translator = GoogleTranslator();
  bool isListeningPart1 = false;
  final _textEditingController = TextEditingController();
  int Indexer = 0;
  String _translatedText = '';
  String? token;
  // String _selectedInputLanguage = 'Vietnamese';
  // String _selectedOutputLanguage = 'Japanese';
  String _selectedLocaleId = 'en';
  String _selectedLanguageDropdown = 'en-US';
  String? selectedCountryLabel2 = "English";
  String? selectedCountryValue = 'vi';
  int _selectedIndex = 1;
  // String? langSession = '';
  late List<Map<String, String>> countryList;
  int? userid; //ADDUID
  File? selectedMedia;
  late CameraController? _controller;
  bool _isCameraReady = false;
  late String selectedValue;
  Setting? setting;
  List<Map<String, String>> getList() {
    return [
      {'value': 'af', 'label': '${data["af"].toString()}'},
      {'value': 'sq', 'label': '${data["sq"].toString()}'},
      {'value': 'am', 'label': '${data["am"].toString()}'},
      {'value': 'ar', 'label': '${data["ar"].toString()}'},
      {'value': 'hy', 'label': '${data["hy"].toString()}'},
      {'value': 'az', 'label': '${data["az"].toString()}'},
      {'value': 'eu', 'label': '${data["eu"].toString()}'},
      {'value': 'bn', 'label': '${data["bn"].toString()}'},
      {'value': 'bg', 'label': '${data["bg"].toString()}'},
      {'value': 'ca', 'label': '${data["ca"].toString()}'},
      {'value': 'zh-cn', 'label': '${data["zh-cn"].toString()}'},
      {'value': 'zh-tw', 'label': '${data["zh-tw"].toString()}'},
      {'value': 'hr', 'label': '${data["hr"].toString()}'},
      {'value': 'cs', 'label': '${data["cs"].toString()}'},
      {'value': 'da', 'label': '${data["da"].toString()}'},
      {'value': 'nl', 'label': '${data["nl"].toString()}'},
      {'value': 'en', 'label': '${data["en"].toString()}'},
      {'value': 'et', 'label': '${data["et"].toString()}'},
      {'value': 'fi', 'label': '${data["fi"].toString()}'},
      {'value': 'fr', 'label': '${data["fr"].toString()}'},
      {'value': 'gl', 'label': '${data["gl"].toString()}'},
      {'value': 'ka', 'label': '${data["ka"].toString()}'},
      {'value': 'de', 'label': '${data["de"].toString()}'},
      {'value': 'el', 'label': '${data["el"].toString()}'},
      {'value': 'gu', 'label': '${data["gu"].toString()}'},
      {'value': 'iw', 'label': '${data["iw"].toString()}'},
      {'value': 'hi', 'label': '${data["hi"].toString()}'},
      {'value': 'hu', 'label': '${data["hu"].toString()}'},
      {'value': 'is', 'label': '${data["is"].toString()}'},
      {'value': 'id', 'label': '${data["id"].toString()}'},
      {'value': 'it', 'label': '${data["it"].toString()}'},
      {'value': 'ja', 'label': '${data["ja"].toString()}'},
      {'value': 'kn', 'label': '${data["kn"].toString()}'},
      {'value': 'kk', 'label': '${data["kk"].toString()}'},
      {'value': 'km', 'label': '${data["km"].toString()}'},
      {'value': 'ko', 'label': '${data["ko"].toString()}'},
      {'value': 'lo', 'label': '${data["lo"].toString()}'},
      {'value': 'lv', 'label': '${data["lv"].toString()}'},
      {'value': 'lt', 'label': '${data["lt"].toString()}'},
      {'value': 'mk', 'label': '${data["mk"].toString()}'},
      {'value': 'ms', 'label': '${data["ms"].toString()}'},
      {'value': 'ml', 'label': '${data["ml"].toString()}'},
      {'value': 'mr', 'label': '${data["mr"].toString()}'},
      {'value': 'mn', 'label': '${data["mn"].toString()}'},
      {'value': 'my', 'label': '${data["my"].toString()}'},
      {'value': 'ne', 'label': '${data["ne"].toString()}'},
      {'value': 'fa', 'label': '${data["fa"].toString()}'},
      {'value': 'pl', 'label': '${data["pl"].toString()}'},
      {'value': 'pt', 'label': '${data["pt"].toString()}'},
      {'value': 'pa', 'label': '${data["pa"].toString()}'},
      {'value': 'ro', 'label': '${data["ro"].toString()}'},
      {'value': 'ru', 'label': '${data["ru"].toString()}'},
      {'value': 'sr', 'label': '${data["sr"].toString()}'},
      {'value': 'st', 'label': '${data["st"].toString()}'},
      {'value': 'si', 'label': '${data["si"].toString()}'},
      {'value': 'sk', 'label': '${data["sk"].toString()}'},
      {'value': 'sl', 'label': '${data["sl"].toString()}'},
      {'value': 'es', 'label': '${data["es"].toString()}'},
      {'value': 'sw', 'label': '${data["sw"].toString()}'},
      {'value': 'sv', 'label': '${data["sv"].toString()}'},
      {'value': 'ta', 'label': '${data["ta"].toString()}'},
      {'value': 'te', 'label': '${data["te"].toString()}'},
      {'value': 'th', 'label': '${data["th"].toString()}'},
      {'value': 'tr', 'label': '${data["tr"].toString()}'},
      {'value': 'uk', 'label': '${data["uk"].toString()}'},
      {'value': 'ur', 'label': '${data["ur"].toString()}'},
      {'value': 'uz', 'label': '${data["uz"].toString()}'},
      {'value': 'vi', 'label': '${data["vi"].toString()}'},
      {'value': 'xh', 'label': '${data["xh"].toString()}'},
      {'value': 'zu', 'label': '${data["zu"].toString()}'},
    ];
  }

  Widget _getFlagIcon(String countryCode) {
    Map<String, String> flagIcons = {
      'af': ImageCountry1Constant.South_Africa,
      'sq': ImageCountry1Constant.Albania,
      'am': ImageCountry1Constant.Ethiopia,
      'ar': ImageCountry1Constant.ARap,
      'az': ImageCountry1Constant.Azerbaijan,
      'hy': ImageCountry1Constant.Armenia,
      'eu': ImageCountry1Constant.Basque,
      'bn': ImageCountry1Constant.Bengali,
      'bg': ImageCountry1Constant.Bulgaria,
      'ca': ImageCountry1Constant.Catalan,
      'zh-cn': ImageCountry1Constant.China,
      'kn': ImageCountry1Constant.Kanada,
      'zh-tw': ImageCountry1Constant.Taiwan,
      'hr': ImageCountry1Constant.Croatia,
      'cs': ImageCountry1Constant.Czech_Republic,
      'da': ImageCountry1Constant.Denmark,
      'nl': ImageCountry1Constant.Netherlands,
      'en': ImageCountry1Constant.United_Kingdom,
      'et': ImageCountry1Constant.Estonia,
      'fi': ImageCountry1Constant.Finland,
      'fr': ImageCountry1Constant.France1,
      'gl': ImageCountry1Constant.Spain,
      'ka': ImageCountry1Constant.Georgian,
      'de': ImageCountry1Constant.Germany,
      'el': ImageCountry1Constant.Greece,
      'gu': ImageCountry1Constant.India,
      'iw': ImageCountry1Constant.Israel,
      'hi': ImageCountry1Constant.India,
      'hu': ImageCountry1Constant.Hungary,
      'is': ImageCountry1Constant.Iceland,
      'id': ImageCountry1Constant.Indonesia,
      'it': ImageCountry1Constant.Italy,
      'ja': ImageCountry1Constant.Japan,
      'kk': ImageCountry1Constant.Kazakhstan,
      'km': ImageCountry1Constant.Cambodia,
      'ko': ImageCountry1Constant.Korea,
      'lo': ImageCountry1Constant.Laos,
      'lv': ImageCountry1Constant.Latvia,
      'lt': ImageCountry1Constant.Lithuania,
      'mk': ImageCountry1Constant.NorthMacedonia,
      'ms': ImageCountry1Constant.Malaysia,
      'ml': ImageCountry1Constant.India,
      'mr': ImageCountry1Constant.India,
      'mn': ImageCountry1Constant.Mongolia,
      'my': ImageCountry1Constant.Myanmar,
      'ne': ImageCountry1Constant.Nepal,
      'fa': ImageCountry1Constant.Iran,
      'pl': ImageCountry1Constant.Poland,
      'pt': ImageCountry1Constant.Brazil,
      'pa': ImageCountry1Constant.India,
      'ro': ImageCountry1Constant.Romania,
      'ru': ImageCountry1Constant.Russia,
      'sr': ImageCountry1Constant.Serbia1,
      'st': ImageCountry1Constant.Lesotho,
      'si': ImageCountry1Constant.Sri_Lanka,
      'sk': ImageCountry1Constant.Slovakia,
      'sl': ImageCountry1Constant.Slovenia,
      'es': ImageCountry1Constant.Spain,
      'sw': ImageCountry1Constant.Swahili,
      'sv': ImageCountry1Constant.Sweden,
      'ta': ImageCountry1Constant.Sri_Lanka,
      'te': ImageCountry1Constant.India,
      'th': ImageCountry1Constant.Thailand,
      'tr': ImageCountry1Constant.Turkiye,
      'uk': ImageCountry1Constant.Ukraine,
      'ur': ImageCountry1Constant.Pakistan,
      'uz': ImageCountry1Constant.Uzbekistan,
      'vi': ImageCountry1Constant.Vietnam,
      'xh': ImageCountry1Constant.South_Africa,
      'zu': ImageCountry1Constant.South_Africa,
    };
    String imagePath = flagIcons[countryCode] ?? '';
    return imagePath.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: Image.asset(
              imagePath,
              width: 45,
              height: 45,
              fit: BoxFit.cover,
            ))
        : Icon(Icons.flag);
  }

  //ADDUID
  String removePlusSign(String str) {
    return str.replaceAll('+', '');
  }

  List<Map<String, String>> _filterCountries1(String keyword) {
    print("Hello");
    var filteredCountries = getList()
        .where((countryList1) => countryList1['label']!
            .toLowerCase()
            .contains(keyword.toLowerCase()))
        .toList();
    print(filteredCountries);
    if (filteredCountries.length == 0) {
      return [
        {'value': 'vi', 'label': 'The Language does not exit!'}
      ];
    }
    return filteredCountries;
  }

  late Language _selectedLanguage;
  Map<String, String> textData = {};
  Map<String, String> data = {};
  Map<String, String> interfaceData = {};
  String? langSession = '';
  int currentPageItem = 0;

  Future<Map<String, dynamic>> readFromFile(String name) async {
    try {
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      String filePath = '${appDocumentsDirectory.path}/lang/$name.json';
      File file = File(filePath);
      // bool fileExists = await doesFileExist(fileName);
      // if (!fileExists) {
      //   print('Not exist reading from file');
      //   return {};
      // }
      String jsonString = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      print('Data read from file: $jsonData');
      setState(() {
        textData = jsonData.cast<String, String>();
      });
      return jsonData;
    } catch (e) {
      print('Error reading from file: $e');
      return {};
    }
  }

  @override
  void initState() {
    _initializeToken();
    super.initState();
    _selectedLanguage = new Language(value: 'en', label: 'English');
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
    _initializeController();
    _initialize();
    SessionManager.getUserid()
        .then((value) => {userid = int.tryParse(value ?? "@@")});
    print(userid);
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    AccessLogs();
    await fetchData(userid ?? 0).then((value) {
      setState(() {
        setting = value;
        if (setting != null) {
          selectedCountryLabel2 = '${data["${setting?.pictureLangTo}"]}';
          selectedCountryValue = setting?.pictureLangTo;
          _selectedLanguage.label = '${data["${setting?.pictureLangTo}"]}';
          _selectedLanguage.value = setting!.pictureLangTo;
        } else {
          selectedCountryLabel2 = '${data["en"]}';
        }
      });
    });
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
    final int? userId = userid ?? 0; //ADDUID
    final int pageId = 7;
    final String location = positions ?? 'Unknown Location';
    try {
      final Map<String, dynamic> requestData = {
        'userId': userId,
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
      await SessionManager.getUserid().then((value) {
        setState(() {
          userid = int.tryParse(value ?? "@@");
        });
      });
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

  Future<bool> LanguageLogs(String value, bool fromOrTos) async {
    final String apiUrl =
        'http://api-languagefree.cosplane.asia/api/LanguageLogs';
    final int? userId = userid; //ADDUID
    final int pageId = 7;
    final String location = positions ?? 'Unknown Location';
    final String languageTarget = value;
    final bool fromOrTo = fromOrTos;
    try {
      final Map<String, dynamic> requestData = {
        'userId': userId ?? 0,
        'pageId': pageId,
        'languageTarget': languageTarget,
        'location': location,
        'fromOrTo': fromOrTo,
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

  Future<Setting> fetchData(int userid) async {
    print('ID setting: $userid');
    String apiUrl =
        "http://api-languagefree.cosplane.asia/api/Settings/$userid";
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      return Setting.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data setting ');
    }
  }

  Future<void> loadData(String name) async {
    final jsonString =
        await rootBundle.loadString('lang/TranslateLang/$name.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      data = jsonData.cast<String, String>();
      countryList = getList();
      if (setting != null) {
        selectedCountryLabel2 = '${data["${setting?.pictureLangTo}"]}';
        selectedCountryValue = setting?.pictureLangTo;
        _selectedLanguage.label = '${data["${setting?.pictureLangTo}"]}';
        _selectedLanguage.value = setting!.pictureLangTo;
      } else {
        selectedCountryLabel2 = '${data["en"]}';
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
    double screenHeight = MediaQuery.of(context).size.height;
    _copy() {
      final Value = ClipboardData(text: _translatedText);
      Clipboard.setData(Value);
      print(Value);
    }

    return Scaffold(
      backgroundColor: ColorConstant.whiteA700,
      appBar: CustomAppBar(
        titleKey: '${interfaceData["img"]}',
        currentPageItem: 2,
        leading1: IconButton(
          icon: Icon(Icons.feedback_rounded),
          color: ColorConstant.whiteA700,
          onPressed: () {
            _showDialogFeedback();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenWidth * 0.02,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: screenWidth * 0.80,
                height: screenHeight * 0.315,
                decoration: BoxDecoration(
                  color: ColorConstant.greyNew4,
                  border: Border.all(color: ColorConstant.blueNew, width: 2.0),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    selectedMedia != null
                        ? ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7.0)),
                            child: Image.file(
                              selectedMedia!,
                              fit: BoxFit.cover,
                              width: screenWidth * 0.78,
                              height: screenHeight * 0.303,
                            ),
                          )
                        : _isCameraReady
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => _pickImage(),
                                    child: Icon(
                                      Icons.upload_file_rounded,
                                      color: ColorConstant.blueNew,
                                      size: screenWidth * 0.2,
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenWidth * 0.03,
                                  ),
                                  Text(
                                    '${interfaceData["uab"]}.',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: screenWidth * 0.035),
                                  )
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: screenWidth * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Ink(
                  decoration: ShapeDecoration(
                    color: ColorConstant.blueNew, // Màu nền của Ink
                    shape: CircleBorder(), // Hình dạng của nút là hình tròn
                  ),
                  child: IconButton(
                    onPressed: () {
                      _captureImage();
                    },
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      color: ColorConstant.whiteA700,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.08,
                ),
                button(),
                SizedBox(
                  width: screenWidth * 0.08,
                ),
                Ink(
                  decoration: ShapeDecoration(
                    color: ColorConstant.blueNew,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _pickImage();
                    },
                    icon: Icon(
                      Icons.upload_file_rounded,
                      color: ColorConstant.whiteA700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenWidth * 0.03,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.07, right: screenWidth * 0.07),
              child: Column(children: [
                Container(
                  padding: getPadding(
                    top: screenWidth * 0.02,
                    right: screenWidth * 0.03,
                    left: screenWidth * 0.03,
                    bottom: screenWidth * 0.02,
                  ),
                  height: MediaQuery.of(context).size.width > 210
                      ? MediaQuery.of(context).size.height * 0.32
                      : MediaQuery.of(context).size.width * 0.50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: ColorConstant.grey, width: 1.0),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                          height: screenHeight * 0.05,
                          child: Column(children: [
                            Flexible(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '$selectedCountryLabel2',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyle.txtPoppinsMedium15WhiteA200
                                      .copyWith(
                                          fontSize: screenWidth * 0.05,
                                          color: ColorConstant.blueNew,
                                          fontWeight: FontWeight.w200),
                                ),
                              ),
                            ),
                          ])),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  _extractTextView(),
                                  _translatedTextView(),
                                ],
                              ),
                            ),
                          ],
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
              ]),
            ),
            SizedBox(
              height: screenWidth * 0.02,
            )
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

  Widget _extractTextView() {
    if (selectedMedia == null) {
      return Container(
        alignment: Alignment.bottomLeft,
        child: Text(
          '${interfaceData["uab"]}.',
          style: AppStyle.txtPoppinsMedium15.copyWith(
            color: ColorConstant.gray500,
          ),
        ),
      );
    }
    return FutureBuilder(
      future: _extractAndTranslateText(selectedMedia!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          return Text('Error1: ${snapshot.error}');
        } else {
          return Text(
            snapshot.data ?? "",
            style: const TextStyle(
              fontSize: 15,
            ),
          );
        }
      },
    );
  }

  Widget _translatedTextView() {
    double screenWidth = MediaQuery.of(context).size.width;
    if (_translatedText.isEmpty) {
      return SizedBox.shrink();
    }
    return Container(
      width: screenWidth,
      height: screenWidth * 0.30,
      child: SingleChildScrollView(
        child: Text(
          textAlign: TextAlign.left,
          "$_translatedText",
          style: TextStyle(
            fontSize: screenWidth * 0.04,
          ),
        ),
      ),
    );
  }

  Future<String?> _extractAndTranslateText(File file) async {
    final List<String> languages = [
      'chinese',
      'japanese',
      'devanagiri',
      'korean'
    ];

    List<String> results = [];

    for (String language in languages) {
      final mlkit.TextRecognitionScript script =
          determineScriptForLanguage(language);

      final textRecognizer = mlkit.TextRecognizer(script: script);
      final mlkit.InputImage inputImage = mlkit.InputImage.fromFile(file);

      try {
        final mlkit.RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);

        String result = '';

        for (mlkit.TextBlock block in recognizedText.blocks) {
          for (mlkit.TextLine line in block.lines) {
            result += line.text + '\n';
          }
        }

        results.add(result);
      } catch (e) {
        print('Error extracting text for language $language: $e');
      } finally {
        textRecognizer.close();
      }
    }

    String bestResult = _selectBestResult(results);
    await _translateText(bestResult, _selectedLanguage.value);

    return bestResult;
  }

  String _selectBestResult(List<String> results) {
    String bestResult = '';
    int maxLength = 0;

    for (String result in results) {
      if (result.length > maxLength) {
        maxLength = result.length;
        bestResult = result;
      }
    }

    return bestResult;
  }

  Future<void> _translateText(String inputText, String targetLanguage) async {
    inputText = inputText.trim();
    if (inputText.isNotEmpty) {
      try {
        final translation =
            await translator.translate(inputText, to: targetLanguage);
        setState(() {
          _translatedText = translation.toString();
        });
        print(translation);
      } catch (e) {
        print('Translation error: $e');
      }
    }
  }

  mlkit.TextRecognitionScript determineScriptForLanguage(String language) {
    if (language.toLowerCase().compareTo('chinese') == 0) {
      return mlkit.TextRecognitionScript.chinese;
    } else if (language.toLowerCase().compareTo('japanese') == 0) {
      return mlkit.TextRecognitionScript.japanese;
    } else if (language.toLowerCase().compareTo('devanagiri') == 0) {
      return mlkit.TextRecognitionScript.devanagiri;
    } else if (language.toLowerCase().compareTo('korean') == 0) {
      return mlkit.TextRecognitionScript.korean;
    } else {
      return mlkit.TextRecognitionScript.latin;
    }
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile? image =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (image != null) {
          setState(() {
            selectedMedia = File(image.path);
          });
        }
      } catch (e) {
        print('$e');
      }
    } else {
      print('_controller is not initialized.');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          selectedMedia = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _initializeController() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    await _controller?.initialize();
    setState(() {
      _isCameraReady = true;
    });
  }

  Widget _buildSearchBar() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
      child: TextField(
        style: TextStyle(color: ColorConstant.black900),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: '${interfaceData["sfl"]}',
          hintStyle: AppStyle.txtPoppinsMedium18Grey_1,
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }

  void updateSelectedCountry1(String? label, String? value) {
    if (label != "The Language does not exit!") {
      setState(() {
        _selectedLanguage.label = label!;
        _selectedLanguage.value = value!;
        selectedCountryLabel2 = label;
      });
      LanguageLogs(value!, false);
      SessionManager.updateSession(pictureLangTo: value);
    }
  }

  Widget button() {
    double buttonWidth = MediaQuery.of(context).size.width * 0.4;
    double buttonHeight = MediaQuery.of(context).size.width * 0.15;
    double widthsize = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(top: widthsize * 0.02, bottom: widthsize * 0.02),
      height: buttonHeight,
      width: buttonWidth,
      decoration: BoxDecoration(
          color: ColorConstant.blueNew,
          borderRadius: BorderRadius.all(Radius.circular(widthsize * 0.1))),
      child: Center(
        child: GestureDetector(
          onTap: () {
            _showLanguageDialog(context, updateSelectedCountry1);
          },
          child: _getFlagIcon(_selectedLanguage.value),
        ),
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context,
      Function(String?, String?) updateSelectedCountry1) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: FractionallySizedBox(
                widthFactor: 1.06,
                heightFactor: 0.98,
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: ColorConstant.greyNew3,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: screenWidth * 0.1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: screenWidth * 0.55,
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.12),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '${interfaceData["lg"]}',
                                  style: AppStyle.txtPoppinsSemiBold20Black900,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                weight: screenWidth * 0.9,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenWidth * 0.05,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 9,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          style: AppStyle.txtPoppinsMedium18Black900_1,
                          onChanged: (value) {
                            setState(() {
                              countryList = _filterCountries1(value);
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '${interfaceData["sfl"]}',
                            hintStyle: AppStyle.txtPoppinsMedium18Grey_1,
                            contentPadding: EdgeInsets.all(10.0),
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: countryList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final country = countryList[index];
                            print(country);
                            return Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  updateSelectedCountry1(
                                      country['label'], country['value']);
                                  Navigator.of(context).pop();
                                },
                                child: DropdownMenuItem<String>(
                                  value: country['value'],
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: screenWidth * 0.02,
                                        bottom: screenWidth * 0.02,
                                        left: screenWidth * 0.02,
                                        right: screenWidth * 0.02),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: ColorConstant.whiteA700,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.03),
                                    ),
                                    child: Row(
                                      children: [
                                        _getFlagIcon(country['value']!),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            country['label']!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: ColorConstant.black900),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
      final int pageId = 7; // Thay thế bằng ID trang thực tế
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

class Language {
  String value;
  String label;
  Language({
    required this.value,
    required this.label,
  });
}
