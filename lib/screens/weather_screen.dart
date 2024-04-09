import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/comment.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/theme/app_style.dart';
import 'package:dashboard/utils/color_constant.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar.dart';
import 'package:dashboard/widgets/app_bar/custom_app_bar1.dart';
import 'package:dashboard/widgets/app_bar/custom_bottom_app_bar.dart';
import 'package:dashboard/widgets/weather_view/item_weather.dart';
import 'package:dashboard/widgets/weather_view/item_weather2.dart';
import 'package:dashboard/widgets/weather_view/list_weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import '../services/consts.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  TextEditingController _cityController = TextEditingController();
  List<Location> _coordinates = [];
  bool isLoading = false;
  int _selectedIndex = 3;
  Map<String, String> interfaceData = {};
  Timer? _debounceTimer;
  String? langSession = '';
  Weather? _currentWeather;
  List<Weather> _forecastWeather = [];
  Map<String, String> data = {};
  String? positions;
  int? userid; //ADDUID
  String? token;
  @override
  void initState() {
    _initializeToken();
    super.initState();
    _getCurrentLocation();
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

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  Future<void> _initialize() async {
    await _getCurrentLocation2();
    AccessLogs();
  }

  //ADDUID
  String removePlusSign(String str) {
    return str.replaceAll('+', '');
  }

  Future<void> _getCurrentLocation2() async {
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
    final int pageId = 9;
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _getWeatherByLocation(position.latitude, position.longitude);

      print(position);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _getWeatherByLocation(double latitude, double longitude) async {
    try {
      Weather currentWeather = await _wf.currentWeatherByLocation(
        latitude,
        longitude,
      );
      List<Weather> forecastWeather = await _wf.fiveDayForecastByLocation(
        latitude,
        longitude,
      );
      forecastWeather.removeWhere((weather) {
        return weather.date?.hour == 4;
      });
      forecastWeather.removeWhere((weather) {
        return weather.date?.hour == 1;
      });
      forecastWeather.removeWhere((weather) {
        return weather.date?.hour == 16;
      });
      forecastWeather.removeWhere((weather) {
        return weather.date?.hour == 22;
      });
      List<List<Weather>> dailyForecastWeather = [];

      for (int i = 0; i < forecastWeather.length; i += 4) {
        dailyForecastWeather.add(forecastWeather.sublist(i, i + 4));
      }
      forecastWeather.clear();
      dailyForecastWeather.forEach((dailyWeather) {
        forecastWeather.addAll(dailyWeather);
        print("huyaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        print(forecastWeather);
      });

      setState(() {
        _currentWeather = currentWeather;
        _forecastWeather = forecastWeather;
      });
    } catch (e) {
      print("Error getting weather: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_currentWeather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: CustomAppBar1(
        titleKey: '${interfaceData["wt"]}',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: screenHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImageConstant.bgWeather),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
                      ),
                      _citySearch(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      _locationHeader(),
                      _weatherIcon(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      _extraInfo(),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _citySearch() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding:
          EdgeInsets.only(left: screenWidth * 0.05, right: screenWidth * 0.05),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        decoration: BoxDecoration(
          color: ColorConstant.whiteA700,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: '${interfaceData["sfac"]}',
                  hintStyle: TextStyle(color: ColorConstant.gray),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.1),
            GestureDetector(
              onTap: () {
                _getCoordinates();
              },
              child: Icon(
                Icons.search,
                color: ColorConstant.greyNew9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationHeader() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Text(
          _currentWeather?.areaName ?? "",
          style: AppStyle.txtPoppinsSemiBold30_2
              .copyWith(fontSize: screenWidth * 0.06),
        ),
        Text(
            DateFormat('EEE, MMM d')
                .format(_currentWeather?.date ?? DateTime.now()),
            style: AppStyle.txtPoppinsSemiBold15_2
                .copyWith(fontSize: screenWidth * 0.03)),
      ],
    );
  }

  Widget _weatherIcon() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentWeather != null && _currentWeather!.weatherIcon != null)
          Image.network(
            width: screenWidth * 0.45,
            height: screenWidth * 0.45,
            scale: 1.5,
            "http://openweathermap.org/img/wn/${_currentWeather?.weatherIcon}@4x.png",
            fit: BoxFit.fill,
          ),
        Text(
          "${_currentWeather?.temperature?.celsius?.toStringAsFixed(0)}°C",
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter'),
        ),
        Text(
          _currentWeather?.weatherDescription?.toUpperCase() ?? "",
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.03,
              fontFamily: 'Inter'),
        ),
      ],
    );
  }

  Widget _extraInfo() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.088,
          width: MediaQuery.sizeOf(context).width * 0.90,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ColorConstant.blueNew.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
            color: ColorConstant.blueNew,
            borderRadius: BorderRadius.circular(
              screenWidth * 0.1,
            ),
          ),
          padding: EdgeInsets.only(
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: screenWidth * 0.02,
              bottom: screenWidth * 0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomItemWeather(
                text1: "${interfaceData["max"]}",
                imagePath: ImageConstant.iconMax,
                text2:
                    "${_currentWeather?.tempMax?.celsius?.toStringAsFixed(0)}°C",
              ),
              Container(
                width: screenWidth * 0.01,
                color: Colors.white,
              ),
              CustomItemWeather(
                text1: "${interfaceData["min"]}",
                imagePath: ImageConstant.iconMin,
                text2:
                    "${_currentWeather?.tempMin?.celsius?.toStringAsFixed(0)}°C",
              ),
              Container(
                width: screenWidth * 0.01,
                color: Colors.white,
              ),
              CustomItemWeather(
                text1: "${interfaceData["wind"]}",
                imagePath: ImageConstant.iconWind,
                text2: "${_currentWeather?.windSpeed}m/s",
              ),
              Container(
                width: screenWidth * 0.01,
                color: Colors.white,
              ),
              CustomItemWeather(
                text1: "${interfaceData["hu"]}",
                imagePath: ImageConstant.iconHumidity,
                text2: "${_currentWeather?.humidity}%",
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenWidth * 0.04,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForecastWeatherWidget(
                  cityName: _cityController.text.trim(),
                  currentWeather: _currentWeather,
                  forecastWeather: _forecastWeather,
                ),
              ),
            );
          },
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.7,
            decoration: BoxDecoration(
                color: ColorConstant.blueNew,
                borderRadius:
                    BorderRadius.all(Radius.circular(screenWidth * 0.02))),
            padding: EdgeInsets.all(screenWidth * 0.02),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: ColorConstant.whiteA700,
                  size: screenWidth * 0.04,
                ),
                SizedBox(
                  width: screenWidth * 0.02,
                ),
                Text(
                  '${interfaceData["df"]}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontFamily: 'Inter'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _getCoordinates() async {
    String cityName = _cityController.text.trim();
    if (cityName.isNotEmpty) {
      try {
        if (await Connectivity().checkConnectivity() ==
            ConnectivityResult.none) {
          print('No internet connection');
          return;
        }
        setState(() {
          isLoading = true;
        });
        List<Location> locations = await locationFromAddress(cityName);
        if (locations.isNotEmpty) {
          double latitude = locations[0].latitude;
          double longitude = locations[0].longitude;
          print('Latitude: $latitude, Longitude: $longitude');
          await _getWeatherByLocation(latitude, longitude);
        }
        setState(() {
          isLoading = false;
        });
      } on PlatformException catch (e) {
        print('Error: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.message}'),
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        print('$e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDialogFeedback() {
    String? _inputText;
    Future<void> postComment() async {
      final String apiUrl =
          'http://api-languagefree.cosplane.asia/api/Comments';
      final String comment = _inputText!;
      final int? userId = userid;
      final int pageId = 9;
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
                            width: 1.0, color: ColorConstant.greyNew2),
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
