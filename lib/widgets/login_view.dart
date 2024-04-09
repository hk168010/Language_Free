import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/DTO/accounts.dart';
import 'package:dashboard/app_export.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:dashboard/screens/enter_name_email.dart';
import 'package:dashboard/screens/enter_name_phone.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/screens/otp_screen.dart';
import 'package:dashboard/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../DTO/country.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool? check;
  bool? checkUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late String verificationId;
  TextEditingController phonenumberController = TextEditingController();
  String phoneNumber = "", data = "";
  String smscode = "";
  bool captchaVerified = false;
  TextEditingController _codeController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  String smsCode = "";
  bool rememberUser = false;
  bool isWrongPhoneNumber = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? userid;
  bool isLocked = false;
  String? token;
  @override
  void initState() {
    _initializeToken();
    super.initState();
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
        // Xử lý dữ liệu nhận được từ API ở đây
        print('Huyyyyyyyyyyyyyyyyyyyyyyy $responseData');
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
        }
      }
    } catch (error) {
      print('Đã xảy ra lỗi khi gọi API: $error');
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

  void _handleSignOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (error) {
      print("Error signing out: $error");
    }
  }

  void onCaptchaVerified() {
    setState(() {
      captchaVerified = true;
    });
  }

  void _signInWithMobileNumber() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+84' + phonenumberController.text.trim(),
        verificationCompleted: (PhoneAuthCredential authCredential) async {
          SessionManager.saveUsername(phoneNumber);
        },
        verificationFailed: (FirebaseAuthException error) {
          SessionManager.saveUsername(phoneNumber);
          print("Verification Failed: ${error.message}");
          if (error.message ==
              'We have blocked all requests from this device due to unusual activity. Try again later.') {
            Flushbar(
              margin: EdgeInsets.all(15),
              borderRadius: BorderRadius.circular(8),
              message:
                  "Sending too many OTPs is overloading the system! Try again later!",
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
        codeSent: (String verificationId, [int? forceResendingToken]) {
          this.verificationId = verificationId;
          print('Verification ID in send: $verificationId');
          if (verificationId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: verificationId,
                ),
              ),
            );
          } else {
            print('Verification ID is empty');
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: Duration(seconds: 45),
      );
    } catch (e) {
      print(e);
    }
  }

  //Hàm Format SĐT
  String? _validatePhoneNumber(String value) {
    // Kiểm tra định dạng số điện thoại, ví dụ: 1234567890
    return RegExp(r'^[1-9][0-9]{8}?$').hasMatch(value)
        ? null
        : 'Invalid phone number';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImageConstant
                  .bgLogin), // Thay đổi đường dẫn tới hình ảnh của bạn
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            // Wrap the entire content in a SingleChildScrollView
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenHeight * 0.35,
                  ),
                  Text(
                    'Access',
                    style: AppStyle.txtPoppinsSemiBold40Blue_1,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Enter your phone number',
                    textAlign: TextAlign.justify,
                    style: AppStyle.txtPoppinsSem16Grey,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownMenuExample(),
                      SizedBox(
                        width: screenWidth * 0.02,
                      ),
                      Expanded(
                        child: TextFields(
                            isWrongPhoneNumber, phonenumberController),
                      )
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  ElevatedButton(
                    onPressed: () {
                      if (!isWrongPhoneNumber) {
                        _signInWithMobileNumber();
                      } else {
                        Flushbar(
                          margin: EdgeInsets.all(15),
                          borderRadius: BorderRadius.circular(8),
                          message: "The phone number is invalid!!",
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
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: ColorConstant.blueNew,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: screenWidth * 0.04, bottom: screenWidth * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confirm',
                            style: AppStyle.txtPoppinsMedium20White_2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'or start with',
                    style: AppStyle.txtPoppinsMedium15Black
                        .copyWith(color: Colors.black),
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
                        backgroundColor:
                            ColorConstant.greyNew6.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: screenWidth * 0.04,
                            bottom: screenWidth * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              ImageConstant.google,
                              height: screenHeight * 0.03,
                              width: screenHeight * 0.03,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              'Google',
                              style: AppStyle.txtPoppinsMedium20White_2
                                  .copyWith(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
    );
  }

  Widget TextFields(bool isWrong, TextEditingController controller,
      {bool isOTP = false}) {
    bool isValid = _validatePhoneNumber(controller.text) == null;

    String hintText = 'Phone Number';
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: TextStyle(
              color: ColorConstant.black900, fontSize: screenWidth * 0.035),
          cursorColor: ColorConstant.black900,
          controller: controller,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppStyle.txtPoppinsSem16Blue,
            contentPadding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                top: screenWidth * 0.02,
                bottom: screenWidth * 0.02),
            filled: true, // Set filled to true
            fillColor: ColorConstant.blueNew4,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isValid
                ? Icon(
                    Icons.done,
                    size: screenWidth * 0.05,
                  )
                : isWrong
                    ? Icon(Icons.close, size: screenWidth * 0.05)
                    : null,
          ),
          onChanged: (value) {
            // Kiểm tra và cập nhật thông báo lỗi khi giá trị thay đổi
            setState(() {
              isWrongPhoneNumber = _validatePhoneNumber(value) != null;
            });
          },
        ),
      ],
    );
  }
}

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

class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({Key? key}) : super(key: key);

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
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
      },
      onCanceled: () {
        // Xử lý khi người dùng hủy bỏ dropdown menu
        setState(() {
          isItemSelected = false; // Đánh dấu là không có mục nào được chọn
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: ColorConstant.blueNew4,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        width: screenWidth * 0.2,
        height: screenWidth * 0.13,
        // padding: EdgeInsets.symmetric(horizontal: 10),
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
    );
  }
}

class MoveableFab9 extends StatefulWidget {
  final double initialTop;
  final double initialLeft;

  const MoveableFab9({
    Key? key,
    required this.initialTop,
    required this.initialLeft,
  }) : super(key: key);
  @override
  _MoveableFab9State createState() => _MoveableFab9State();
}

class _MoveableFab9State extends State<MoveableFab9> {
  late double _fabTop;
  late double _fabLeft;

  @override
  void initState() {
    super.initState();
    _fabTop = widget.initialTop;
    _fabLeft = widget.initialLeft;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          top: _fabTop,
          left: _fabLeft,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // Cập nhật vị trí của FAB dựa trên cử chỉ của người dùng
                _fabTop += details.delta.dy;
                _fabLeft += details.delta.dx;
              });
            },
            child: FloatingActionButton(
              backgroundColor: ColorConstant.blueNew4,
              onPressed: () {
                _showDialogFeedback();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth *
                    0.1), // Điều chỉnh giá trị để thay đổi độ cong
              ),
              child: Icon(
                Icons.feedback_rounded,
                color: ColorConstant.blueNew,
              ),
            ),
          ),
        ),
        // Các thành phần khác của giao diện
      ],
    );
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
