import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/accounts.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/enter_name_email.dart';
import 'package:dashboard/screens/enter_name_phone.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool? check;
  bool? checkUser;
  String? userid;
  bool isLocked = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String? token;
  @override
  void initState() {
    _initializeToken();
    SessionManager.updateSession(
      uiLanguagePreference: 'en',
      translationLanguageFrom: 'vi',
      translationLanguageTo: 'en',
      conversationLanguageFrom: 'vi_VN',
      conversationLanguageTo: 'en_GB',
      pictureLangTo: 'en',
    );
    super.initState();
  }

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  void _handleGoogleSignIn() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await _auth.signInWithCredential(googleCredential);
      if (googleUser != null) {
        print("User email: ${googleUser.email}");
        await checkLogin(googleUser.email);
        SessionManager.saveUsername(googleUser.email);
        await _checkAccountExist(googleUser.email);
        if (check == true) {
          await _checkUserExist(googleUser.email);
          if (checkUser == true) {
            await getAccountsToSession(googleUser.email);
            SessionManager.saveUserId(userid ?? "@@");
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
            }
          } else {
            bool isSignedIn = await _googleSignIn.isSignedIn();
            print('Dang sigin  $isSignedIn');
            await getAccountsToSession(googleUser.email);
            SessionManager.saveUserId(userid ?? "@@");
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
              }
            }
          }
        } else {
          await postAccount(googleUser.email);
          await checkLogin(googleUser.email);
          await _checkUserExist(googleUser.email);
          await getAccountsToSession(googleUser.email);
          SessionManager.saveUserId(userid ?? "@@");
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
            }
          } else {
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
            }
          }
        }
      } else {
        print("Sign-in with Google failed. User is null.");
      }
    } catch (error) {
      print("Error during Google Sign-In: $error");
    }
  }

  Future<void> postAccount(String user) async {
    final String apiUrl = 'http://api-languagefree.cosplane.asia/api/Accounts';
    final String username = user;
    final String password = '';
    final Account newAccount = Account(
      username: username,
      password: password,
    );
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newAccount.toJson()),
      );

      if (response.statusCode == 200) {
        print('Up thành công.');
      } else {
        print('Đã xảy ra lỗi. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('Đã xảy ra lỗi: $e');
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
    } else {
      print('Failed to load data, status code: ${response.statusCode}');
    }
  }

  Future<void> _checkAccountExist(String username) async {
    final url = Uri.parse(
        'http://api-languagefree.cosplane.asia/api/Accounts/checkAccountExist/$username');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          check = responseData['isChecked'];
        });
        print('Huyyyyyyyyyyyyyyyyyyyyyyy $check');
      } else {
        print(
            'Request failed with statusHuyyyyyyyyyyyyyyyyyyyyyyy: ${response.statusCode}');
      }
    } catch (e) {
      print('ErrorHuyyyyyyyyyyyyyyyyyyyyyyy: $e');
    }
  }

  Future<void> _checkUserExist(String username) async {
    final url = Uri.parse(
        'http://api-languagefree.cosplane.asia/api/Users/checkUserExist/$username');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          checkUser = responseData['isChecked'];
        });
        print('Huyyyyyyyyyyyyyyyyyyyyyyy111111111 $check');
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

  void _handleSignOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (error) {
      print("Error signing out: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
        navigatorKey: _navigatorKey,
        home: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SingleChildScrollView(
            child: Container(
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImageConstant
                      .bgWelcome), // Thay đổi đường dẫn tới hình ảnh của bạn
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenWidth * 0.3,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.1, right: screenWidth * 0.1),
                    child: Text(
                      'Language assistant for multinational travelers.',
                      style: AppStyle.txtPoppinsSemiBold35,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.1, right: screenHeight * 0.1),
                        child: Text(
                          textAlign: TextAlign.left,
                          'Please select a method to get started',
                          style: AppStyle.txtPoppinsItalic15White_1,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.1, right: screenWidth * 0.1),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            primary: ColorConstant.greyNew6.withOpacity(0.2),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: screenWidth * 0.04,
                                bottom: screenWidth * 0.04),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_android,
                                  color: ColorConstant.whiteA700,
                                  size: screenWidth * 0.05,
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  'Phone Number',
                                  style: AppStyle.txtPoppinsMedium20White_2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'or start with',
                        style: AppStyle.txtPoppinsMedium15White,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.1, right: screenWidth * 0.1),
                        child: ElevatedButton(
                          onPressed: () {
                            _handleGoogleSignIn();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            primary: ColorConstant.greyNew6.withOpacity(0.2),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: screenWidth * 0.04,
                                bottom: screenWidth * 0.04),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  ImageConstant.google,
                                  height: screenHeight * 0.03,
                                  width: screenHeight * 0.03,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  'Google',
                                  style: AppStyle.txtPoppinsMedium20White_2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create by',
                  style: AppStyle.txtPoppinsSem16white_2,
                ),
                Image.asset(
                  ImageConstant.logo,
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Language',
                        style: AppStyle.txtPoppinsSem16white_2
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                          text: ' Free',
                          style: AppStyle.txtPoppinsSem16white_2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _showDialogFeedback() {
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
                      'Feedback',
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
              cursorColor: ColorConstant.black900,
              textAlign: TextAlign.left,
              maxLines: 10,
              style: TextStyle(color: ColorConstant.black900),
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
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
                          'Submit',
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
