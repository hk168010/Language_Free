import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/enter_name_email.dart';
import 'package:dashboard/screens/enter_name_phone.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/screens/welcome_screen.dart';
import 'package:dashboard/utils/color_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dashboard/utils/image_constant.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? userid;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool? checkUser;
  bool? checkAcc;
  String? check;
  bool isLocked = false;
  String? token;
  @override
  void initState() {
    _initializeToken();
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _scaleAnimation =
        Tween<double>(begin: 0.5, end: 1.0).animate(_animationController);
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    _animationController.addStatusListener((status) async {
      await SessionManager.getUsername().then((value) {
        print('Gía trị của session là: $value');
        setState(() {
          check = value;
        });
      });
      await _checkAccountExist(removePlusSign(check ?? "@@@@@@@@@"));
      if (status == AnimationStatus.completed) {
        if (check == null || check?.isEmpty == true || checkAcc == false) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => WelcomeScreen(),
          ));
        } else {
          await _checkUserExist(removePlusSign(check ?? "@@@@@@@@@"));
          await getAccountsToSession(removePlusSign(check ?? "@@@@@@@@@"));
          await checkLogin(removePlusSign(check ?? "@@@"));
          SessionManager.saveUserId(userid ?? "@@@");
          if (checkUser == true) {
            if (!isLocked) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else {
              _handleSignOut();
              setState(() {
                isLocked = false;
              });
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => WelcomeScreen(),
              ));
            }
          } else {
            bool isSignedIn = await _googleSignIn.isSignedIn();
            print(isSignedIn);
            await getAccountsToSession(removePlusSign(check ?? "@@@@@@@@@"));
            SessionManager.saveUserId(userid?? "@@@");
            if (isSignedIn == true) {
              if (!isLocked) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EnterNameScreen()),
                );
              } else {
                _handleSignOut();
                setState(() {
                  isLocked = false;
                });
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => WelcomeScreen(),
                ));
              }
            } else {
              if (!isLocked) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EnterNameEmailScreen()),
                );
              } else {
                _handleSignOut();
                setState(() {
                  isLocked = false;
                });
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => WelcomeScreen(),
                ));
              }
            }
          }
        }
      }
    });
  }

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  void _handleSignOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (error) {
      print("Error signing out: $error");
    }
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
          await Flushbar(
            margin: EdgeInsets.all(15),
            borderRadius: BorderRadius.circular(8),
            message: "Your account was locked! Please try arain later!",
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
          SessionManager.clearSession();
        }
      }
    } catch (error) {
      print('Đã xảy ra lỗi khi gọi API: $error');
    }
  }

  Future<void> getAccountsToSession(String username) async {
    final response = await http.get(
      Uri.parse(
          'http://api-languagefree.cosplane.asia/api/Accounts/getAccountsToSession/$username'),
      headers: <String, String>{
        'accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final userId = data['userId'];
      // Update the state with the obtained UserId
      setState(() {
        userid = userId.toString();
      });
      print('SessionGet id $userId');
    } else {
      print('Failed to load data, status code: ${response.statusCode}');
    }
  }

  String removePlusSign(String str) {
    return str.replaceAll('+', '');
  }

  Future<void> _checkAccountExist(String username) async {
    final url = Uri.parse(
        'http://api-languagefree.cosplane.asia/api/Accounts/checkAccountExist/$username');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          checkAcc = responseData['isChecked'];
        });
        print('Huyyyyyyyyyyyyyyyyyyyyyyy $checkAcc');
      } else {
        // Xử lý lỗi nếu có
        print(
            'Request failed with statusHuyyyyyyyyyyyyyyyyyyyyyyy: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      print('ErrorHuyyyyyyyyyyyyyyyyyyyyyyy: $e');
    }
  }

  Future<void> _checkUserExist(String username) async {
    final url = Uri.parse(
        'http://api-languagefree.cosplane.asia/api/Users/checkUserExist/$username');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          checkUser = responseData['isChecked'];
        });
        print('Huyyyyyyyyyyyyyyyyyyyyyyy111111111 $checkUser');
      } else {
        // Xử lý lỗi nếu có
        print(
            'Request failed with statusHuyyyyyyyyyyyyyyyyyyyyyyy: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      print('ErrorHuyyyyyyyyyyyyyyyyyyyyyyy: $e');
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -(screenWidth * 0.6),
                left: -(screenWidth * 0.3),
                child: Container(
                  width: 200 * screenWidth / 200,
                  height: 100 * screenHeight / 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(500),
                      color: ColorConstant.blueNew3.withOpacity(0.5)),
                ),
              ),
              Positioned(
                top: -(screenWidth * 0.4),
                right: -(screenWidth * 0.2),
                child: Container(
                  width: 140 * screenWidth / 190,
                  height: 70 * screenHeight / 190,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(500),
                      color: ColorConstant.orangeNew.withOpacity(0.5)),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: screenWidth * 0.45),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FractionallySizedBox(
                        widthFactor: 0.8, // Adjust the width as needed
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              children: [
                                Image(
                                  image: AssetImage(ImageConstant.logo),
                                  fit: BoxFit.contain,
                                  width: screenWidth * 0.5,
                                  height: screenWidth * 0.5,
                                ),
                                SizedBox(
                                  height: screenWidth * 0.05,
                                ),
                                Text.rich(
                                  textAlign: TextAlign.justify,
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Language',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: screenWidth * 0.055),
                                      ),
                                      TextSpan(
                                        text: 'Free',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w200,
                                            fontSize: screenWidth * 0.055),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenWidth * 0.02,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(
                                      left: screenWidth * 0.01,
                                      right: screenWidth * 0.01),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    'CONNECT EVERYONE UNDERSTAND EVERY LANGUAGE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.035),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenWidth * 0.1,
                    ),
                    SequentialLoadingDots(),
                    SizedBox(
                      height: screenWidth * 0.2,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class SequentialLoadingDots extends StatefulWidget {
  @override
  _SequentialLoadingDotsState createState() => _SequentialLoadingDotsState();
}

class _SequentialLoadingDotsState extends State<SequentialLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();

    _animations = List.generate(3, (index) {
      return Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.33,
            (index + 1) * 0.33,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return SequentialLoadingDot(
          color: index == 0
              ? ColorConstant.green1
              : index == 1
                  ? ColorConstant.green2
                  : ColorConstant.green3,
          animation: _animations[index],
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SequentialLoadingDot extends StatelessWidget {
  final Color color;
  final Animation<double> animation;

  const SequentialLoadingDot({
    Key? key,
    required this.color,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Container(
            width: 25.0,
            height: 25.0,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            margin: EdgeInsets.symmetric(horizontal: 8.0),
          ),
        );
      },
    );
  }
}
