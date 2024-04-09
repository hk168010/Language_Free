import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/DTO/settings.dart';
import 'package:dashboard/DTO/uservoices.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/utils/image_country_constant_1.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dashboard/app_export.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dashboard/widgets/app_bar/custom_bottom_app_bar.dart';
import 'package:translator/translator.dart';

class SpeedScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<SpeedScreen>
    with SingleTickerProviderStateMixin {
  String? positions;
  Timer? _debounceTimer;
  String Perpader = "";
  String mapLang = "";
  bool isPlay1 = false;
  bool isPlay2 = false;
  int? userid; //ADDUID
  bool isListeningPart1 = false;
  bool isListeningPart2 = false;
  TextEditingController _textEditingController1 = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();
  int Indexer = 0;
  String? selectedCountryLabel = "English";
  String? selectedCountryValue = 'vi_VN';
  String? selectedCountryLabel2 = "English";
  final translator = GoogleTranslator();
  final translator2 = GoogleTranslator();
  Duration delayDuration = Duration(seconds: 5);
  String? selectedCountryValue2 = 'en_GB';
  // String _selectedInputLanguage = 'Vietnamese';
  // String _selectedOutputLanguage = 'Japanese';
  Map<String, String> textData = {};
  Map<String, String> data = {};
  Map<String, String> interfaceData = {};
  UserVoice? _uservoice;
  int _selectedIndex = 1;
  late int currentPageItem;
  late stt.SpeechToText _speech;
  final AudioCache _audioCache = AudioCache();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _audioPlayer2 = AudioPlayer();
  bool _isListening = false;
  bool _isInitializing = false;
  bool _isListening2 = false;
  String voiceType = 'alloy';
  bool _isInitializing2 = false; // Add this flag
  String _text = '';
  late AnimationController _animationController;
  late Animation<Color?> _animation;
  String _text2 = '';
  late AnimationController _animationController2;
  late Animation<Color?> _animation2;
  List<Map<String, String>> countryList1 = [];
  List<Map<String, String>> countryList2 = [];
  String? langSession = '';
  FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  bool isSpeaking2 = false;
  Setting? setting;
  String? token;
  List<bool> showLabels = [true, true, true];
  void updateLabel(int index) {
    setState(() {
      for (int i = 0; i < showLabels.length; i++) {
        showLabels[i] = (i == index) ? !showLabels[i] : true;
      }
    });
  }

  void _changeLanguageDropdown() async {
    setState(() {
      var tempLabel = selectedCountryLabel;
      var tempValue = selectedCountryValue;
      var tempText = _textEditingController1.text;
      selectedCountryLabel = selectedCountryLabel2;
      selectedCountryLabel2 = tempLabel;
      selectedCountryValue = selectedCountryValue2;
      selectedCountryValue2 = tempValue;
      _textEditingController1.text = _textEditingController2.text;
      _textEditingController2.text = tempText;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool _isAppListen1 = false;
  bool _isAppListen2 = false;

  bool _animate = false;
  bool _animate2 = false;
  @override
  void initState() {
    _initializeToken();
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
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
      }
    });
    _animation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_animationController);
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
    await fetchUserVoice(userid ?? 0);
    AccessLogs();
    await fetchData(userid ?? 0).then((value) {
      setState(() {
        setting = value;
        if (setting != null) {
          String label1 =
              mapLanguage(setting?.conversationLanguageFrom ?? "@@").toLowerCase();
          String label2 = mapLanguage(setting?.conversationLanguageTo ?? "@@").toLowerCase();
          selectedCountryLabel = '${data["$label1"]}';
          selectedCountryLabel2 = '${data["$label2"]}';
          selectedCountryValue = setting?.conversationLanguageFrom;
          selectedCountryValue2 = setting?.conversationLanguageTo;
        } else {
          selectedCountryLabel = '${data["vi"]}';
          selectedCountryLabel2 = '${data["en"]}';
        }
      });
    });
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

  String mapVoiceType(String? gender, DateTime? dateOfBirth) {
    int ye = dateOfBirth?.year ?? 2002;
    int age = DateTime.now().year - ye;

    if (gender == "Male") {
      if (age >= 6 && age <= 17) {
        return "alloy";
      } else if (age >= 18 && age <= 39) {
        return "fable";
      } else if (age >= 40 && age <= 70) {
        return "onyx";
      }
    } else if (gender == "Female") {
      if (age >= 6 && age <= 39) {
        return "nova";
      } else if (age >= 40 && age <= 70) {
        return "shimmer";
      }
    }
    return "alloy";
  }

  Future<void> fetchUserVoice(int id) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(
        Uri.parse(
            'http://api-languagefree.cosplane.asia/api/Users/getByUserVoice/$id'),
        headers: headers);

    if (response.statusCode == 200) {
      setState(() {
        _uservoice = UserVoice.fromJson(jsonDecode(response.body));
        print("request uservoice: ${_uservoice?.gender}");
      });
    } else {
      throw Exception('Failed to load user voice ${response.statusCode}' );
    }
  }

  Future<bool> AccessLogs() async {
    final String apiUrl =
        'http://api-languagefree.cosplane.asia/api/AccessLogs';
    final int? userId = userid; //ADDUID
    final int pageId = 6;
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
        if (setting != null) {
          selectedCountryLabel =
              '${data["${setting?.conversationLanguageFrom}"]}';
          selectedCountryLabel2 =
              '${data["${setting?.conversationLanguageTo}"]}';
          selectedCountryValue = setting?.conversationLanguageFrom;
          selectedCountryValue2 = setting?.conversationLanguageTo;
        } else {
          selectedCountryLabel = '${data["vi"]}';
          selectedCountryLabel2 = '${data["en"]}';
        }
        countryList1 = getList();
        countryList2 = getList1();

        print(countryList1);
      });
    } catch (error) {
      print("Error loading JSON: $error");
    }
  }

  void _listen(String localeId) async {
    setState(() {
      _isAppListen1 = true;
    });
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) async {
          print('Status: $status');
          if (status == 'done') {
            setState(() {
              _speech.cancel();
              _isListening = false;
              _animationController.stop();
              _animate = false;
              _isAppListen1 = false;
            });
          }
        },
        onError: (errorNotification) =>
            print('ErrorNotification: $errorNotification'),
      );
      setState(() {
        _isInitializing = false;
      });

      if (available) {
        setState(() {
          _isListening = true;
          _animationController.repeat();
          _animate = true;
        });

        _speech.listen(
          onResult: (result) async {
            setState(() {
              _textEditingController1.text = result.recognizedWords;
            });
            print(selectedCountryLabel);
            mapLang = mapLanguage(selectedCountryValue2!);
            await _translateText1(_textEditingController1.text, mapLang);
          },
          listenFor: Duration(minutes: 5),
          localeId: localeId,
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _animationController.stop();
        _speech.cancel(); // Stop listening
        _animate = false;
        _isAppListen1 = false;
      });
    }
  }

  String mapLanguage(String inputLanguage) {
    switch (inputLanguage) {
      case 'af_ZA':
        return 'af';
      case 'sq_AL':
        return 'sq';
      case 'am_ET':
        return 'am';
      case 'ar_EG':
        return 'ar';
      case 'az_AZ':
        return 'az';
      case 'hy_AM':
        return 'hy';
      case 'eu_ES':
        return 'eu';
      case 'bn_IN':
        return 'bn';
      case 'bg_BG':
        return 'bg';
      case 'ca_ES':
        return 'ca';
      case 'cmn_CN':
        return 'zh-CN';
      case 'cmn_TW':
        return 'zh-TW';
      case 'hr_HR':
        return 'hr';
      case 'cs_CZ':
        return 'cs';
      case 'da_DK':
        return 'da';
      case 'nl_NL':
        return 'nl';
      case 'en_GB':
        return 'en';
      case 'et_EE':
        return 'et';
      case 'fi_FI':
        return 'fi';
      case 'fr_FR':
        return 'fr';
      case 'gl_ES':
        return 'gl';
      case 'ka_GE':
        return 'ka';
      case 'de_DE':
        return 'de';
      case 'el_GR':
        return 'el';
      case 'gu_IN':
        return 'gu';
      case 'iw_IL':
        return 'iw';
      case 'hi_IN':
        return 'hi';
      case 'hu_HU':
        return 'hu';
      case 'is_IS':
        return 'is';
      case 'su_ID':
        return 'su';
      case 'it_IT':
        return 'it';
      case 'ja_JP':
        return 'ja';
      case 'kn_IN':
        return 'kn';
      case 'kk_KZ':
        return 'kk';
      case 'km_KH':
        return 'km';
      case 'ko_KR':
        return 'ko';
      case 'lo_LA':
        return 'lo';
      case 'lv_LV':
        return 'lv';
      case 'lt_LT':
        return 'lt';
      case 'mk_MK':
        return 'mk';
      case 'ms_MY':
        return 'ms';
      case 'ml_IN':
        return 'ml';
      case 'mr_IN':
        return 'mr';
      case 'mn_MN':
        return 'mn';
      case 'my_MM':
        return 'my';
      case 'ne_NP':
        return 'ne';
      case 'fa_IR':
        return 'fa';
      case 'pl_PL':
        return 'pl';
      case 'pt_BR':
        return 'pt';
      case 'pa_IN':
        return 'pa';
      case 'ro_RO':
        return 'ro';
      case 'ru_RU':
        return 'ru';
      case 'sr_RS':
        return 'sr';
      case 'st_LS':
        return 'st';
      case 'si_LK':
        return 'si';
      case 'sk_SK':
        return 'sk';
      case 'sl_SI':
        return 'sl';
      case 'es_AR':
        return 'es';
      case 'sw_SW':
        return 'sw';
      case 'sv_SE':
        return 'sv';
      case 'ta_LK':
        return 'ta';
      case 'te_IN':
        return 'te';
      case 'th_TH':
        return 'th';
      case 'tr_TR':
        return 'tr';
      case 'uk_UA':
        return 'uk';
      case 'ur_PK':
        return 'ur';
      case 'uz_UZ':
        return 'uz';
      case 'vi_VN':
        return 'vi';
      case 'xh_ZA':
        return 'xh';
      case 'zu_ZA':
        return 'zu';
      default:
        return 'Unknown Language';
    }
  }

  void _listen2(String localeId2) async {
    setState(() {
      _isAppListen2 = true;
    });
    if (!_isListening2) {
      bool available = await _speech.initialize(
        onStatus: (status) async {
          print('Status: $status');
          if (status == 'done') {
            print('NGUNG ROI');
            setState(() {
              _speech.cancel();
              _isListening2 = false;
              _animationController.stop();
              _animate2 = false;
              _isAppListen2 = false;
            });
          }
        },
        onError: (errorNotification) =>
            print('ErrorNotification: $errorNotification'),
      );
      setState(() {
        _isInitializing2 = false;
      });

      if (available) {
        setState(() {
          _isListening2 = true;
          _animationController.repeat();
          _animate2 = true;
        });

        _speech.listen(
          onResult: (result) async {
            setState(() {
              _textEditingController2.text = result.recognizedWords;
            });
            mapLang = mapLanguage(selectedCountryValue!);
            await _translateText2(_textEditingController2.text, mapLang);
          },
          listenFor: Duration(minutes: 5),
          localeId: localeId2,
        );
      }
    } else {
      setState(() {
        _isListening2 = false;
        _animationController.stop();
        _speech.cancel(); // Stop listening
        _animate2 = false;
        _isAppListen2 = false;
      });
    }
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
    final int pageId = 6;
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
        {
          'value': 'vi_VN',
          'label': 'The Language does not exit! Please try again!'
        }
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
        {
          'value': 'en_GB',
          'label': 'The Language does not exit! Please try again!'
        }
      ];
    }
    return filteredCountries;
  }

  @override
  Widget build(BuildContext context) {
    _copy() {
      final Value = ClipboardData(text: _textEditingController1.text);
      Clipboard.setData(Value);
      print(Value);
    }

    _copy2() {
      final Valu = ClipboardData(text: _textEditingController2.text);
      Clipboard.setData(Valu);
      print(Valu);
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // GlobalKey<NavigatorState> navigatorKey = GlobalKey();
    List<String> labels = [
      textData["Label1"] ?? '',
      textData["Label2"] ?? '',
      textData["Label3"] ?? '',
    ];
    return Scaffold(
      backgroundColor: ColorConstant.whiteA700,
      appBar: CustomAppBar(
        titleKey: '${interfaceData["co"]}',
        currentPageItem: 1,
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
            Column(children: [
              SizedBox(
                height: screenWidth * 0.03,
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.07, right: screenWidth * 0.07),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationX(pi) * Matrix4.rotationY(pi),
                    child: Container(
                      padding: getPadding(
                        top: screenWidth * 0.02,
                        right: screenWidth * 0.03,
                        left: screenWidth * 0.03,
                        bottom: screenWidth * 0.02,
                      ),
                      height: MediaQuery.of(context).size.width > 200
                          ? MediaQuery.of(context).size.height * 0.28
                          : MediaQuery.of(context).size.width * 0.45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: ColorConstant.grey, width: 1.0),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  height: screenHeight * 0.03,
                                  child: Column(children: [
                                    Flexible(
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          '$selectedCountryLabel',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppStyle
                                              .txtPoppinsMedium15WhiteA200
                                              .copyWith(
                                                  fontSize: screenWidth * 0.04,
                                                  color: ColorConstant.blueNew,
                                                  fontWeight: FontWeight.w200),
                                        ),
                                      ),
                                    ),
                                  ])),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ),
                              Container(
                                padding:
                                    EdgeInsets.only(right: screenWidth * 0.02),
                                child: GestureDetector(
                                  onTap: () {
                                    _copy();
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    color: ColorConstant.blueNew,
                                    size: screenWidth * 0.06,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: TextField(
                                    readOnly: _isListening,
                                    cursorHeight: screenHeight * 0.03,
                                    controller: _textEditingController1,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 50,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      hintText: _isListening
                                          ? '${interfaceData["ln"]}'
                                          : '${interfaceData["sol"]}',
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
                                    onChanged: (String value) {
                                      setState(() {
                                        _textEditingController1.text = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: AvatarGlow(
                                  startDelay:
                                      const Duration(milliseconds: 1000),
                                  glowColor: _animate
                                      ? ColorConstant.blueNew
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  animate: _animate,
                                  curve: Curves.fastOutSlowIn,
                                  endRadius: screenWidth * 0.06,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!_isAppListen2 &&
                                          !isPlay1 &&
                                          !isPlay2) {
                                        _listen(selectedCountryValue!);
                                      }
                                    },
                                    child: Material(
                                      elevation: 1.0,
                                      shape: const CircleBorder(),
                                      color: Colors.transparent,
                                      child: CircleAvatar(
                                        radius: screenWidth * 0.07,
                                        backgroundColor: ColorConstant.blueNew,
                                        child: Icon(
                                          _isListening
                                              ? Icons.stop_rounded
                                              : Icons.mic_rounded,
                                          color: Colors.white,
                                          size: screenWidth * 0.06,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (!isPlay2 &&
                                      !_isAppListen1 &&
                                      !_isAppListen2 &&
                                      !isPlay1 &&
                                      !isListeningPart1) {
                                    String prepare =
                                        _textEditingController1.text;
                                    print(prepare);
                                    await callTextToSpeechAPIAndPlay(prepare);
                                  } else {
                                    await Future.delayed(
                                        Duration(milliseconds: 2500));
                                    await _audioPlayer.stop();
                                    setState(() {
                                      isPlay1 = false;
                                      isListeningPart1 = false;
                                    });
                                    print('not play');
                                  }
                                },
                                child: AvatarGlow(
                                  startDelay:
                                      const Duration(milliseconds: 1000),
                                  glowColor: isListeningPart1
                                      ? ColorConstant.greyNew5
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  animate: isListeningPart1,
                                  curve: Curves.fastOutSlowIn,
                                  endRadius: screenWidth * 0.07,
                                  child: Container(
                                    // width: screenWidth * 0.124,
                                    // height: screenWidth * 0.124,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      child: isListeningPart1
                                          ? CustomImageView(
                                              svgPath: ImageConstant.stop,
                                              key: Key('stop'),
                                              width: screenWidth * 0.07,
                                              height: screenWidth * 0.07,
                                              color: ColorConstant.blueNew,
                                            )
                                          : CustomImageView(
                                              svgPath: ImageConstant.speaker,
                                              color: ColorConstant.blueNew,
                                              key: Key('speaker'),
                                              width: screenWidth * 0.07,
                                              height: screenWidth * 0.07,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ))
            ]),
            SizedBox(
              height: screenWidth * 0.03,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    button(),
                    button1(),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.04,
                      right: screenWidth * 0.04,
                      top: screenWidth * 0.027,
                      bottom: screenWidth * 0.027),
                  decoration: BoxDecoration(
                      color: ColorConstant.purple2,
                      borderRadius: BorderRadius.all(
                          Radius.circular(screenWidth * 0.07))),
                  child: CustomImageView(
                    svgPath: ImageConstant.swap_horiz,
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    color: ColorConstant.black900,
                    onTap: () {
                      _changeLanguageDropdown();
                    },
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
                  height: MediaQuery.of(context).size.width > 200
                      ? MediaQuery.of(context).size.height * 0.28
                      : MediaQuery.of(context).size.width * 0.45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: ColorConstant.grey, width: 1.0),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              height: screenHeight * 0.04,
                              child: Column(children: [
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      '$selectedCountryLabel2',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyle
                                          .txtPoppinsMedium15WhiteA200
                                          .copyWith(
                                              fontSize: screenWidth * 0.04,
                                              color: ColorConstant.blueNew,
                                              fontWeight: FontWeight.w200),
                                    ),
                                  ),
                                ),
                              ])),
                          SizedBox(
                            width: screenWidth * 0.02,
                          ),
                          Container(
                            padding: EdgeInsets.only(right: screenWidth * 0.02),
                            child: GestureDetector(
                              onTap: () {
                                _copy2();
                              },
                              child: Icon(
                                Icons.copy,
                                color: ColorConstant.blueNew,
                                size: screenWidth * 0.06,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: TextField(
                                      readOnly: _isListening2,
                                      cursorHeight: screenHeight * 0.03,
                                      controller: _textEditingController2,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 50,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        hintText: _isListening2
                                            ? '${interfaceData["ln"]}'
                                            : '${interfaceData["sol"]}',
                                        border: InputBorder.none,
                                        labelStyle: AppStyle
                                            .txtPoppinsMedium18Black900
                                            .copyWith(
                                          color: ColorConstant.black900,
                                        ),
                                        hintStyle: AppStyle.txtPoppinsMedium15
                                            .copyWith(
                                          color: ColorConstant.gray500,
                                        ),
                                      ),
                                      onChanged: (String value) {
                                        _debounceTimer?.cancel();
                                        _debounceTimer =
                                            Timer(Duration(seconds: 3), () {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: AvatarGlow(
                              startDelay: const Duration(milliseconds: 1000),
                              glowColor: _animate2
                                  ? ColorConstant.blueNew
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              animate: _animate2,
                              curve: Curves.fastOutSlowIn,
                              endRadius: screenWidth * 0.06,
                              child: GestureDetector(
                                onTap: () {
                                  if (!_isAppListen1 && !isPlay2 && !isPlay1) {
                                    _listen2(selectedCountryValue2!);
                                  }
                                },
                                child: Material(
                                  elevation: 1.0,
                                  shape: const CircleBorder(),
                                  color: Colors.transparent,
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.07,
                                    backgroundColor: ColorConstant.blueNew,
                                    child: Icon(
                                      _isListening2
                                          ? Icons.stop_rounded
                                          : Icons.mic_rounded,
                                      color: Colors.white,
                                      size: screenWidth * 0.06,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (!isPlay1 &&
                                  !isPlay2 &&
                                  !_isAppListen1 &&
                                  !_isAppListen2 &&
                                  !isListeningPart2) {
                                setState(() {
                                  isListeningPart2 = true;
                                  isPlay2 = true;
                                });
                                String prepare2 = _textEditingController2.text;
                                print(prepare2);
                                await callTextToSpeechAPIAndPlay2(prepare2);
                              } else {
                                await Future.delayed(
                                    Duration(milliseconds: 2500));
                                await _audioPlayer2.stop();
                                setState(() {
                                  isPlay2 = false;
                                  isListeningPart2 = false;
                                });
                              }
                            },
                            child: AvatarGlow(
                              startDelay: const Duration(milliseconds: 1000),
                              glowColor: isListeningPart2
                                  ? ColorConstant.greyNew5
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              animate: isListeningPart2,
                              curve: Curves.fastOutSlowIn,
                              endRadius: screenWidth * 0.07,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: isListeningPart2
                                      ? CustomImageView(
                                          svgPath: ImageConstant.stop,
                                          key: Key('stop'),
                                          width: screenWidth * 0.07,
                                          height: screenWidth * 0.07,
                                          color: ColorConstant.blueNew,
                                        )
                                      : CustomImageView(
                                          svgPath: ImageConstant.speaker,
                                          color: ColorConstant.blueNew,
                                          key: Key('speaker'),
                                          width: screenWidth * 0.07,
                                          height: screenWidth * 0.07,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildSearchBar() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
      child: TextField(
        style: AppStyle.txtPoppinsMedium18Black900_1,
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
    if (label != "The Language does not exit! Please try again!") {
      setState(() {
        selectedCountryLabel = label;
        selectedCountryValue = value;
      });
      LanguageLogs(value!, true);
      SessionManager.updateSession(conversationLanguageFrom: value);
    }
  }

  Widget button() {
    double buttonWidth = MediaQuery.of(context).size.width * 0.50;
    double buttonHeight = MediaQuery.of(context).size.width * 0.15;
    // double iconWidth = MediaQuery.of(context).size.width * 0.000008;
    // double lineSpacing = 0.5;

    return Container(
      height: buttonHeight,
      width: buttonWidth,
      // padding: EdgeInsets.symmetric(horizontal: iconWidth),
      decoration: BoxDecoration(
        color: ColorConstant.blueNew,
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            _showLanguageDialog(context, updateSelectedCountry);
          },
          child: _getFlagIcon(selectedCountryValue!),
        ),
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, Function(String?, String?) updateSelectedCountry1) {
    String? selectedCountry;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            double screenWidth = MediaQuery.of(context).size.width;
            return Dialog(
              backgroundColor: Colors.transparent,
              child: FractionallySizedBox(
                widthFactor: 1.06,
                heightFactor: 0.98,
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: ColorConstant.primary,
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
                          onChanged: (value) {
                            setState(() {
                              countryList1 = _filterCountries1(value);
                              print('list hahahahahahahah $countryList1');
                            });
                          },
                          style: AppStyle.txtPoppinsMedium18Black900_1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '${interfaceData["sfl"]}',
                            hintStyle: AppStyle.txtPoppinsMedium18Grey_1,
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.all(10.0),
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
                                                  color:
                                                      ColorConstant.black900),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
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
      'af_ZA': ImageCountry1Constant.South_Africa,
      'sq_AL': ImageCountry1Constant.Albania,
      'am_ET': ImageCountry1Constant.Ethiopia,
      'ar_EG': ImageCountry1Constant.ARap,
      'az_AZ': ImageCountry1Constant.Azerbaijan,
      'hy_AM': ImageCountry1Constant.Armenia,
      'eu_ES': ImageCountry1Constant.Basque,
      'bn_IN': ImageCountry1Constant.Bengali,
      'bg_BG': ImageCountry1Constant.Bulgaria,
      'ca_ES': ImageCountry1Constant.Spain,
      'cmn_CN': ImageCountry1Constant.China,
      'cmn_TW': ImageCountry1Constant.Taiwan,
      'hr_HR': ImageCountry1Constant.Croatia,
      'cs_CZ': ImageCountry1Constant.Czech_Republic,
      'da_DK': ImageCountry1Constant.Denmark,
      'nl_NL': ImageCountry1Constant.Netherlands,
      'en_GB': ImageCountry1Constant.United_Kingdom,
      'et_EE': ImageCountry1Constant.Estonia,
      'fi_FI': ImageCountry1Constant.Finland,
      'fr_FR': ImageCountry1Constant.France1,
      'gl_ES': ImageCountry1Constant.Spain,
      'ka_GE': ImageCountry1Constant.Georgia,
      'de_DE': ImageCountry1Constant.Germany,
      'el_GR': ImageCountry1Constant.Greece,
      'gu_IN': ImageCountry1Constant.India,
      'iw_IL': ImageCountry1Constant.Israel,
      'hi_IN': ImageCountry1Constant.India,
      'hu_HU': ImageCountry1Constant.Hungary,
      'is_IS': ImageCountry1Constant.Iceland,
      'id_ID': ImageCountry1Constant.Indonesia,
      'it_IT': ImageCountry1Constant.Italy,
      'ja_JP': ImageCountry1Constant.Japan,
      'kn_IN': ImageCountry1Constant.India,
      'kk_KZ': ImageCountry1Constant.Kazakhstan,
      'km_KH': ImageCountry1Constant.Cambodia,
      'ko_KR': ImageCountry1Constant.Korea,
      'lo_LA': ImageCountry1Constant.Laos,
      'lv_LV': ImageCountry1Constant.Latvia,
      'lt_LT': ImageCountry1Constant.Lithuania,
      'mk_MK': ImageCountry1Constant.NorthMacedonia,
      'ms_MY': ImageCountry1Constant.Malaysia,
      'ml_IN': ImageCountry1Constant.India,
      'mr_IN': ImageCountry1Constant.India,
      'mn_MN': ImageCountry1Constant.Mongolia,
      'my_MM': ImageCountry1Constant.Myanmar,
      'ne_NP': ImageCountry1Constant.Nepal,
      'fa_IR': ImageCountry1Constant.Iran,
      'pl_PL': ImageCountry1Constant.Poland,
      'pt_BR': ImageCountry1Constant.Brazil,
      'pa_IN': ImageCountry1Constant.India,
      'ro_RO': ImageCountry1Constant.Romania,
      'ru_RU': ImageCountry1Constant.Russia,
      'sr_RS': ImageCountry1Constant.Serbia1,
      'st_LS': ImageCountry1Constant.Lesotho,
      'si_LK': ImageCountry1Constant.Sri_Lanka,
      'sk_SK': ImageCountry1Constant.Slovakia,
      'sl_SI': ImageCountry1Constant.Slovenia,
      'es_AR': ImageCountry1Constant.Spain,
      'sw_SW': ImageCountry1Constant.Swahili,
      'sv_SE': ImageCountry1Constant.Sweden,
      'ta_LK': ImageCountry1Constant.Sri_Lanka,
      'te_IN': ImageCountry1Constant.India,
      'th_TH': ImageCountry1Constant.Thailand,
      'tr_TR': ImageCountry1Constant.Turkiye,
      'uk_UA': ImageCountry1Constant.Ukraine,
      'ur_PK': ImageCountry1Constant.Pakistan,
      'uz_UZ': ImageCountry1Constant.Uzbekistan,
      'vi_VN': ImageCountry1Constant.Vietnam,
      'xh_ZA': ImageCountry1Constant.South_Africa,
      'zu_ZA': ImageCountry1Constant.South_Africa,
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
      {'value': 'af_ZA', 'label': '${data["af"].toString()}'},
      {'value': 'sq_AL', 'label': '${data["sq"].toString()}'},
      {'value': 'am_ET', 'label': '${data["am"].toString()}'},
      {'value': 'ar_EG', 'label': '${data["ar"].toString()}'},
      {'value': 'az_AZ', 'label': '${data["az"].toString()}'},
      {'value': 'hy_AM', 'label': '${data["hy"].toString()}'},
      {'value': 'eu_ES', 'label': '${data["eu"].toString()}'},
      {'value': 'bn_IN', 'label': '${data["bn"].toString()}'},
      {'value': 'bg_BG', 'label': '${data["bg"].toString()}'},
      {'value': 'ca_ES', 'label': '${data["ca"].toString()}'},
      {'value': 'cmn_CN', 'label': '${data["zh-cn"].toString()}'},
      {'value': 'cmn_TW', 'label': '${data["zh-tw"].toString()}'},
      {'value': 'hr_HR', 'label': '${data["hr"].toString()}'},
      {'value': 'cs_CZ', 'label': '${data["cs"].toString()}'},
      {'value': 'da_DK', 'label': '${data["da"].toString()}'},
      {'value': 'nl_NL', 'label': '${data["nl"].toString()}'},
      {'value': 'en_GB', 'label': '${data["en"].toString()}'},
      {'value': 'et_EE', 'label': '${data["et"].toString()}'},
      {'value': 'fi_FI', 'label': '${data["fi"].toString()}'},
      {'value': 'fr_FR', 'label': '${data["fr"].toString()}'},
      {'value': 'gl_ES', 'label': '${data["gl"].toString()}'},
      {'value': 'ka_GE', 'label': '${data["ka"].toString()}'},
      {'value': 'de_DE', 'label': '${data["de"].toString()}'},
      {'value': 'el_GR', 'label': '${data["el"].toString()}'},
      {'value': 'gu_IN', 'label': '${data["gu"].toString()}'},
      {'value': 'iw_IL', 'label': '${data["iw"].toString()}'},
      {'value': 'hi_IN', 'label': '${data["hi"].toString()}'},
      {'value': 'hu_HU', 'label': '${data["hu"].toString()}'},
      {'value': 'is_IS', 'label': '${data["is"].toString()}'},
      {'value': 'id_ID', 'label': '${data["id"].toString()}'},
      {'value': 'it_IT', 'label': '${data["it"].toString()}'},
      {'value': 'ja_JP', 'label': '${data["ja"].toString()}'},
      {'value': 'kn_IN', 'label': '${data["kn"].toString()}'},
      {'value': 'kk_KZ', 'label': '${data["kk"].toString()}'},
      {'value': 'km_KH', 'label': '${data["km"].toString()}'},
      {'value': 'ko_KR', 'label': '${data["ko"].toString()}'},
      {'value': 'lo_LA', 'label': '${data["lo"].toString()}'},
      {'value': 'lv_LV', 'label': '${data["lv"].toString()}'},
      {'value': 'lt_LT', 'label': '${data["lt"].toString()}'},
      {'value': 'mk_MK', 'label': '${data["mk"].toString()}'},
      {'value': 'ms_MY', 'label': '${data["ms"].toString()}'},
      {'value': 'ml_IN', 'label': '${data["ml"].toString()}'},
      {'value': 'mr_IN', 'label': '${data["mr"].toString()}'},
      {'value': 'mn_MN', 'label': '${data["mn"].toString()}'},
      {'value': 'my_MM', 'label': '${data["my"].toString()}'},
      {'value': 'ne_NP', 'label': '${data["ne"].toString()}'},
      {'value': 'fa_IR', 'label': '${data["fa"].toString()}'},
      {'value': 'pl_PL', 'label': '${data["pl"].toString()}'},
      {'value': 'pt_BR', 'label': '${data["pt"].toString()}'},
      {'value': 'pa_IN', 'label': '${data["pa"].toString()}'},
      {'value': 'ro_RO', 'label': '${data["ro"].toString()}'},
      {'value': 'ru_RU', 'label': '${data["ru"].toString()}'},
      {'value': 'sr_RS', 'label': '${data["sr"].toString()}'},
      {'value': 'st_LS', 'label': '${data["st"].toString()}'},
      {'value': 'si_LK', 'label': '${data["si"].toString()}'},
      {'value': 'sk_SK', 'label': '${data["sk"].toString()}'},
      {'value': 'sl_SI', 'label': '${data["sl"].toString()}'},
      {'value': 'es_AR', 'label': '${data["es"].toString()}'},
      {'value': 'sw_SW', 'label': '${data["sw"].toString()}'},
      {'value': 'sv_SE', 'label': '${data["sv"].toString()}'},
      {'value': 'ta_LK', 'label': '${data["ta"].toString()}'},
      {'value': 'te_IN', 'label': '${data["te"].toString()}'},
      {'value': 'th_TH', 'label': '${data["th"].toString()}'},
      {'value': 'tr_TR', 'label': '${data["tr"].toString()}'},
      {'value': 'uk_UA', 'label': '${data["uk"].toString()}'},
      {'value': 'ur_PK', 'label': '${data["ur"].toString()}'},
      {'value': 'uz_UZ', 'label': '${data["uz"].toString()}'},
      {'value': 'vi_VN', 'label': '${data["vi"].toString()}'},
      {'value': 'xh_ZA', 'label': '${data["xh"].toString()}'},
      {'value': 'zu_ZA', 'label': '${data["zu"].toString()}'},
    ];
  }

  void updateSelectedCountry1(String? label, String? value) {
    if (label != "The Language does not exit! Please try again!") {
      setState(() {
        selectedCountryLabel2 = label;
        selectedCountryValue2 = value;
      });
      LanguageLogs(value!, false);
      SessionManager.updateSession(conversationLanguageTo: value);
    }
  }

  Widget button1() {
    double buttonWidth = MediaQuery.of(context).size.width * 0.50;
    double buttonHeight = MediaQuery.of(context).size.width * 0.15;

    return Container(
      height: buttonHeight,
      width: buttonWidth,
      decoration: BoxDecoration(
        color: ColorConstant.greyNew4,
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            _showLanguageDialog1(context, updateSelectedCountry1);
          },
          child: _getFlagIcon1(selectedCountryValue2!),
        ),
      ),
    );
  }

  void _showLanguageDialog1(
      BuildContext context, Function(String?, String?) updateSelectedCountry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            double screenWidth = MediaQuery.of(context).size.width;
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
                          onChanged: (value) {
                            setState(() {
                              countryList2 = _filterCountries2(value);
                              print('list hahahahahahahah $countryList2');
                            });
                          },
                          style: AppStyle.txtPoppinsMedium18Black900_1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '${interfaceData["sfl"]}',
                            hintStyle: AppStyle.txtPoppinsMedium18Grey_1,
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.all(10.0),
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
                            return Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: GestureDetector(
                                  onTap: () {
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
                                                  color:
                                                      ColorConstant.black900),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
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
      'af_ZA': ImageCountry1Constant.South_Africa,
      'sq_AL': ImageCountry1Constant.Albania,
      'am_ET': ImageCountry1Constant.Ethiopia,
      'ar_EG': ImageCountry1Constant.ARap,
      'az_AZ': ImageCountry1Constant.Azerbaijan,
      'hy_AM': ImageCountry1Constant.Armenia,
      'eu_ES': ImageCountry1Constant.Basque,
      'bn_IN': ImageCountry1Constant.Bengali,
      'bg_BG': ImageCountry1Constant.Bulgaria,
      'ca_ES': ImageCountry1Constant.Spain,
      'cmn_CN': ImageCountry1Constant.China,
      'cmn_TW': ImageCountry1Constant.Taiwan,
      'hr_HR': ImageCountry1Constant.Croatia,
      'cs_CZ': ImageCountry1Constant.Czech_Republic,
      'da_DK': ImageCountry1Constant.Denmark,
      'nl_NL': ImageCountry1Constant.Netherlands,
      'en_GB': ImageCountry1Constant.United_Kingdom,
      'et_EE': ImageCountry1Constant.Estonia,
      'fi_FI': ImageCountry1Constant.Finland,
      'fr_FR': ImageCountry1Constant.France1,
      'gl_ES': ImageCountry1Constant.Spain,
      'ka_GE': ImageCountry1Constant.Georgia,
      'de_DE': ImageCountry1Constant.Germany,
      'el_GR': ImageCountry1Constant.Greece,
      'gu_IN': ImageCountry1Constant.India,
      'iw_IL': ImageCountry1Constant.Israel,
      'hi_IN': ImageCountry1Constant.India,
      'hu_HU': ImageCountry1Constant.Hungary,
      'is_IS': ImageCountry1Constant.Iceland,
      'id_ID': ImageCountry1Constant.Indonesia,
      'it_IT': ImageCountry1Constant.Italy,
      'ja_JP': ImageCountry1Constant.Japan,
      'kn_IN': ImageCountry1Constant.India,
      'kk_KZ': ImageCountry1Constant.Kazakhstan,
      'km_KH': ImageCountry1Constant.Cambodia,
      'ko_KR': ImageCountry1Constant.Korea,
      'lo_LA': ImageCountry1Constant.Laos,
      'lv_LV': ImageCountry1Constant.Latvia,
      'lt_LT': ImageCountry1Constant.Lithuania,
      'mk_MK': ImageCountry1Constant.NorthMacedonia,
      'ms_MY': ImageCountry1Constant.Malaysia,
      'ml_IN': ImageCountry1Constant.India,
      'mr_IN': ImageCountry1Constant.India,
      'mn_MN': ImageCountry1Constant.Mongolia,
      'my_MM': ImageCountry1Constant.Myanmar,
      'ne_NP': ImageCountry1Constant.Nepal,
      'fa_IR': ImageCountry1Constant.Iran,
      'pl_PL': ImageCountry1Constant.Poland,
      'pt_BR': ImageCountry1Constant.Brazil,
      'pa_IN': ImageCountry1Constant.India,
      'ro_RO': ImageCountry1Constant.Romania,
      'ru_RU': ImageCountry1Constant.Russia,
      'sr_RS': ImageCountry1Constant.Serbia1,
      'st_LS': ImageCountry1Constant.Lesotho,
      'si_LK': ImageCountry1Constant.Sri_Lanka,
      'sk_SK': ImageCountry1Constant.Slovakia,
      'sl_SI': ImageCountry1Constant.Slovenia,
      'es_AR': ImageCountry1Constant.Spain,
      'sw_SW': ImageCountry1Constant.Swahili,
      'sv_SE': ImageCountry1Constant.Sweden,
      'ta_LK': ImageCountry1Constant.Sri_Lanka,
      'te_IN': ImageCountry1Constant.India,
      'th_TH': ImageCountry1Constant.Thailand,
      'tr_TR': ImageCountry1Constant.Turkiye,
      'uk_UA': ImageCountry1Constant.Ukraine,
      'ur_PK': ImageCountry1Constant.Pakistan,
      'uz_UZ': ImageCountry1Constant.Uzbekistan,
      'vi_VN': ImageCountry1Constant.Vietnam,
      'xh_ZA': ImageCountry1Constant.South_Africa,
      'zu_ZA': ImageCountry1Constant.South_Africa,
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
      {'value': 'af_ZA', 'label': '${data["af"].toString()}'},
      {'value': 'sq_AL', 'label': '${data["sq"].toString()}'},
      {'value': 'am_ET', 'label': '${data["am"].toString()}'},
      {'value': 'ar_EG', 'label': '${data["ar"].toString()}'},
      {'value': 'az_AZ', 'label': '${data["az"].toString()}'},
      {'value': 'hy_AM', 'label': '${data["hy"].toString()}'},
      {'value': 'eu_ES', 'label': '${data["eu"].toString()}'},
      {'value': 'bn_IN', 'label': '${data["bn"].toString()}'},
      {'value': 'bg_BG', 'label': '${data["bg"].toString()}'},
      {'value': 'ca_ES', 'label': '${data["ca"].toString()}'},
      {'value': 'cmn_CN', 'label': '${data["zh-cn"].toString()}'},
      {'value': 'cmn_TW', 'label': '${data["zh-tw"].toString()}'},
      {'value': 'hr_HR', 'label': '${data["hr"].toString()}'},
      {'value': 'cs_CZ', 'label': '${data["cs"].toString()}'},
      {'value': 'da_DK', 'label': '${data["da"].toString()}'},
      {'value': 'nl_NL', 'label': '${data["nl"].toString()}'},
      {'value': 'en_GB', 'label': '${data["en"].toString()}'},
      {'value': 'et_EE', 'label': '${data["et"].toString()}'},
      {'value': 'fi_FI', 'label': '${data["fi"].toString()}'},
      {'value': 'fr_FR', 'label': '${data["fr"].toString()}'},
      {'value': 'gl_ES', 'label': '${data["gl"].toString()}'},
      {'value': 'ka_GE', 'label': '${data["ka"].toString()}'},
      {'value': 'de_DE', 'label': '${data["de"].toString()}'},
      {'value': 'el_GR', 'label': '${data["el"].toString()}'},
      {'value': 'gu_IN', 'label': '${data["gu"].toString()}'},
      {'value': 'iw_IL', 'label': '${data["iw"].toString()}'},
      {'value': 'hi_IN', 'label': '${data["hi"].toString()}'},
      {'value': 'hu_HU', 'label': '${data["hu"].toString()}'},
      {'value': 'is_IS', 'label': '${data["is"].toString()}'},
      {'value': 'id_ID', 'label': '${data["id"].toString()}'},
      {'value': 'it_IT', 'label': '${data["it"].toString()}'},
      {'value': 'ja_JP', 'label': '${data["ja"].toString()}'},
      {'value': 'kn_IN', 'label': '${data["kn"].toString()}'},
      {'value': 'kk_KZ', 'label': '${data["kk"].toString()}'},
      {'value': 'km_KH', 'label': '${data["km"].toString()}'},
      {'value': 'ko_KR', 'label': '${data["ko"].toString()}'},
      {'value': 'lo_LA', 'label': '${data["lo"].toString()}'},
      {'value': 'lv_LV', 'label': '${data["lv"].toString()}'},
      {'value': 'lt_LT', 'label': '${data["lt"].toString()}'},
      {'value': 'mk_MK', 'label': '${data["mk"].toString()}'},
      {'value': 'ms_MY', 'label': '${data["ms"].toString()}'},
      {'value': 'ml_IN', 'label': '${data["ml"].toString()}'},
      {'value': 'mr_IN', 'label': '${data["mr"].toString()}'},
      {'value': 'mn_MN', 'label': '${data["mn"].toString()}'},
      {'value': 'my_MM', 'label': '${data["my"].toString()}'},
      {'value': 'ne_NP', 'label': '${data["ne"].toString()}'},
      {'value': 'fa_IR', 'label': '${data["fa"].toString()}'},
      {'value': 'pl_PL', 'label': '${data["pl"].toString()}'},
      {'value': 'pt_BR', 'label': '${data["pt"].toString()}'},
      {'value': 'pa_IN', 'label': '${data["pa"].toString()}'},
      {'value': 'ro_RO', 'label': '${data["ro"].toString()}'},
      {'value': 'ru_RU', 'label': '${data["ru"].toString()}'},
      {'value': 'sr_RS', 'label': '${data["sr"].toString()}'},
      {'value': 'st_LS', 'label': '${data["st"].toString()}'},
      {'value': 'si_LK', 'label': '${data["si"].toString()}'},
      {'value': 'sk_SK', 'label': '${data["sk"].toString()}'},
      {'value': 'sl_SI', 'label': '${data["sl"].toString()}'},
      {'value': 'es_AR', 'label': '${data["es"].toString()}'},
      {'value': 'sw_SW', 'label': '${data["sw"].toString()}'},
      {'value': 'sv_SE', 'label': '${data["sv"].toString()}'},
      {'value': 'ta_LK', 'label': '${data["ta"].toString()}'},
      {'value': 'te_IN', 'label': '${data["te"].toString()}'},
      {'value': 'th_TH', 'label': '${data["th"].toString()}'},
      {'value': 'tr_TR', 'label': '${data["tr"].toString()}'},
      {'value': 'uk_UA', 'label': '${data["uk"].toString()}'},
      {'value': 'ur_PK', 'label': '${data["ur"].toString()}'},
      {'value': 'uz_UZ', 'label': '${data["uz"].toString()}'},
      {'value': 'vi_VN', 'label': '${data["vi"].toString()}'},
      {'value': 'xh_ZA', 'label': '${data["xh"].toString()}'},
      {'value': 'zu_ZA', 'label': '${data["zu"].toString()}'},
    ];
  }

  Future<void> _translateText1(String inputText, String targetLanguage) async {
    inputText = inputText.trim();
    if (inputText.isNotEmpty) {
      try {
        print(inputText);
        print(targetLanguage);

        final translation =
            await translator.translate(inputText, to: targetLanguage);
        setState(() {
          _textEditingController2.text = translation.toString();
        });
      } catch (e) {
        print('Translation error: $e');
      }
    }
  }

  Future<void> _translateText2(String inputText, String targetLanguage) async {
    inputText = inputText.trim();
    if (inputText.isNotEmpty) {
      try {
        print(inputText);
        print(targetLanguage);

        final translation =
            await translator.translate(inputText, to: targetLanguage);
        setState(() {
          _textEditingController1.text = translation.toString();
        });
      } catch (e) {
        print('Translation error: $e');
      }
    }
  }

  Future<void> callTextToSpeechAPIAndPlay(String input) async {
    setState(() {
      isPlay1 = true;
      isListeningPart1 = true;
    });
    if (input.isNotEmpty) {
      final String apiUrl = 'https://api.openai.com/v1/audio/speech';
      List<String> apiKey = [
        
      ];

      var requestBody =
          json.encode({"model": "tts-1", "input": input, "voice": "alloy"});

      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer ${apiKey[Indexer]}',
            'Content-Type': 'application/json',
          },
          body: requestBody,
        );

        if (response.statusCode == 200) {
          Uint8List audioBytes = response.bodyBytes;
          // Save the bytes to a temporary file
          Directory tempDir = await getApplicationDocumentsDirectory();
          File tempFile = File('${tempDir.path}/speech.mp3');
          await tempFile.writeAsBytes(audioBytes);
          print(tempFile);
          // Preload the temporary file
          await _audioPlayer.play(UrlSource(tempFile.path));
          _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
            if (state == PlayerState.completed) {
              setState(() {
                isPlay1 = false;
                isListeningPart1 = false;
              });
            }
          });
        } else {
          setState(() {
            isPlay1 = false;
            isListeningPart1 = false;
          });
          Indexer++;
          print("Chiều dài là: ${apiKey.length}");
          if (Indexer < apiKey.length - 1) {
            print("Xài apikey thứ mấy : $Indexer");
            await callTextToSpeechAPIAndPlay(input);
          } else {
            print("All API keys failed. No more keys to try.");
          }
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        setState(() {
          isPlay1 = false;
          isListeningPart1 = false;
        });
        Indexer++;
        print("Chiều dài là: ${apiKey.length}");
        if (Indexer < apiKey.length - 1) {
          print("Xài apikey thứ mấy : $Indexer");
          await callTextToSpeechAPIAndPlay(input);
        } else {
          print("All API keys failed. No more keys to try.");
        }
        print('Erroraaaaaaaaaaaaaa: $error');
      }
    } else {
      setState(() {
        isPlay1 = false;
        isListeningPart1 = false;
      });
    }
  }

  Future<void> callTextToSpeechAPIAndPlay2(String input) async {
    setState(() {
      isPlay2 = true;
      voiceType = mapVoiceType(_uservoice?.gender, _uservoice?.dateOfBirth);
    });
    if (input.isNotEmpty) {
      final String apiUrl = 'https://api.openai.com/v1/audio/speech';
      List<String> apiKey = [
        
      ];

      var requestBody =
          json.encode({"model": "tts-1", "input": input, "voice": voiceType});

      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer ${apiKey[Indexer]}',
            'Content-Type': 'application/json',
          },
          body: requestBody,
        );

        if (response.statusCode == 200) {
          Uint8List audioBytes = response.bodyBytes;
          // Save the bytes to a temporary file
          Directory tempDir = await getApplicationDocumentsDirectory();
          File tempFile = File('${tempDir.path}/speech2.mp3');
          await tempFile.writeAsBytes(audioBytes);
          print(tempFile);
          // Preload the temporary file
          await _audioPlayer2.play(UrlSource(tempFile.path));
          _audioPlayer2.onPlayerStateChanged.listen((PlayerState state) {
            if (state == PlayerState.completed) {
              setState(() {
                isPlay2 = false;
                isListeningPart2 = false;
              });
            }
          });
        } else {
          setState(() {
            isPlay2 = false;
            isListeningPart2 = false;
          });
          Indexer++;
          print("Chiều dài là: ${apiKey.length}");
          if (Indexer < apiKey.length - 1) {
            print("Xài apikey thứ mấy : $Indexer");
            await callTextToSpeechAPIAndPlay2(input);
          } else {
            print("All API keys failed. No more keys to try.");
          }
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        setState(() {
          isPlay2 = false;
          isListeningPart2 = false;
        });
        Indexer++;
        print("Chiều dài là: ${apiKey.length}");
        if (Indexer < apiKey.length - 1) {
          print("Xài apikey thứ mấy : $Indexer");
          await callTextToSpeechAPIAndPlay2(input);
        } else {
          print("All API keys failed. No more keys to try.");
        }
        print('Erroraaaaaaaaaaaaaa: $error');
      }
    } else {
      setState(() {
        isPlay2 = false;
        isListeningPart2 = false;
      });
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
      final int pageId = 6; // Thay thế bằng ID trang thực tế
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
