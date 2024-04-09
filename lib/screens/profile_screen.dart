import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dashboard/DTO/country.dart';
import 'package:http_parser/http_parser.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/DTO/usersview.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/theme/profile_style.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar1.dart';
import 'package:dashboard/widgets/app_bar/custom_bottom_app_bar.dart';
import 'package:dashboard/widgets/profile/profile_appbar_widget.dart';
import 'package:dashboard/widgets/profile/profile_widget.dart';
import 'package:dashboard/widgets/test1.dart';
import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class EditProfilePage extends StatefulWidget {
  late final ValueChanged<String> onSubmit;
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  int? userid;
  bool isPicker = false;
  UserView? _userView;
  String? diacode = "+84";
  String? username;
  late Future<Uint8List> _imageFuture;
  int _selectedIndex = 4;
  Map<String, String> interfaceData = {};
  Timer? _debounceTimer;
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  TextEditingController dateinput = TextEditingController();
  File? selectedMedia;
  late CameraController? _controller;
  bool _isCameraReady = false;
  Map<String, String> data = {};
  late List<Map<String, String>> countryList;
  String? langSession = '';
  String? selectedCountryLabel2 = "English";
  String? positions;
  String? _selectedNationality;
  bool _submitted = false;
  bool _submitted2 = false;
  bool _submitted3 = false;
  bool _submitted4 = false;
  bool _check = false;
  File? _imageFileTemp;
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String? _selectedGender;
  String? token;
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

  Future<void> loadData(String name) async {
    try {
      String jsonString =
          await rootBundle.loadString('lang/TranslateLang/$name.json');
      print("Decoded JSON: $jsonString");
      Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        data = jsonData.cast<String, String>();
        countryList = getList();
        selectedCountryLabel2 = '${data["en"]}';
      });
    } catch (error) {
      print("Error loading JSON: $error");
    }
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerEmail.dispose();
    _controllerNumber.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initializeToken();
    super.initState();
    dateinput.text = "";
    _loadImageFileFromAsset('assets/images/bg_news.png');
    _debounceTimer = Timer(Duration(milliseconds: 2000), () {});
    _getSessionUser();
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
    _controllerName.addListener(_handleKeyboardShortcut);
    _controllerNumber.addListener(_handleKeyboardShortcut3);
    _controllerEmail.addListener(_handleKeyboardShortcut2);
    SessionManager.getUserid()
        .then((value) => {userid = int.tryParse(value ?? "@@")});
    print(userid);
  }

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  Future<void> _loadImageFileFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final File imgFile = File('${tempDir.path}/temp_image.png');

    await imgFile.writeAsBytes(bytes);

    setState(() {
      _imageFileTemp = imgFile;
    });
  }

  void _handleKeyboardShortcut() {
    setState(() {
      _submitted = true;
    });
  }

  void _handleKeyboardShortcut2() {
    setState(() {
      _submitted2 = true;
    });
  }

  void _handleKeyboardShortcut3() {
    setState(() {
      _submitted3 = true;
    });
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    AccessLogs();
  }

  String removePlusSign(String str) {
    return str.replaceAll('+', '');
  }

  Future<void> _getSessionUser() async {
    await SessionManager.getUsername().then((value) {
      if (value != null) {
        username = removePlusSign(value);
        print('Username in Home: $username');
      } else {
        print('Username is null');
      }
    }).catchError((error) {
      print('Error: $error');
    });
    await fetchUser(username ?? "").then((userView) async {
      setState(() {
        _userView = userView;
      });

      String formattedDate =
          DateFormat('yyyy-MM-dd').format(_userView!.dateOfBirth);
      await updateControllers(
          _userView?.fullName,
          _userView?.email,
          _userView?.phone,
          _userView?.gender,
          _userView?.national,
          formattedDate.toString());
      print("3333333333333333${_userView?.fullName}");
    }).catchError((error) {
      print(error);
    });
    setState(() {
      _imageFuture = _fetchImage(_userView?.imageUser);
    });
  }

  Future<Uint8List> _fetchImage(String? name) async {

    final response = await http.get(
        Uri.parse('http://api-languagefree.cosplane.asia/api/Image/$name'));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }

  Future<void> updateControllers(String? name, String? email, String? number,
      String? gender, String? nationality, String? dateOfBirth) async {
    setState(() {
      _controllerName.text = name ?? '';
      _controllerEmail.text = email ?? '';
      if (number?.startsWith("84") == true) {
        _controllerNumber.text = number?.substring(2) ?? '';
      } else {
        _controllerNumber.text = number ?? '';
      }
      _selectedGender = gender ?? '';
      _selectedNationality = nationality ?? '';
      dateinput.text = dateOfBirth ?? '';
    });
  }

  Future<UserView> fetchUser(String username) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
        Uri.parse(
            'http://api-languagefree.cosplane.asia/api/Users/getByAccount/$username'),
        headers: headers);
    if (response.statusCode == 200) {
      return UserView.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user ${response.statusCode}');
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

  Future<bool> AccessLogs() async {
    final String apiUrl =
        'http://api-languagefree.cosplane.asia/api/AccessLogs';
    final int? userId = userid; //ADDUID
    final int pageId = 11;
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

  Future<void> _initializeController() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    await _controller?.initialize();
    setState(() {
      _isCameraReady = true;
    });
  }

  String base64String(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          selectedMedia = File(image.path);
          isPicker = true;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ColorConstant.whiteA700,
      appBar: CustomAppBar1(
        titleKey: '${interfaceData["mp"]}',
        actions: [
          Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              child: CustomImageView(
                width: 50,
                height: 50,
                imagePath: ImageConstant.logo,
              )),
        ],
        leading: IconButton(
          icon: Icon(Icons.feedback_rounded),
          color: ColorConstant.whiteA700,
          onPressed: () {
            _showDialogFeedback();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: screenWidth * 0.03,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (selectedMedia != null) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: ColorConstant.blueNew4,
                          content: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.01),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.05),
                              child: Image.file(selectedMedia!),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: selectedMedia != null
                      ? Stack(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.2,
                              child: ClipOval(
                                child: Image.file(
                                  selectedMedia!,
                                  fit: BoxFit.cover,
                                  width: screenWidth,
                                  height: screenHeight,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -12,
                              left: 100,
                              child: Container(
                                width: screenWidth * 0.1,
                                height: screenHeight * 0.1,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorConstant.black900,
                                ),
                                child: IconButton(
                                  onPressed: _pickImage,
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: screenWidth * 0.05,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : Stack(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.20,
                              backgroundImage: _userView != null &&
                                      _userView!.imageUser != null
                                  ? Image.network(
                                      'http://api-languagefree.cosplane.asia/api/Image/${_userView!.imageUser}',
                                      scale: 50,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ).image
                                  : null,
                            ),
                            Positioned(
                              bottom: -12,
                              left: 100,
                              child: Container(
                                width: screenWidth * 0.1,
                                height: screenHeight * 0.1,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorConstant.black900,
                                ),
                                child: IconButton(
                                  onPressed: _pickImage,
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: screenWidth * 0.05,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.0, color: ColorConstant.grey),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.04, right: screenWidth * 0.04),
              child: Column(
                children: [
                  TextReadonly(
                      labelText: '${interfaceData["fn"]}',
                      hintText: '${interfaceData["peyfn"]}',
                      EditText: _controllerName,
                      errortext: _errorText1,
                      keyboardType: TextInputType.text,
                      onChanged: _onNameChanged,
                      suffixIcon: Icon(Icons.person_rounded,
                          color: ColorConstant.blueNew)),
                  SizedBox(height: screenWidth * 0.01),
                  TextReadonly(
                      labelText: '${interfaceData["e"]}',
                      hintText: '${interfaceData["peye"]}',
                      EditText: _controllerEmail,
                      errortext: _errorText2,
                      suffixIcon: Icon(Icons.email_outlined,
                          color: ColorConstant.blueNew)),
                  SizedBox(height: screenWidth * 0.01),
                  TextReadonly(
                      keyboardType: TextInputType.number,
                      labelText: '${interfaceData["pn"]}',
                      EditText: _controllerNumber,
                      hintText: '${interfaceData["peypn"]}',
                      errortext: _errorText3,
                      suffixIcon: Container(
                          width: screenWidth * 0.30,
                          padding: EdgeInsets.only(left: screenWidth * 0.02),
                          child: Row(
                            children: [
                              Icon(Icons.phone, color: ColorConstant.blueNew),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ),
                              DropdownMenuExample(
                                onCountrySelected: (Country country) {
                                  setState(() {
                                    diacode = country.dialCode;
                                  });
                                  print(" dial code: ${country.dialCode}");
                                },
                              ),
                            ],
                          ))),
                  SizedBox(height: screenWidth * 0.01),
                  DropdownGender(
                    suffixIcon: Icon(Icons.group, color: ColorConstant.blueNew),
                    labelText: '${interfaceData["gd"]}',
                    selectedGender: _selectedGender ?? "",
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  DropdownNationality(
                    suffixIcon: Icon(Icons.language_rounded,
                        color: ColorConstant.blueNew),
                    labelText: '${interfaceData["n"]}',
                    nationalityList: getList(),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Datepicker(
                    suffixIcon: Icon(Icons.calendar_today,
                        color: ColorConstant.blueNew),
                    labelText: '${interfaceData["bd"]}',
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  ElevatedButton(
                    onPressed: () {
                      String fullName = _controllerName.text;
                      String email = _controllerEmail.text;
                      String phone = _controllerNumber.text;

                      SessionManager.getUserid().then((value) {
                        if (value != null) {
                          print('Username in Home: $value');
                          int? x = int.tryParse(value);
                          setState(() {
                            userid = x;
                          });
                        } else {
                          print('Username is null');
                        }
                      }).catchError((error) {
                        print('Error: $error');
                      });
                      if (_isButtonEnabled() == true) {
                        setState(() {
                          _submitted = true;
                          _submitted2 = true;
                          _submitted3 = true;
                          _submitted4 = true;
                        });

                        if (_controllerName.value.text.isNotEmpty &&
                            _controllerNumber.value.text.isNotEmpty &&
                            _controllerEmail.value.text.isNotEmpty) {
                          _submit();
                          print('isPicker: $isPicker');
                          print('userid: $userid');
                          print('Name: ${_controllerName.value.text}');
                          print(
                              'Number: $diacode${_controllerNumber.value.text}');
                          print('Gender: $_selectedGender');
                          print('Date: ${DateTime.parse(dateinput.text)}');
                          print('Email: ${_controllerEmail.value.text}');
                          print('Nationality: $_selectedNationality');
                          print(
                              'Selected Media: ${selectedMedia ?? _imageFileTemp!}');
                          DateTime selectedDate =
                              DateFormat('yyyy-MM-dd').parse(dateinput.text);
                          if (fullName.isEmpty ||
                              fullName.length <= 2 ||
                              fullName.length >= 30 ||
                              _isNumberEntered ||
                              phone.isEmpty ||
                              !RegExp(r'^([1-9][0-9]{8})$|^([1-9][0-9]{9})$')
                                  .hasMatch(phone) ||
                              email.isEmpty ||
                              (!RegExp(
                                      r'^(?=.{6,30}@)(?=.*[a-zA-Z])[a-zA-Z0-9]*[a-zA-Z][a-zA-Z0-9]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(email)) ||
                              (!email.endsWith('@gmail.com') &&
                                  !email.endsWith('@fpt.edu.vn') &&
                                  !email.endsWith('@fe.edu.vn')) ||
                              _selectedGender == null ||
                              _selectedNationality == null ||
                              dateinput.text.isEmpty ||
                              selectedDate.year < 1950 ||
                              selectedDate.year > 2016) {
                            print(
                                "siuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu");
                            Flushbar(
                              margin: EdgeInsets.all(15),
                              borderRadius: BorderRadius.circular(8),
                              message: "The information is invalid.",
                              messageColor: Colors.red,
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
                          } else {
                            updateUser(
                                    isPicker,
                                    userid ?? 0,
                                    _controllerName.value.text,
                                    "$diacode${_controllerNumber.value.text}",
                                    _selectedGender!,
                                    DateTime.parse(dateinput.text),
                                    _controllerEmail.value.text,
                                    _selectedNationality!,
                                    selectedMedia ?? _imageFileTemp!)
                                .then((_) {
                              if (_check == true) {
                                setState(() {
                                  _check == false;
                                });
                                Flushbar(
                                  margin: EdgeInsets.all(15),
                                  borderRadius: BorderRadius.circular(8),
                                  message: '${interfaceData["yhssc"]}',
                                  messageColor: Colors.green,
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
                              }
                            });
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _isButtonEnabled()
                          ? ColorConstant.blueNew
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                      // Thiết lập màu chữ
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: screenWidth * 0.04, bottom: screenWidth * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${interfaceData["sc"]}',
                            style: TextStyle(
                              color: _isButtonEnabled()
                                  ? Colors.white
                                  : Colors.black, // Màu chữ tương ứng
                              fontSize: 20, // Cỡ chữ
                              fontWeight: FontWeight.w500, // Độ đậm của chữ
                              // Các thuộc tính khác của TextStyle
                            ),
                            // style: AppStyle.txtPoppinsMedium20White_2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenWidth * 0.03,
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

  bool _isButtonEnabled() {
    return _controllerName.value.text.isNotEmpty &&
        _controllerNumber.value.text.isNotEmpty &&
        _controllerEmail.value.text.isNotEmpty;
  }

  final _controllerName = TextEditingController();
  String? get _errorText1 {
    if (!_submitted) {
      return null; // Don't show error message if form hasn't been submitted
    }
    final text = _controllerName.value.text;
    if (_isNumberEntered) {
      return '${interfaceData["peoa"]}'; // Show error if number is entered
    }
    if (text.isEmpty) {
      return '${interfaceData["cbe"]}';
    }
    if (text.length <= 2 || text.length >= 30) {
      return '${interfaceData["1a1"]}';
    }
    return null;
  }

  bool _isNumberEntered = false;

  String _capitalize(String text) {
    List<String> words = text.split(' ');
    words = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      } else {
        return '';
      }
    }).toList();
    return words.join(' ');
  }

// Custom onChanged method for TextField to handle number input
  void _onNameChanged(String value) {
    setState(() {
      _isNumberEntered =
          value.contains(RegExp(r'[0-9]')); // Check if number is entered
      _controllerName.value = _controllerName.value.copyWith(
        text: _capitalize(value), // Capitalize first letter of each word
        selection:
            TextSelection.collapsed(offset: _controllerName.value.text.length),
      );
    });
  }

  final _controllerEmail = TextEditingController();
  String? get _errorText2 {
    if (!_submitted2) {
      return null;
    }
    final text = _controllerEmail.value.text.trim();
    if (text.isEmpty) {
      return '${interfaceData["ecbe"]}';
    } else if (!RegExp(
            r'^(?=.{6,30}@)(?=.*[a-zA-Z])[a-zA-Z0-9]*[a-zA-Z][a-zA-Z0-9]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(text)) {
      return '${interfaceData["ief"]}';
    } else if (!text.endsWith('@gmail.com') &&
        !text.endsWith('@fpt.edu.vn') &&
        !text.endsWith('@fe.edu.vn')) {
      return '${interfaceData["emewe"]}';
    }
    return null;
  }

  final _controllerNumber = TextEditingController();
  String? get _errorText3 {
    if (!_submitted3) {
      return null; // Don't show error message if form hasn't been submitted
    }
    final text = _controllerNumber.value.text.trim();
    if (text.isEmpty) {
      return '${interfaceData["pncbe"]}';
    } else if (!RegExp(r'^([1-9][0-9]{8})$|^([1-9][0-9]{9})$').hasMatch(text)) {
      return '${interfaceData["ipnf"]}';
    }
    return null;
  }

  Future<void> updateUser(
      bool isPickImage,
      int userId,
      String fullName,
      String phone,
      String gender,
      DateTime dateOfBirth,
      String email,
      String national,
      File imageFile) async {
    try {
      Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
      var uri = Uri.parse(
          'http://api-languagefree.cosplane.asia/api/Users/withImage');
      var request = http.MultipartRequest('POST', uri);
      final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      // Add form fields
      request.headers.addAll(headers);
      request.fields['UserTempDTO.UserId'] = userId.toString();
      request.fields['UserTempDTO.FullName'] = fullName;
      request.fields['UserTempDTO.Phone'] = removePlusSign(phone);
      request.fields['UserTempDTO.Gender'] = gender;
      request.fields['UserTempDTO.DateOfBirth'] =
          formatter.format(dateOfBirth.toUtc());
      request.fields['UserTempDTO.Email'] = email;
      request.fields['UserTempDTO.National'] = national;
      request.fields['UserTempDTO.isPickImage'] = isPickImage.toString();

      String nameFile = getFileNameFromPath(imageFile.path);
      print("huyaaaaaaa $imageFile");
      print("huyaaaaaaa2222222222222 $nameFile");

      request.files.add(
        http.MultipartFile.fromBytes(
          'UploadModel.ImageFile',
          imageFile.readAsBytesSync(),
          filename: nameFile,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _check = true;
        });
      } else {
        print('Failed to update user: ${response.statusCode}');
        print('Failed to update user: ${response.reasonPhrase}');
        var errorResponse = await response.stream.bytesToString();
        Flushbar(
          margin: EdgeInsets.all(15),
          borderRadius: BorderRadius.circular(8),
          message: '${interfaceData["ftuu"]}',
          messageColor: Colors.red,
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

        print('Error response: $errorResponse');
      }
    } catch (e) {
      print('Failed to update user: $e');
    }
  }

  String getFileNameFromPath(String filePath) {
    List<String> pathParts = filePath.split('/');
    return pathParts.last;
  }

  String? _validateDate(String? inputDate) {
    if (!_submitted4) {
      return null; // Don't show error message if form hasn't been submitted
    }
    if (inputDate == null || inputDate.isEmpty) {
      return '${interfaceData["psad"]}'; // No error if the input is empty
    }

    DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(inputDate);

    if (selectedDate.year < 1950 || selectedDate.year > 2016) {
      return '${interfaceData["idpsad"]}';
    }

    return null; // No error if the date is valid
  }

  String? _validateGender(String? selectedGender) {
    if (!_submitted4) {
      return null; // Don't show error message if form hasn't been submitted
    }
    if (selectedGender == null || selectedGender.isEmpty) {
      return '${interfaceData["psag"]}'; // Error message if gender is not selected
    }
    return null; // No error if gender is selected
  }

  String? _validateNationality(String? selectedNationality) {
    if (!_submitted4) {
      return null; // Don't show error message if form hasn't been submitted
    }
    if (selectedNationality == null || selectedNationality.isEmpty) {
      return '${interfaceData["psaa"]}'; // Error message if nationality is not selected
    }
    return null; // No error if nationality is selected
  }

  Widget TextReadonly({
    required String labelText,
    required TextEditingController EditText,
    required Widget suffixIcon,
    required String? errortext,
    required String hintText,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 1,
          ),
          TextField(
            keyboardType: keyboardType,
            onChanged: onChanged,
            textAlign: TextAlign.left,
            style: TextStyle(color: ColorConstant.black900),
            decoration: InputDecoration(
              errorText: errortext,
              hintText: hintText,
              contentPadding: EdgeInsets.zero,
              filled: true, // Set filled to true
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(width: 1, color: ColorConstant.greyNew8),
              ),
              prefixIcon: suffixIcon,
            ),
            controller: EditText,
          ),
        ],
      );

  void _submit() {
    // if (_errorText1 == null && _errorText2 == null && _errorText3 == null)  {
    //   widget.onSubmit(_controllerName.value.text);
    //   widget.onSubmit(_controllerEmail.value.text);
    //   widget.onSubmit(_controllerNumber.value.text);
    // }
  }

  Widget DropdownGender({
    required Widget suffixIcon,
    required String labelText,
    required String selectedGender,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        DropDownTextField(
          initialValue: selectedGender,

          textFieldDecoration: InputDecoration(
            errorText: _validateGender(_selectedGender),
            contentPadding: EdgeInsets.zero,
            hintText: '${_selectedGender}',
            filled: true, // Set filled to true
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(width: 1, color: ColorConstant.greyNew8),
            ),
            prefixIcon: suffixIcon,
          ),
          clearOption: false,
          textFieldFocusNode: textFieldFocusNode,
          searchFocusNode: searchFocusNode,
          // searchAutofocus: true,
          dropDownItemCount: 2,
          searchShowCursor: false,
          enableSearch: false,
          dropdownColor: Colors.blue[50],
          searchKeyboardType: TextInputType.text,
          dropDownList: [
            DropDownValueModel(name: 'Female', value: "F"),
            DropDownValueModel(name: 'Male', value: "M"),
          ],
          onChanged: (value) => {
            setState(() {
              _selectedGender = value.name.toString();
            }),
          },
        )
      ],
    );
  }

  Widget DropdownNationality({
    required Widget suffixIcon,
    required String labelText,
    required List<Map<String, String>> nationalityList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        DropDownTextField(
          textFieldDecoration: InputDecoration(
            errorText: _validateNationality(_selectedNationality),
            contentPadding: EdgeInsets.zero,
            hintText: '${_selectedNationality}',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(width: 1, color: ColorConstant.greyNew8),
            ),
            prefixIcon: suffixIcon,
          ),
          clearOption: false,
          textFieldFocusNode: textFieldFocusNode,
          searchDecoration:
              InputDecoration(hintText: '${interfaceData["syno"]}'),
          dropDownItemCount: 5,
          searchShowCursor: false,
          enableSearch: true,
          dropdownColor: Colors.blue[50],
          searchKeyboardType: TextInputType.text,
          dropDownList: nationalityList
              .map((item) => DropDownValueModel(
                  name: item['label'] ?? '', value: item['label'] ?? ''))
              .toList(),
          onChanged: (value) => {
            setState(() {
              _selectedNationality = value.name.toString();
            })
          },
        )
      ],
    );
  }

  Widget Datepicker({
    required Widget suffixIcon,
    required String labelText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        TextField(
          scrollPadding: EdgeInsets.zero,
          controller: dateinput,
          decoration: InputDecoration(
            errorText: _validateDate(dateinput.text),
            contentPadding: EdgeInsets.symmetric(vertical: 0.0),
            filled: true,
            hintText: '${interfaceData["sybi"]}',
            fillColor: Colors.white,
            border: OutlineInputBorder(
              gapPadding: 0.0,
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(width: 1, color: ColorConstant.greyNew8),
            ),
            prefixIcon: suffixIcon,
          ),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1930),
              lastDate: DateTime(2050),
              // Thêm backgroundColor để thiết lập màu nền của showDatePicker
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: Colors.blue[50], // Màu chủ đạo của DatePicker
                    backgroundColor: Colors.blue[50], // Màu nền của DatePicker
                    colorScheme: ColorScheme.light(
                      primary: ColorConstant.blueNew,
                    ), // Màu chủ đạo của DatePicker
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              print(pickedDate);
              String formattedDate =
                  DateFormat('yyyy-MM-dd').format(pickedDate);
              print(formattedDate);
              setState(() {
                dateinput.text = formattedDate;
              });
            } else {
              print("Date is not selected");
            }
          },
        )
      ],
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
      final int pageId = 11; // Thay thế bằng ID trang thực tế
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
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token',},
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

class DropdownMenuExample extends StatefulWidget {
  final Function(Country)? onCountrySelected;

  const DropdownMenuExample({Key? key, this.onCountrySelected})
      : super(key: key);

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  List<Country> countries = <Country>[
    Country('+84'),
    Country('+93'),
    Country('+355'),
    Country('+251'),
    Country('+966'),
    Country('+374'),
    Country('+994'),
    Country('+34'),
    Country('+880'),
    Country('+359'),
    Country('+86'),
    Country('+886'),
    Country('+385'),
    Country('+420'),
    Country('+45'),
    Country('+31'),
    Country('+44'),
    Country('+372'),
    Country('+358'),
    Country('+33'),
    Country('+34'),
    Country('+995'),
    Country('+49'),
    Country('+30'),
    Country('+91'),
    Country('+972'),
    Country('+91'),
    Country('+36'),
    Country('+354'),
    Country('+62'),
    Country('+39'),
    Country('+81'),
    Country('+91'),
    Country('+7'),
    Country('+855'),
    Country('+82'),
    Country('+856'),
    Country('+371'),
    Country('+370'),
    Country('+389'),
    Country('+60'),
    Country('+91'),
    Country('+91'),
    Country('+976'),
    Country('+95'),
    Country('+977'),
    Country('+98'),
    Country('+48'),
    Country('+351'),
    Country('+91'),
    Country('+40'),
    Country('+7'),
    Country('+381'),
    Country('+266'),
    Country('+94'),
    Country('+421'),
    Country('+386'),
    Country('+34'),
    Country('+255'),
    Country('+46'),
    Country('+91'),
    Country('+91'),
    Country('+66'),
    Country('+90'),
    Country('+380'),
    Country('+92'),
    Country('+998'),
    Country('+27'),
    Country('+27'),
  ];
  Country? dropdownValue;
  bool isItemSelected = false;
  @override
  void initState() {
    super.initState();
    dropdownValue = countries[0]; // Đặt dropdownValue ban đầu là Vietnam
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return PopupMenuButton<Country>(
      color: ColorConstant.blueNew4,
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<Country>(
            child: Container(
              alignment: Alignment.center,
              width: screenWidth * 0.3,
              height: screenWidth * 0.1 * 5, // Chiều cao tối đa cho 5 mục
              child: SingleChildScrollView(
                child: Column(
                  children: countries.map((Country country) {
                    return PopupMenuItem<Country>(
                        value: country,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.check,
                                color: dropdownValue == country
                                    ? Colors.green
                                    : Colors.transparent,
                                size: screenWidth * 0.04,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(country.dialCode),
                            ],
                          ),
                        ));
                  }).toList(),
                ),
              ),
            ),
          ),
        ];
      },
      onSelected: (Country country) {
        setState(() {
          dropdownValue = country;
          isItemSelected = true; // Đánh dấu là đã chọn một mục
        });
        // Gọi callback để truyền giá trị Country được chọn ra ngoài
        if (widget.onCountrySelected != null) {
          widget.onCountrySelected!(country);
        }
      },
      onCanceled: () {
        // Xử lý khi người dùng hủy bỏ dropdown menu
        setState(() {
          isItemSelected = false; // Đánh dấu là không có mục nào được chọn
        });
      },
      child: SizedBox(
        width: screenWidth * 0.18,
        height: screenWidth * 0.1,
        child: Container(
          decoration: BoxDecoration(
              color: ColorConstant.whiteA700,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${dropdownValue?.dialCode}'),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
