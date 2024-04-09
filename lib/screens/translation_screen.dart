import 'dart:async';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/DTO/settings.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/history_translation.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/utils/image_country_constant_1.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dashboard/widgets/app_bar/custom_bottom_app_bar.dart';
import 'package:dashboard/app_export.dart';
import 'package:translator/translator.dart';

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  Timer? _debounceTimer;
  String? positions;
  final translator = GoogleTranslator();
  bool isListeningPart1 = false;
  bool isListeningPart2 = false;
  DateTime? lastPostTime;
  final _textEditingController = TextEditingController();
  int Indexer = 0;
  String _translatedText = '';
  bool isPostSuccess = false;
  String _selectedLocaleId = 'en';
  String _selectedLocaleId1 = 'en';
  String _selectedLanguageDropdown = 'en-US';
  String? selectedCountryLabel = "English";
  String? selectedCountryValue = 'vi';
  String? selectedCountryLabel2 = "English";
  String? selectedCountryValue2 = 'en';
  String? langSession = '';
  List<Map<String, String>> countryList1 = [];
  List<Map<String, String>> countryList2 = [];
  int? userid;
  Map<String, String> textData = {};
  Map<String, String> data = {};
  Map<String, String> interfaceData = {};
  Setting? setting;
  String? token;
  int _selectedIndex = 1;

  int currentPageItem = 0;
  @override
  void initState() {
    _initializeToken();
    _debounceTimer = Timer(Duration(milliseconds: 2000), () {});
    _initialize();
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
        super.initState();
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
    await SessionManager.getUserid()
        .then((value) => {userid = int.tryParse(value ?? "@@")});
    print(userid);
    await fetchData(userid ?? 0).then((value) {
      setState(() {
        setting = value;
        if (setting != null) {
          selectedCountryLabel =
              '${data["${setting?.translationLanguageFrom}"]}';
          selectedCountryLabel2 =
              '${data["${setting?.translationLanguageTo}"]}';
          selectedCountryValue = setting?.translationLanguageFrom;
          selectedCountryValue2 = setting?.translationLanguageTo;
        } else {
          selectedCountryLabel = '${data["vi"]}';
          selectedCountryLabel2 = '${data["en"]}';
        }
      });
    });
  }

  String removePlusSign(String str) {
    return str.replaceAll('+', '');
  }

  Future<bool> AccessLogs() async {
    final String apiUrl =
        'http://api-languagefree.cosplane.asia/api/AccessLogs';
    final int? userId = userid; //ADDUID
    final int pageId = 5;
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
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onLocaleChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedLocaleId = value;
      });
    }
  }

  void _onLocaleChanged1(String? value) {
    if (value != null) {
      setState(() {
        _selectedLocaleId1 = value;
      });
      _translateText(
        _textEditingController.text,
        selectedCountryValue2!,
      );
    }
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

  List<Map<String, String>> _filterCountries2(String keyword) {
    print("Hello");
    var filteredCountries = getList1()
        .where((countryList2) => countryList2['label']!
            .toLowerCase()
            .contains(keyword.toLowerCase()))
        .toList();
    print(filteredCountries);
    if (filteredCountries.length == 0) {
      return [
        {'value': 'en', 'label': 'The Language does not exit!'}
      ];
    }
    return filteredCountries;
  }

  Future<Map<String, dynamic>> readFromFile(String fileName) async {
    try {
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      String filePath = '${appDocumentsDirectory.path}/lang/$fileName.json';
      File file = File(filePath);
      bool fileExists = await doesFileExist(fileName);
      if (!fileExists) {
        print('Not exist reading from file');
        return {};
      }
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

  Future<void> writeToFile(String fileName, Map<String, dynamic> data) async {
    try {
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      Directory langFolder = Directory('${appDocumentsDirectory.path}/lang');
      langFolder.createSync(recursive: true);
      File file = File('${langFolder.path}/$fileName.json');
      bool fileExists = await file.exists();
      if (!fileExists) {
        String jsonString = jsonEncode(data);
        await file.writeAsString(jsonString);
        print('Data saved to file: ${file.path}');
      } else {
        print('File already exists. Skipped writing to file.');
      }
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  Future<Setting> fetchData(int userid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    print('ID setting: $userid');
    String apiUrl =
        "http://api-languagefree.cosplane.asia/api/Settings/$userid";
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      return Setting.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data setting ');
    }
  }

  Future<void> loadData(String name) async {
    try {
      String jsonString =
          await rootBundle.loadString('lang/TranslateLang/$name.json');
      print("Decoded JSON: $jsonString");
      Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        data = jsonData.cast<String, String>();
        countryList1 = getList();
        countryList2 = getList1();
        if (setting != null) {
          selectedCountryLabel =
              '${data["${setting?.translationLanguageFrom}"]}';
          selectedCountryLabel2 =
              '${data["${setting?.translationLanguageTo}"]}';
          selectedCountryValue = setting?.translationLanguageFrom;
          selectedCountryValue2 = setting?.translationLanguageTo;
        } else {
          selectedCountryLabel = '${data["vi"]}';
          selectedCountryLabel2 = '${data["en"]}';
        }
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

  Future<bool> doesFileExist(String fileName) async {
    try {
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      String filePath = '${appDocumentsDirectory.path}/lang/$fileName.json';
      File file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      String filePath = '${appDocumentsDirectory.path}/lang/$fileName.json';
      File file = File(filePath);
      bool fileExists = await file.exists();
      if (fileExists) {
        await file.delete();
        print('File deleted: $filePath');
      } else {
        print('File does not exist. Skipped deleting file.');
      }
    } catch (e) {
      print('Error deleting file: $e');
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

  Future<bool> LanguageLogs(String value, bool fromOrTos) async {
    final String apiUrl =
        'http://api-languagefree.cosplane.asia/api/LanguageLogs';
    final int? userId = userid ?? 0; //ADDUID
    final int pageId = 5;
    final String location = positions ?? 'Unknown Location';
    final String languageTarget = value;
    final bool fromOrTo = fromOrTos;
    try {
      final Map<String, dynamic> requestData = {
        'userId': userId,
        'pageId': pageId,
        'languageTarget': languageTarget,
        'location': location,
        'fromOrTo': fromOrTo,
      };
      print('requestData: $requestData');

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

  Future<void> postTranslationHistory() async {
    if (_textEditingController.text.isEmpty) {
      Flushbar(
        margin: EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(8),
        message: '${interfaceData["etcba"]}',
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
      return;
    }
    final apiUrl =
        'http://api-languagefree.cosplane.asia/api/TranslationHistorys';
    final Map<String, dynamic> requestData = {
      'userId': userid,
      'pageId': 5,
      'sourceLanguage': selectedCountryLabel,
      'targetLanguage': selectedCountryLabel2,
      'sourceText': _textEditingController.text,
      'translatedText': _translatedText,
      'location': positions,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      print('Translation history posted successfully');
      setState(() {
        isPostSuccess = true;
      });
    } else {
      print(
          'Failed to post translation history. Status code: ${response.statusCode}');
      isPostSuccess = false;
    }
  }

  void _changeLanguageDropdown() async {
    setState(() {
      var tempLabel = selectedCountryLabel;
      var tempValue = selectedCountryValue;
      var tempText = _textEditingController.text;
      selectedCountryLabel = selectedCountryLabel2;
      selectedCountryLabel2 = tempLabel;
      selectedCountryValue = selectedCountryValue2;
      selectedCountryValue2 = tempValue;
      _textEditingController.text = _translatedText;
      _translatedText = tempText;
    });
  }

  @override
  Widget build(BuildContext context) {
    _copy() {
      final Value = ClipboardData(text: _textEditingController.text);
      Clipboard.setData(Value);
      print(Value);
    }

    _copy2() {
      final Valu = ClipboardData(text: _translatedText);
      Clipboard.setData(Valu);
      print(Valu);
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    GlobalKey<NavigatorState> navigatorKey = GlobalKey();
    return Scaffold(
      backgroundColor: ColorConstant.whiteA700,
      appBar: CustomAppBar(
        titleKey: '${interfaceData["tt"]}',
        currentPageItem: 0,
        leading1: IconButton(
          icon: Icon(Icons.feedback_rounded),
          color: ColorConstant.whiteA700,
          onPressed: () {
            _showDialogFeedback();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            left: screenWidth * 0.07, right: screenWidth * 0.07),
        child: Column(
          children: [
            SizedBox(
              height: screenWidth * 0.03,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
              decoration: BoxDecoration(
                color: ColorConstant.greyNew4,
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button(),
                  SizedBox(width: screenWidth * 0.16),
                  CustomImageView(
                    svgPath: ImageConstant.swap_horiz,
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    color: ColorConstant.black900,
                    onTap: () {
                      _changeLanguageDropdown();
                    },
                  ),
                  SizedBox(width: screenWidth * 0.16),
                  button1(),
                ],
              ),
            ),
            SizedBox(
              height: screenWidth * 0.03,
            ),
            Column(children: [
              Container(
                padding: getPadding(
                  top: screenWidth * 0.02,
                  right: screenWidth * 0.03,
                  left: screenWidth * 0.03,
                  bottom: screenWidth * 0.02,
                ),
                height: MediaQuery.of(context).size.width > 200
                    ? MediaQuery.of(context).size.height * 0.27
                    : MediaQuery.of(context).size.width * 0.45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: ColorConstant.grey, width: 1.0),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                ),
                child: Column(
                  children: [
                    Container(
                        height: screenHeight * 0.04,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '$selectedCountryLabel',
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
                              Container(
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                child: IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: Icon(
                                    Icons.history_sharp,
                                    color: ColorConstant.black900,
                                    size: screenWidth * 0.07,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HistoryScreen()),
                                    );
                                  },
                                ),
                              ),
                            ])),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: _textEditingController,
                              cursorHeight: screenHeight * 0.03,
                              keyboardType: TextInputType.multiline,
                              maxLines: 50,
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: '${interfaceData["et"]}',
                                border: InputBorder.none,
                                labelStyle: AppStyle.txtPoppinsMedium18Black900
                                    .copyWith(
                                  color: ColorConstant.black900,
                                ),
                                hintStyle: AppStyle.txtPoppinsMedium15.copyWith(
                                  color: ColorConstant.gray500,
                                ),
                              ),
                              onChanged: (String value) {
                                _debounceTimer?.cancel();
                                _debounceTimer =
                                    Timer(Duration(seconds: 0), () {
                                  _translateText(
                                    _textEditingController.text,
                                    selectedCountryValue2!,
                                  );
                                });
                              },
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
            SizedBox(
              height: screenWidth * 0.03,
            ),
            Column(children: [
              SizedBox(
                height: screenWidth * 0.01,
              ),
              Container(
                padding: getPadding(
                  top: screenWidth * 0.02,
                  right: screenWidth * 0.03,
                  left: screenWidth * 0.03,
                  bottom: screenWidth * 0.02,
                ),
                height: MediaQuery.of(context).size.width > 200
                    ? MediaQuery.of(context).size.height * 0.27
                    : MediaQuery.of(context).size.width * 0.45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: ColorConstant.grey, width: 1.0),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                ),
                child: Column(
                  children: [
                    Container(
                        height: screenHeight * 0.04,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
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
                              Container(
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                child: IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: Icon(
                                    Icons.star_border,
                                    color: ColorConstant.black900,
                                    size: screenWidth * 0.07,
                                  ),
                                  onPressed: () async {
                                    if (lastPostTime == null ||
                                        DateTime.now()
                                                .difference(lastPostTime!) >=
                                            Duration(seconds: 10)) {
                                      await postTranslationHistory(); // Assuming postTranslationHistory is an asynchronous function
                                      if (isPostSuccess) {
                                        isPostSuccess = false;
                                        lastPostTime = DateTime.now();
                                        Flushbar(
                                          margin: EdgeInsets.all(15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          message: '${interfaceData["atfls"]}',
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
                                          leftBarIndicatorColor:
                                              Colors.green[800],
                                        ).show(context);
                                      }
                                    } else {
                                      Flushbar(
                                        margin: EdgeInsets.all(15),
                                        borderRadius: BorderRadius.circular(8),
                                        message: '${interfaceData["pwstaa"]}',
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
                                  },
                                ),
                              ),
                            ])),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: TextField(
                                    controller: TextEditingController(
                                        text: '$_translatedText'),
                                    readOnly: true,
                                    cursorHeight: screenHeight * 0.03,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 50,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      border: InputBorder.none,
                                      labelStyle: AppStyle
                                          .txtPoppinsMedium18Black900
                                          .copyWith(
                                        color: ColorConstant.black900,
                                      ),
                                      hintStyle:
                                          AppStyle.txtPoppinsMedium15.copyWith(
                                        color: ColorConstant.gray500,
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
                              _copy2();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            SizedBox(
              height: screenWidth * 0.02,
            ),
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

  Future<void> _translateText(String inputText, String targetLanguage) async {
    inputText = inputText.trim();
    if (inputText.isNotEmpty) {
      try {
        final translation =
            await translator.translate(inputText, to: targetLanguage);
        setState(() {
          _translatedText = translation.toString();
        });
      } catch (e) {
        print('Translation error: $e');
      }
    }
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

  void updateSelectedCountry(String? label, String? value) {
    if (label != "The Language does not exit!") {
      setState(() {
        selectedCountryLabel = label;
        selectedCountryValue = value;
      });
      print("Huy111111111111111111111 $value");
      LanguageLogs(value!, true);
      SessionManager.updateSession(translationLanguageFrom: value);
    }
  }

  Widget button() {
    double buttonWidth = MediaQuery.of(context).size.width * 0.15;
    double buttonHeight = MediaQuery.of(context).size.width * 0.15;

    return GestureDetector(
      onTap: () {
        _showLanguageDialog(context, updateSelectedCountry);
      },
      child: _getFlagIcon(selectedCountryValue!),
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
                              countryList1 = _filterCountries1(value);
                              print('list hahahahahahahah $countryList1');
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
                          itemCount: countryList1.length,
                          itemBuilder: (BuildContext context, int index) {
                            final country = countryList1[index];
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
      'ca': ImageCountry1Constant.Spain,
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

  void updateSelectedCountry1(String? label, String? value) {
    if (label != "The Language does not exit!") {
      setState(() {
        selectedCountryLabel2 = label;
        selectedCountryValue2 = value;
      });
      LanguageLogs(value!, false);
      _translateText(
        _textEditingController.text,
        selectedCountryValue2!,
      );
      SessionManager.updateSession(translationLanguageTo: value);
    }
  }

  Widget button1() {
    double buttonWidth = MediaQuery.of(context).size.width * 0.15;
    double buttonHeight = MediaQuery.of(context).size.width * 0.15;

    return GestureDetector(
      onTap: () {
        _showLanguageDialog1(context, updateSelectedCountry1);
      },
      child: _getFlagIcon1(selectedCountryValue2!),
    );
  }

  void _showLanguageDialog1(
      BuildContext context, Function(String?, String?) updateSelectedCountry) {
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
                                  'Language',
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
                              countryList2 = _filterCountries2(value);
                              print('list hahahahahahahah $countryList2');
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
                          itemCount: countryList2.length,
                          itemBuilder: (BuildContext context, int index) {
                            final country = countryList2[index];
                            print(country);
                            return Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: GestureDetector(
                                onTap: () async {
                                  updateSelectedCountry(
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
                                        _getFlagIcon1(country['value']!),
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

  Widget _getFlagIcon1(String countryCode) {
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

  List<Map<String, String>> getList1() {
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

  void _showDialogFeedback() {
    String? _inputText;
    Future<void> postComment() async {
      final String apiUrl =
          'http://api-languagefree.cosplane.asia/api/Comments'; // Thay thế bằng đường dẫn thực tế của API của bạn
      final String comment = _inputText!;

      // Assuming user_id, page_id, and location are known values (you need to adapt this based on your app logic)
      final int? userId =
          userid; //ADDUID // Thay thế bằng ID người dùng thực tế
      final int pageId = 5; // Thay thế bằng ID trang thực tế
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

class AnchoredFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(scaffoldGeometry.scaffoldSize.width / 2.4,
        scaffoldGeometry.scaffoldSize.height - 80.0);
  }

  const AnchoredFabLocation();
}
