import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/rate.dart';
import 'package:dashboard/DTO/usersview.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/about_us.dart';
import 'package:dashboard/screens/camera_screen.dart';
import 'package:dashboard/screens/chat_box_screen.dart';
import 'package:dashboard/screens/help_screen.dart';
import 'package:dashboard/screens/newspaper_screen.dart';
import 'package:dashboard/screens/profile_screen.dart';
import 'package:dashboard/screens/qr_screen.dart';
import 'package:dashboard/screens/speed_screen.dart';
import 'package:dashboard/screens/translation_screen.dart';
import 'package:dashboard/screens/weather_screen.dart';
import 'package:dashboard/screens/welcome_screen.dart';
import 'package:dashboard/services/rss_api_news.dart';
import 'package:dashboard/utils/image_country_constant_1.dart';
import 'package:dashboard/widgets/app_bar/custom_bottom_app_bar.dart';
import 'package:dashboard/widgets/home_view/custom_item_home.dart';
import 'package:dashboard/widgets/home_view/custom_item_service.dart';
import 'package:dashboard/widgets/newspaper_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/app_export.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserView? _userView;
  String? username;
  int _counter = 120; // Thời gian đếm ngược (giây)
  late Timer _timer;
  int? userid; //ADDUID
  bool? checkRate;
  bool isLocked = false;
  late Future<Uint8List> _imageFuture;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? positions;
  double xOffset = 0;
  double yOffset = 0;
  int _selectedIndex = 0;
  String? langSession = '';
  List<RssItem> news = [];
  bool isDrawerOpen = false;
  bool isLoading = false;
  bool hasError = false;
  Map<String, String> data = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, String>> countryList = [];
  Map<String, String> interfaceData = {};
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

  Future<void> _getNews() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final fetchedNews = await RssApi().getRssItems();
      setState(() {
        news = fetchedNews;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching news: $error');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          _timer.cancel();
          _checkRate(userid ?? 0);
        }
      });
    });
  }

  _signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    SessionManager.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  @override
  void initState() {
    _initializeToken();
    super.initState();
    _getNews();
    _getSessionUser();
    _startTimer();
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
  }

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    AccessLogs();
    await SessionManager.getUsername().then((value) async {
      await checkLogin(value ?? 'huy@@@@');
    });
    postData();
  }

  Future<void> checkLogin(String username) async {
    final String apiUrl =
        'http://api-languagefree.cosplane.asia/api/Accounts/Login';
    final Map<String, dynamic> requestData = {
      "username": username,
      "password": ""
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final accessToken = jsonResponse['accessToken'];
        print('Đăng nhập thành công! : $accessToken');
        print('Response: ${response.body}');
        SessionManager.saveToken(accessToken);
      } else {
        print('Đăng nhập không thành công. Mã lỗi: ${response.statusCode}');
        print('Response: ${response.body}');
        if (response.body == '{"message":"Account Locked"}') {
          setState(() {
            isLocked = true;
          });
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          size: 35.0,
                          color: Colors.red[800],
                        ),
                      ],
                    ),
                    Text(
                      '${interfaceData["war"]}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                content: Text('${interfaceData["yawlpt"]}'),
                actions: <Widget>[
                  Container(
                    alignment: Alignment.center, // Căn giữa
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorConstant.blueNew,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                            color: ColorConstant.blueNew,
                            width: 2.0,
                          ),
                        ),
                        child: Text('${interfaceData["cn"]}',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          setState(() {
            isLocked = false;
          });
          _signOut();
        }
      }
    } catch (error) {
      print('Đã xảy ra lỗi khi gọi API: $error');
    }
  }

  Future<void> _checkRate(int uid) async {
    final url = Uri.parse(
        'http://api-languagefree.cosplane.asia/api/Rates/canRate/$uid');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          checkRate = responseData['isChecked'];
        });
        print('HuyyyyyyyyyyyyyyyyyyyyyyyCheckRAte $checkRate');
        if (checkRate == true) {
          _showRatingDialog();
        }
      } else {
        print(
            'Request failed with statusHuyyyyyyyyyyyyyyyyyyyyyyy: ${response.statusCode}');
      }
    } catch (e) {
      print('ErrorHuyyyyyyyyyyyyyyyyyyyyyyy: $e');
    }
  }

  //ADDUID
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
    await fetchUser(username ?? "").then((userView) {
      setState(() {
        _userView = userView;
      });
      print("3333333333333333${_userView?.fullName}");
    }).catchError((error) {
      print(error);
    });
    setState(() {
      _imageFuture = _fetchImage(_userView?.imageUser);
    });
    //ADDUID
  }

  Future<Uint8List> _fetchImage(String? name) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(
        Uri.parse('http://api-languagefree.cosplane.asia/api/Image/$name'),
        headers: headers);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
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

  Future<bool> AccessLogs() async {
    final String apiUrl =
        'http://api-languagefree.cosplane.asia/api/AccessLogs';
    final int userId = userid ?? 0; //ADDUID
    final int pageId = 4;
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
        await SessionManager.getUserid().then((value) async {
          setState(() {
            userid = int.tryParse(value ?? "@@");
          });
          await SessionManager.updateSession(userId: userid);
        });
        print(userid);
      } else {
        print('No position found.');
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> postData() async {
    String jsonData = await SessionManager.getSessionDataAndConvertToJson();
    print(jsonData);
    final response = await http.post(
      Uri.parse('http://api-languagefree.cosplane.asia/api/Settings'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonData,
    );

    if (response.statusCode == 200) {
      print('POST request successful');
      print('Response: ${response.body}');
    } else {
      print('Failed to make POST request.');
      print('Response: ${response.body}');
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

        countryList = getList();

        print(countryList);
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

  List<Map<String, String>> _filterCountries(String keyword) {
    print("Hello");
    var filteredCountries = getList()
        .where((countryList) =>
            countryList['label']!.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    print(filteredCountries);
    if (filteredCountries.length == 0) {
      return [
        {
          'value': 'No language access',
          'label': 'The Language does not exit! Please try again!'
        }
      ];
    }
    return filteredCountries;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: false,
      extendBody: true,
      backgroundColor: ColorConstant.blueNew,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            '${interfaceData["home"]}',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: ColorConstant.blueNew,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext innerContext) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: ColorConstant.whiteA700,
                size: screenWidth * 0.05,
              ),
              onPressed: () {
                Scaffold.of(innerContext).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
              iconSize: screenWidth * 0.05,
              onPressed: () {
                _showLanguageDialog(context);
              },
              icon: Image.asset(
                ImageConstant.logoLanguage,
                width: screenWidth * 0.05,
                height: screenWidth * 0.05,
              )),
        ],
      ),
      drawer: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageConstant.sidebar),
            fit: BoxFit.cover,
          ),
        ),
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                    top: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: ColorConstant.greyNew2, width: 1.0)),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          padding: EdgeInsets.only(bottom: screenWidth * 0.05),
                          child: Image.asset(
                            ImageConstant.imgSidebar,
                            width: screenWidth * 0.55,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.home_rounded,
                        color: ColorConstant.whiteA700,
                      ),
                      title: Text(
                        '${interfaceData["home"]}',
                        style: AppStyle.txtPoppinsMedium22Black900_3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.person_rounded,
                          color: ColorConstant.whiteA700),
                      title: Text(
                        '${interfaceData["pf"]}',
                        style: AppStyle.txtPoppinsMedium22Black900_3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.adb_rounded,
                        color: ColorConstant.whiteA700,
                      ),
                      title: Text(
                        '${interfaceData["cb"]}',
                        style: AppStyle.txtPoppinsMedium22Black900_3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.newspaper_rounded,
                        color: ColorConstant.whiteA700,
                      ),
                      title: Text(
                        '${interfaceData["ns"]}',
                        style: AppStyle.txtPoppinsMedium22Black900_3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsPaperScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.cloud_rounded,
                        color: ColorConstant.whiteA700,
                      ),
                      title: Text(
                        '${interfaceData["wt"]}',
                        style: AppStyle.txtPoppinsMedium22Black900_3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WeatherScreen(), // Thay "SpeedScreen" bằng tên thực tế của màn hình
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.groups_rounded,
                          color: ColorConstant.whiteA700),
                      title: Text(
                        '${interfaceData["au"]}',
                        style: AppStyle.txtPoppinsMedium22Black900_3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutUsScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.info_rounded,
                          color: ColorConstant.whiteA700),
                      title: Text(
                        '${interfaceData["g"]}',
                        style: AppStyle.txtPoppinsMedium22Black900_3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HelpScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.qr_code_rounded,
                          color: ColorConstant.whiteA700),
                      title: Text(
                        '${interfaceData["qrsb"]}',
                        style: AppStyle.txtPoppinsMedium22Black900_3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout_rounded,
                          color: ColorConstant.whiteA700),
                      title: Text(
                        '${interfaceData["lo"]}',
                        style: AppStyle.txtPoppinsMedium22Black900_3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        _signOut();
                      },
                    ),
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: ColorConstant.whiteA700, width: 1.0)),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: screenWidth * 0.05,
                            left: screenWidth * 0.05,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${interfaceData["vs"]}',
                                style: AppStyle.txtPoppinsMedium20Black900_5,
                              ),
                              Text(
                                '${interfaceData["date"]}',
                                style: AppStyle.txtPoppinsMedium20Black900_6,
                              )
                            ],
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
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.03,
                right: screenWidth * 0.03,
                bottom: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${interfaceData["hi"]} ${_userView?.fullName ?? "User"}',
                      style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.whiteA700),
                    ),
                    Container(
                      width: screenWidth * 0.6, // Adjust this value as needed
                      child: Text(
                        '${interfaceData["helpyou"]}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w200,
                          color: ColorConstant.whiteA700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: screenWidth * 0.02,
                ),
                Container(
                  width: screenWidth * 0.14,
                  height: screenWidth * 0.14,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.all(Radius.circular(screenWidth * 0.1))),
                  child: IconButton(
                    icon: Icon(
                      Icons.feedback_rounded,
                      color: ColorConstant.blueNew,
                      size: screenWidth * 0.06,
                    ),
                    onPressed: () {
                      _showDialogFeedback();
                    },
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.01,
                ),
                CircleAvatar(
                  radius: screenWidth * 0.07,
                  backgroundImage: _userView != null &&
                          _userView!.imageUser != null
                      ? Image.network(
                          'http://api-languagefree.cosplane.asia/api/Image/${_userView!.imageUser}',
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ).image
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: bottomCard(context),
          ),
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

  Widget _buildBody(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to fetch news.',
              style: TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: _getNews,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (news.isEmpty) {
      return Center(child: Text('No news available.'));
    } else {
      // Extract only the first 5 news items
      final List<RssItem> topNews = news.take(5).toList();

      return CarouselSlider(
        options: CarouselOptions(
          viewportFraction: 1.0,
          // aspectRatio: 16 / 9,
          height: screenWidth * 0.45,
          enableInfiniteScroll: false,
          enlargeCenterPage: true,
          initialPage: 0,
        ),
        items: topNews.map((newsItem) {
          return Builder(
            builder: (BuildContext context) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailPage(newsItem),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      child: Image.network(
                        newsItem.imageUrl,
                        width: double.infinity,
                        height: screenWidth * 0.50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: screenWidth * 0.02,
                          left: screenWidth * 0.02,
                          right: screenWidth * 0.02),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          height: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: Align(
                            alignment: FractionalOffset.center,
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: screenWidth * 0.03,
                                  right: screenWidth * 0.03),
                              child: Text(
                                newsItem.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    }
  }

  Container bottomCard(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          top: screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(screenWidth * 0.08)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBody(context),
            SizedBox(
              height: screenWidth * 0.03,
            ),
            Text(
              '${interfaceData["translator"]}',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.040,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: screenWidth * 0.02,
            ),
            Row(
              children: [
                CustomItemHome(
                  text: '${interfaceData["tt"]}',
                  imagePath: ImageConstant.text,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TranslationScreen()),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.06,
                ),
                CustomItemHome(
                  text: '${interfaceData["co"]}',
                  imagePath: ImageConstant.conver,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SpeedScreen()),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.06,
                ),
                CustomItemHome(
                    text: '${interfaceData["img"]}',
                    imagePath: ImageConstant.imgaeTranslate,
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraScreen()),
                        ))
              ],
            ),
            SizedBox(
              height: screenWidth * 0.02,
            ),
            Text(
              '${interfaceData["or"]}',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.040,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: screenWidth * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen()),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: screenWidth * 0.18,
                          height: screenWidth * 0.18,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.1),
                            color: ColorConstant.greenNew,
                          ),
                          child: Icon(
                            Icons.adb_rounded,
                            size: screenWidth * 0.08,
                            color: ColorConstant.greenNew2,
                          )),
                      SizedBox(
                        height: screenWidth * 0.02,
                      ),
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: Container(
                            alignment: Alignment.center,
                            width: screenWidth * 0.18,
                            child: Text(
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              '${interfaceData["cb"]}',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w500,
                                  color: ColorConstant.black900),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.05,
                ),
                CustomItemService(
                  text: '${interfaceData["ns"]}',
                  color: ColorConstant.redNew,
                  icons: Icon(
                    Icons.newspaper_rounded,
                    size: screenWidth * 0.08,
                    color: Colors.red[600],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsPaperScreen()),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.05,
                ),
                CustomItemService(
                  text: '${interfaceData["wt"]}',
                  color: Colors.blue[100],
                  icons: Icon(
                    Icons.cloud_rounded,
                    size: screenWidth * 0.08,
                    color: ColorConstant.blue,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WeatherScreen()),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.05,
                ),
                CustomItemService(
                  text: '${interfaceData["qrsb"]}',
                  color: Colors.yellow[100],
                  icons: Icon(
                    Icons.qr_code_rounded,
                    size: screenWidth * 0.08,
                    color: Colors.yellow[600],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog() {
    int? _inputRate;
    final Duration retryDuration =
        Duration(minutes: 5); // Thời gian hiển thị lại là 10 phút

    Future<void> rating() async {
      final String apiUrl = 'http://api-languagefree.cosplane.asia/api/Rates';
      final int rateNum = _inputRate!;
      final int userId = userid ?? 0;
      final String location = positions ?? 'Unknown Location';
      final Rate newComment = Rate(
        userId: userId,
        rateNum: rateNum,
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
            message: '${interfaceData["yfwbtm"]}',
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
          print('Đã xảy ra lỗi khi rate. Mã lỗi: ${response.statusCode}');
        }
      } catch (e) {
        print('Đã xảy ra lỗi: $e');
      }
    }

    final _dialog = RatingDialog(
      initialRating: 4.0,
      starSize: 30,
      title: Text(
        '${interfaceData["ra"]}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      message: Text(
        '${interfaceData["tya"]}',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
      image: Image.asset(ImageConstant.logo, width: 100, height: 100),
      submitButtonText: '${interfaceData["sb"]}',
      submitButtonTextStyle: TextStyle(color: ColorConstant.blueNew),
      enableComment: false,
      onCancelled: () {
        print('cancelled');
        Future.delayed(retryDuration, () {
          _showRatingDialog();
        });
      },
      onSubmitted: (response) {
        print('rating: ${response.rating}');
        setState(() {
          _inputRate = response.rating ~/ 1;
        });
        rating();
      },
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _dialog,
    );
  }

  void _showLanguageDialog(BuildContext context) async {
    String? selectedLanguage = await SessionManager.getLangInterface();
    Map<String, bool> selectedLanguages = {};

    if (selectedLanguage != null) {
      selectedLanguages[selectedLanguage] = true;
    }

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
                  padding: const EdgeInsets.all(20.0),
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
                                  '${interfaceData["ct"]}',
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
                            horizontal: 3.0, vertical: 2.0),
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
                              countryList = _filterCountries(value);
                              print('list hahahahahahahah $countryList');
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '${interfaceData["sfc"]}',
                            hintStyle: AppStyle.txtPoppinsMedium18Grey_1,
                            suffixIcon: Icon(Icons.search),
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
                          itemCount: countryList.length,
                          itemBuilder: (BuildContext context, int index) {
                            var country = countryList[index];
                            bool isSelected =
                                selectedLanguages[country['value']] ?? false;

                            return Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: GestureDetector(
                                onTap: () async {
                                  if (country['value'] !=
                                      "No language access") {
                                    setState(() {
                                      selectedLanguages.forEach((key, value) {
                                        selectedLanguages[key] = false;
                                      });
                                      selectedLanguages[country['value']!] =
                                          true;
                                    });

                                    await SessionManager.saveLangInterface(
                                        country['value']!);
                                    String? s =
                                        await SessionManager.getLangInterface();
                                    loadData(s.toString());
                                    loadinterfaceData(s.toString());
                                    SessionManager.updateSession(
                                        uiLanguagePreference: country['value']);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ColorConstant.blueNew
                                        : Colors.white,
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
                                  child: ListTile(
                                    title: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _getFlagIcon(country['value']!),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            country['label']!,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
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
            borderRadius: BorderRadius.circular(25.0),
            child: Image.asset(
              imagePath,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ))
        : const Icon(Icons.flag);
  }

  void _showDialogFeedback() {
    String removePlusSign(String str) {
      return str.replaceAll('+', '');
    }

    String? _inputText;
    Future<void> postComment() async {
      final String apiUrl =
          'http://api-languagefree.cosplane.asia/api/Comments';
      final String comment = _inputText!;
      final int? userId = userid; //ADDUID
      final int pageId = 4;
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
