import 'dart:async';
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:dashboard/DTO/rate.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/utils/image_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:rating_dialog/rating_dialog.dart';

class _ExampleScreenState extends State<ExampleScreen> {
  Map<String, String> interfaceData = {};
  Timer? _debounceTimer;
  String? token;
  String? langSession = '';
  String? positions;

  @override
  void initState() {
    _initializeToken();
    _getCurrentLocation();
    super.initState();
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
  }

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
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
      String? currentPosition = await getLocationFromCoordinates(
          position.latitude, position.longitude);
      if (currentPosition != null) {
        print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa $currentPosition');
        setState(() {
          positions = currentPosition;
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
        String? country6 = placemark.name;
        String? country7 = placemark.administrativeArea;
        addressname = '$country6, $country5, $country2, $country7, $country';

        print('dia chi nha$addressname');
        print('dia chi quoc gia$country');
        print('dia chi quoc gia2$country2');
        print('dia chi quoc gia5$country5');
        print('dia chi quoc gia6$country6');
        print('dia chi quoc gia7$country7');
        return addressname;
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting location from coordinates: $e");
      return null;
    }
  }

  void _showRatingDialog() {
    int? _inputRate;
    Future<void> rating() async {
      final String apiUrl = 'http://api-languagefree.cosplane.asia/api/Rates';
      final int rateNum = _inputRate!;
      final int userId = 1;
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

    void _rateAndReviewApp() async {
      final _inAppReview = InAppReview.instance;

      if (await _inAppReview.isAvailable()) {
        print('request actual review from store');
        _inAppReview.requestReview();
      } else {
        print('open actual store listing');
        _inAppReview.openStoreListing(
          appStoreId: '<your app store id>',
          microsoftStoreId: '<your microsoft store id>',
        );
      }
    }

    final _dialog = RatingDialog(
      initialRating: 1.0,
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
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print('rating: ${response.rating}');
        setState(() {
          _inputRate = response.rating ~/ 1;
        });
        if (response.rating < 3.0) {
        } else {
          _rateAndReviewApp();
        }
        rating();
      },
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rating Dialog Example')),
      body: Container(
        child: Center(
          child: ElevatedButton(
            child: const Text('Show Rating Dialog'),
            onPressed: _showRatingDialog,
          ),
        ),
      ),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen();

  @override
  _ExampleScreenState createState() => new _ExampleScreenState();
}
