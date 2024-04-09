import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/accounts.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/enter_name_email.dart';
import 'package:dashboard/screens/enter_name_phone.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OTPScreen extends StatefulWidget {
  final String verificationId; //Add : Thêm vô để nó nhận giá trị truyền qua
  OTPScreen({Key? key, required this.verificationId}) : super(key: key);
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool? check;
  bool? checkUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late String verificationId;
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController OTPController = TextEditingController();
  String phoneNumber = "", data = "";
  String smscode = "";
  bool rememberUser = false;
  bool isWrongPhoneNumber = false;
  bool isWrongOTP = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? userid;
  bool isLocked = false;
  String? token;
  //Hàm Xác Nhận OTP
  @override
  void initState() {
    _initializeToken();
    super.initState();
    verificationId =
        widget.verificationId; //Add : Thêm vô để nó lấy giá trị ở trên
    print('Verification ID in initState: $verificationId');
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    TextEditingController controller;

    return MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
              icon: Icon(Icons.arrow_back)),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: ColorConstant.whiteA700,
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: screenWidth * 0.18,
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                    right: screenHeight * 0.05, left: screenHeight * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImageView(
                      imagePath: ImageConstant.bgOTP,
                      width: 200.0 * screenWidth / 200.0,
                      height: 200 * screenWidth / 300.0,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Verification',
                      style: AppStyle.txtPoppinsSemiBold40Blue_1,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Enter the 6-digit code sent to your phone',
                      textAlign: TextAlign.justify,
                      style: AppStyle.txtPoppinsSem16Grey,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    OtpTextField(
                      textStyle: TextStyle(fontSize: screenWidth * 0.04),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      fieldWidth: screenWidth * 0.09,
                      enabledBorderColor: ColorConstant.blueNew,
                      numberOfFields: 6,
                      autoFocus: true,
                      cursorColor: ColorConstant.blueNew,
                      borderColor: ColorConstant.blueNew,
                      focusedBorderColor: ColorConstant.blueNew,
                      showFieldAsBox: true,
                      onCodeChanged: (String code) {
                        OTPController.text = code;
                      },
                      onSubmit: (String verificationCode) {
                        OTPController.text = verificationCode;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    ElevatedButton(
                      onPressed: () {
                        _verifyOTP();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.1),
                        ),
                        primary: ColorConstant.blueNew,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.04,
                            bottom: screenWidth * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Access',
                              style: AppStyle.txtPoppinsMedium20White_2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: screenWidth * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create by',
                style: AppStyle.txtPoppinsSem16Grey_2,
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
                      style: AppStyle.txtPoppinsSem16Grey_2
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                        text: ' Free', style: AppStyle.txtPoppinsSem16Grey_2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (error) {
      print("Error signing out: $error");
    }
  }

  Future<void> _checkAccountExist(String username) async {
    final url = Uri.parse(
        'http://api-languagefree.cosplane.asia/api/Accounts/checkAccountExist/$username');

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          check = responseData['isChecked'];
        });
        print('Huyyyyyyyyyyyyyyyyyyyyyyy $responseData');
      } else {
        print(
            'Request failed with statusHuyyyyyyyyyyyyyyyyyyyyyyy: ${response.statusCode}');
      }
    } catch (e) {
      print('ErrorHuyyyyyyyyyyyyyyyyyyyyyyy: $e');
    }
  }

  Future<void> postAccount(String user) async {
    final String apiUrl = 'http://api-languagefree.cosplane.asia/api/Accounts';
    final String username = removePlusSign(user);
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
        print('Huyyyyyyyyyyyyyyyyyyyyyyy111111111 $check');
      } else {
        print(
            'Request failed with statusHuyyyyyyyyyyyyyyyyyyyyyyy: ${response.statusCode}');
      }
    } catch (e) {
      print('ErrorHuyyyyyyyyyyyyyyyyyyyyyyy: $e');
    }
  }

  Future<void> getAccountsToSession(String username) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
      'accept': '*/*',
    };
    final response = await http.get(
      Uri.parse(
          'http://api-languagefree.cosplane.asia/api/Accounts/getAccountsToSession/$username'),
      headers: headers,
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

  String removePlusSign(String str) {
    return str.replaceAll('+', '');
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
        }
      }
    } catch (error) {
      print('Đã xảy ra lỗi khi gọi API: $error');
    }
  }

  _verifyOTP() async {
    try {
      if (verificationId != null) {
        print("HuyyyyyyyyyyyyyyyVer $verificationId");
        PhoneAuthCredential _credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: OTPController.text.trim(),
        );
        await _auth.signInWithCredential(_credential).then((result) async {
          if (result.user != null) {
            SessionManager.saveLoginTime(DateTime.now());
            SessionManager.saveUsername(result.user!.phoneNumber ?? "");
            print('object');
            print(result.user!.phoneNumber);
            String cut =
                removePlusSign(result.user!.phoneNumber ?? "@@@@@@@@@@@@");
            await checkLogin(cut);
            await _checkAccountExist(cut);
            if (check == true) {
              await _checkUserExist(cut);
              if (checkUser == true) {
                await getAccountsToSession(cut);
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
                print(isSignedIn);
                await getAccountsToSession(cut);
                SessionManager.saveUserId(userid ?? "@@");
                if (isSignedIn == false) {
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
                } else {
                  if (!isLocked) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EnterNameScreen()),
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
              await postAccount(cut);
              await _checkUserExist(cut);
              print(cut);
              await getAccountsToSession(cut);
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
            setState(() {
              isWrongOTP = true;
            });
            Flushbar(
              margin: EdgeInsets.all(15),
              borderRadius: BorderRadius.circular(8),
              message: "Authentication failed. Please check your OTP.",
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
        }).catchError((e) {
          print(e);
          setState(() {
            isWrongOTP = true;
          });
          Flushbar(
            margin: EdgeInsets.all(15),
            borderRadius: BorderRadius.circular(8),
            message: "$e",
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
        });
      } else {
        print("Verification ID is null. Cannot verify OTP.");
        Flushbar(
          margin: EdgeInsets.all(15),
          borderRadius: BorderRadius.circular(8),
          message: "Authentication failed. Please check your OTP.",
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
    } catch (e) {
      print(e);
      Flushbar(
        margin: EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(8),
        message: "$e",
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
  }
}

// class MoveableFab11 extends StatefulWidget {
//   final double initialTop;
//   final double initialLeft;

//   const MoveableFab11({
//     Key? key,
//     required this.initialTop,
//     required this.initialLeft,
//   }) : super(key: key);
//   @override
//   _MoveableFab11State createState() => _MoveableFab11State();
// }

// class _MoveableFab11State extends State<MoveableFab11> {
//   late double _fabTop;
//   late double _fabLeft;

//   @override
//   void initState() {
//     super.initState();
//     _fabTop = widget.initialTop;
//     _fabLeft = widget.initialLeft;
//   }

  // @override
  // Widget build(BuildContext context) {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   return Stack(
  //     children: [
  //       Positioned(
  //         top: _fabTop,
  //         left: _fabLeft,
  //         child: GestureDetector(
  //           onPanUpdate: (details) {
  //             setState(() {
  //               // Cập nhật vị trí của FAB dựa trên cử chỉ của người dùng
  //               _fabTop += details.delta.dy;
  //               _fabLeft += details.delta.dx;
  //             });
  //           },
  //           child: FloatingActionButton(
  //             backgroundColor: ColorConstant.blueNew4,
  //             onPressed: () {
  //               _showDialogFeedback();
  //             },
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(screenWidth *
  //                   0.1), // Điều chỉnh giá trị để thay đổi độ cong
  //             ),
  //             child: Icon(
  //               Icons.feedback_rounded,
  //               color: ColorConstant.blueNew,
  //             ),
  //           ),
  //         ),
  //       ),
  //       // Các thành phần khác của giao diện
  //     ],
  //   );
  // }

  // void _showDialogFeedback() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         double screenWidth = MediaQuery.of(context).size.width;
  //         return AlertDialog(
  //           backgroundColor: Colors.white,
  //           title: Stack(
  //             alignment: Alignment.center,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   GestureDetector(
  //                       onTap: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                       child: const Icon(
  //                         Icons.close_rounded,
  //                         color: Colors.black,
  //                       ))
  //                 ],
  //               ),
  //               Padding(
  //                 padding: EdgeInsets.only(
  //                     left: screenWidth * 0.1, right: screenWidth * 0.1),
  //                 child: Container(
  //                   alignment: Alignment.center,
  //                   decoration: BoxDecoration(
  //                     border: Border(
  //                       bottom: BorderSide(
  //                           width: 1.0,
  //                           color: ColorConstant
  //                               .greyNew2), // Đặt kích thước và màu cho đường viền dưới
  //                     ),
  //                   ),
  //                   child: Text(
  //                     'Feedback',
  //                     style: TextStyle(
  //                         fontSize: screenWidth * 0.06,
  //                         fontFamily: 'Inter',
  //                         fontWeight: FontWeight.w400,
  //                         color: ColorConstant.blueNew),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           content: TextField(
  //             cursorColor: ColorConstant.black900,
  //             textAlign: TextAlign.left,
  //             maxLines: 10,
  //             style: TextStyle(color: ColorConstant.black900),
  //             decoration: InputDecoration(
  //               hintText: 'Enter your feedback here...',
  //               hintStyle: AppStyle.txtPoppinsSem16Blue,
  //               contentPadding: EdgeInsets.only(
  //                   left: screenWidth * 0.02, right: screenWidth * 0.02),
  //               filled: true, // Set filled to true
  //               fillColor: ColorConstant.whiteA700,
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(10.0),
  //                 borderSide: BorderSide.none,
  //               ),
  //             ),
  //           ),
  //           actions: [
  //             Align(
  //               alignment: Alignment.center,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Container(
  //                   width: screenWidth * 0.4,
  //                   decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.all(
  //                           Radius.circular(screenWidth * 0.1)),
  //                       color: ColorConstant.blueNew),
  //                   padding: EdgeInsets.all(screenWidth * 0.02),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       Text(
  //                         'Submit',
  //                         style: TextStyle(
  //                             fontFamily: 'Inter',
  //                             fontWeight: FontWeight.w300,
  //                             color: ColorConstant.whiteA700),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }
