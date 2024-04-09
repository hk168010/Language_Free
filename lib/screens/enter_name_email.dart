import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:dashboard/models/session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:dashboard/DTO/users.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/theme/app_style.dart';
import 'package:dashboard/utils/color_constant.dart';
import 'package:dashboard/utils/image_constant.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnterNameEmailScreen extends StatefulWidget {
  const EnterNameEmailScreen({super.key});
  @override
  State<EnterNameEmailScreen> createState() => _EnterNameEmailScreenState();
}

class _EnterNameEmailScreenState extends State<EnterNameEmailScreen> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  String? _selectedNationality;
  String? _selectedGender;
  String? user;
  int? userid;
  bool _submitted = false;
  bool _submitted2 = false;
  bool _submitted3 = false;
  bool _check = false;
  String? token;
  List<Map<String, String>> getList() {
    return [
      {'value': 'af', 'label': 'Afrikaans'},
      {'value': 'sq', 'label': 'Albanian'},
      {'value': 'am', 'label': 'Amharic'},
      {'value': 'ar', 'label': 'Arabic'},
      {'value': 'hy', 'label': 'Armenian'},
      {'value': 'az', 'label': 'Azerbaijani'},
      {'value': 'eu', 'label': 'Basque'},
      {'value': 'bn', 'label': 'Bengali'},
      {'value': 'bg', 'label': 'Bulgarian'},
      {'value': 'ca', 'label': 'Catalan'},
      {'value': 'zh-cn', 'label': 'Chinese (Simplified)'},
      {'value': 'zh-tw', 'label': 'Chinese (Traditional)'},
      {'value': 'hr', 'label': 'Croatian'},
      {'value': 'cs', 'label': 'Czech'},
      {'value': 'da', 'label': 'Danish'},
      {'value': 'nl', 'label': 'Dutch'},
      {'value': 'en', 'label': 'English'},
      {'value': 'et', 'label': 'Estonian'},
      {'value': 'fi', 'label': 'Finnish'},
      {'value': 'fr', 'label': 'French'},
      {'value': 'gl', 'label': 'Galician'},
      {'value': 'ka', 'label': 'Georgian'},
      {'value': 'de', 'label': 'German'},
      {'value': 'el', 'label': 'Greek'},
      {'value': 'gu', 'label': 'Gujarati'},
      {'value': 'iw', 'label': 'Hebrew'},
      {'value': 'hi', 'label': 'Hindi'},
      {'value': 'hu', 'label': 'Hungarian'},
      {'value': 'is', 'label': 'Icelandic'},
      {'value': 'id', 'label': 'Indonesian'},
      {'value': 'it', 'label': 'Italian'},
      {'value': 'ja', 'label': 'Japanese'},
      {'value': 'kn', 'label': 'Kannada'},
      {'value': 'kk', 'label': 'Kazakh'},
      {'value': 'km', 'label': 'Khmer'},
      {'value': 'ko', 'label': 'Korean'},
      {'value': 'lo', 'label': 'Lao'},
      {'value': 'lv', 'label': 'Latvian'},
      {'value': 'lt', 'label': 'Lithuanian'},
      {'value': 'mk', 'label': 'Macedonian'},
      {'value': 'ms', 'label': 'Malay'},
      {'value': 'ml', 'label': 'Malayalam'},
      {'value': 'mr', 'label': 'Marathi'},
      {'value': 'mn', 'label': 'Mongolian'},
      {'value': 'my', 'label': 'Burmese'},
      {'value': 'ne', 'label': 'Nepali'},
      {'value': 'fa', 'label': 'Persian'},
      {'value': 'pl', 'label': 'Polish'},
      {'value': 'pt', 'label': 'Portuguese'},
      {'value': 'pa', 'label': 'Punjabi'},
      {'value': 'ro', 'label': 'Romanian'},
      {'value': 'ru', 'label': 'Russian'},
      {'value': 'sr', 'label': 'Serbian'},
      {'value': 'st', 'label': 'Sesotho'},
      {'value': 'si', 'label': 'Sinhala'},
      {'value': 'sk', 'label': 'Slovak'},
      {'value': 'sl', 'label': 'Slovenian'},
      {'value': 'es', 'label': 'Spanish'},
      {'value': 'sw', 'label': 'Swahili'},
      {'value': 'sv', 'label': 'Swedish'},
      {'value': 'ta', 'label': 'Tamil'},
      {'value': 'te', 'label': 'Telugu'},
      {'value': 'th', 'label': 'Thai'},
      {'value': 'tr', 'label': 'Turkish'},
      {'value': 'uk', 'label': 'Ukrainian'},
      {'value': 'ur', 'label': 'Urdu'},
      {'value': 'uz', 'label': 'Uzbek'},
      {'value': 'vi', 'label': 'Vietnamese'},
      {'value': 'xh', 'label': 'Xhosa'},
      {'value': 'zu', 'label': 'Zulu'},
    ];
  }

  String removePlusSign(String str) {
    return str.replaceAll('+', '');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImageConstant.bgIF),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: screenWidth * 0.7,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: screenHeight * 0.03,
                        left: screenHeight * 0.03,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Information',
                            style: AppStyle.txtPoppinsSemiBold40Blue_1,
                          ),
                          // SizedBox(height: screenHeight * 0),
                          Text(
                            'Enter your personal Information!',
                            textAlign: TextAlign.justify,
                            style: AppStyle.txtPoppinsSem16Grey,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          TextFields(
                              hintText: 'Full Name',
                              controller: _fullNameController,
                              errortext: _errorText1,
                              onChanged: _onNameChanged,
                              keyboardType: TextInputType.text,
                              suffixIcon: Icon(
                                Icons.person_rounded,
                                color: ColorConstant.blueNew,
                              )),
                          SizedBox(height: screenHeight * 0.02),
                          TextFields(
                              hintText: 'Email',
                              controller: _emailController,
                              errortext: _errorText5,
                              suffixIcon: Icon(Icons.email_outlined,
                                  color: ColorConstant.blueNew)),
                          SizedBox(height: screenHeight * 0.02),
                          DropdownNationality(
                            hintText: 'Nationality',
                            suffixIcon: Icon(Icons.language_rounded,
                                color: ColorConstant.blueNew),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          DropdownGender(
                            suffixIcon:
                                Icon(Icons.group, color: ColorConstant.blueNew),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Datepicker(
                            suffixIcon: Icon(Icons.calendar_month_rounded,
                                color: ColorConstant.blueNew),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              String fullName = _fullNameController.text;
                              String email = _emailController.text;

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
                              SessionManager.getUsername().then((value) {
                                if (value != null) {
                                  print('Username in Home: $value');
                                  setState(() {
                                    user = removePlusSign(value ?? "@@@@@@");
                                    print(user);
                                  });
                                } else {
                                  print('Username is null');
                                }
                              }).catchError((error) {
                                print('Error: $error');
                              });
                              setState(() {
                                _submitted = true;
                                _submitted2 = true;
                                _submitted3 = true;
                              });
                              print('Full Name: $fullName');
                              print('Email: $email');
                              print('Nationality: $_selectedNationality');
                              print('Gender: $_selectedGender');
                              print('Date of Birth: ${dateinput.text}');
                              DateTime selectedDate = DateFormat('yyyy-MM-dd')
                                  .parse(dateinput.text);
                              if (fullName.isEmpty ||
                                  fullName.length <= 2 ||
                                  fullName.length >= 30 ||
                                  _isNumberEntered ||
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
                                postUser(
                                  fullName,
                                  email,
                                  user!,
                                  _selectedGender!,
                                  DateTime.parse(dateinput.text),
                                  _selectedNationality!,
                                ).then((_) {
                                  if (_check == true) {
                                    setState(() {
                                      _check = false;
                                    });
                                    Flushbar(
                                      margin: EdgeInsets.all(15),
                                      borderRadius: BorderRadius.circular(8),
                                      message:
                                          "You have successfully registered.",
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
                                    ).show(context).then((value) =>
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(),
                                          ),
                                        ));
                                  }
                                });
                              }
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
                                    'Confirm',
                                    style: AppStyle.txtPoppinsMedium20White_2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenWidth * 0.05,
                    ),
                  ],
                ),
              )),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: screenWidth * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Copyright © 2024 SEP490_G9.',
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

  @override
  void initState() {
    _initializeToken();
    super.initState();
    // Add listeners to handle keyboard shortcuts
    _fullNameController.addListener(_handleKeyboardShortcut);
    _emailController.addListener(_handleKeyboardShortcut3);
  }

 Future<void> _initializeToken() async {
    await SessionManager.getToken().then((value) async {
      token = value;
    });
  }

  void _handleKeyboardShortcut() {
    setState(() {
      _submitted = true;
    });
  }

  void _handleKeyboardShortcut3() {
    setState(() {
      _submitted3 = true;
    });
  }

  String? get _errorText1 {
    if (!_submitted) {
      return null; // Don't show error message if form hasn't been submitted
    }

    final text = _fullNameController.value.text;
    if (_isNumberEntered) {
      return 'Please enter only alphabets';
    }
    if (text.isEmpty) {
      return 'Full Name cannot be empty';
    }
    if (text.length <= 2 || text.length >= 30) {
      return 'Text must be between 2 and 30 characters';
    }
    return null; // No error if the text meets all conditions
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
      _fullNameController.value = _fullNameController.value.copyWith(
        text: _capitalize(value), // Capitalize first letter of each word
        selection: TextSelection.collapsed(
            offset: _fullNameController.value.text.length),
      );
    });
  }

  String? get _errorText5 {
    if (!_submitted3) {
      return null; // Don't show error message if form hasn't been submitted
    }
    final text = _emailController.value.text.trim();
    if (text.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!RegExp(
            r'^(?=.{6,30}@)(?=.*[a-zA-Z])[a-zA-Z0-9]*[a-zA-Z][a-zA-Z0-9]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(text)) {
      return 'Invalid email format';
    }
    if (!text.endsWith('@gmail.com') &&
        !text.endsWith('@fpt.edu.vn') &&
        !text.endsWith('@fe.edu.vn')) {
      return 'Email must end with @gmail.com or @fpt.edu.vn or @fe.edu.vn';
    }
    return null;
  }

  String? _validateDate(String? inputDate) {
    if (!_submitted2) {
      return null; // Don't show error message if form hasn't been submitted
    }
    if (inputDate == null || inputDate.isEmpty) {
      return 'Please select a date.'; // No error if the input is empty
    }

    DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(inputDate);

    if (selectedDate.year < 1950 || selectedDate.year > 2016) {
      return 'Invalid date. Please select a date between 1950 and 2016.';
    }

    return null; // No error if the date is valid
  }

  String? _validateGender(String? selectedGender) {
    if (!_submitted2) {
      return null; // Don't show error message if form hasn't been submitted
    }
    if (selectedGender == null || selectedGender.isEmpty) {
      return 'Please select a gender.'; // Error message if gender is not selected
    }
    return null; // No error if gender is selected
  }

  String? _validateNationality(String? selectedNationality) {
    if (!_submitted2) {
      return null; // Don't show error message if form hasn't been submitted
    }
    if (selectedNationality == null || selectedNationality.isEmpty) {
      return 'Please select a nationality.'; // Error message if nationality is not selected
    }
    return null; // No error if nationality is selected
  }

  Future<void> postUser(
    String fullName,
    String email,
    String phone,
    String gender,
    DateTime dateOfBirth,
    String national,
  ) async {
    final String apiUrl = 'http://api-languagefree.cosplane.asia/api/Users';
    final DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");

    final Map<String, dynamic> userData = {
      'userId': userid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'national': national,
      'dateOfBirth': formatter.format(dateOfBirth.toUtc()),
    };
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      print('User created successfully');
      setState(() {
        _check = true;
      });
    } else {
      Flushbar(
        margin: EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(8),
        message: 'Failed to create user. Status code: ${response.statusCode}',
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

      print('Failed to create user. Status code: ${response.statusCode}');
    }
  }

  Widget TextFields({
    required String hintText,
    required Widget suffixIcon,
    required TextEditingController controller,
    required String? errortext,
    Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: ColorConstant.black900,
          textAlign: TextAlign.left,
          onChanged: onChanged,
          style: TextStyle(color: ColorConstant.black900),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errortext,
            hintStyle: AppStyle.txtPoppinsSem16Blue,
            contentPadding: EdgeInsets.only(
                left: screenWidth * 0.04, right: screenWidth * 0.04),
            filled: true, // Set filled to true
            fillColor: ColorConstant.blueNew4,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            prefixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  TextEditingController dateinput = TextEditingController();
  Widget Datepicker({
    required Widget suffixIcon,
  }) {
    return TextField(
      scrollPadding: EdgeInsets.zero,
      controller: dateinput,
      decoration: InputDecoration(
        errorText: _validateDate(dateinput.text),
        contentPadding: EdgeInsets.symmetric(vertical: 0.0),
        hintText: 'Birthday',
        hintStyle: AppStyle.txtPoppinsSem16Blue,
        filled: true, // Set filled to true
        fillColor: ColorConstant.blueNew4,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
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
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          print(formattedDate);
          setState(() {
            dateinput.text = formattedDate.toString();
          });
        } else {
          print("Date is not selected");
        }
      },
    );
  }

  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  Widget DropdownGender({
    required Widget suffixIcon,
  }) {
    return DropDownTextField(
      onChanged: (value) => {
        setState(() {
          _selectedGender = value.name.toString();
        })
      },
      textFieldDecoration: InputDecoration(
        errorText: _validateGender(_selectedGender),
        contentPadding: EdgeInsets.zero,
        hintText: 'Gender',
        hintStyle: AppStyle.txtPoppinsSem16Blue,
        filled: true, // Set filled to true
        fillColor: ColorConstant.blueNew4,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
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
      dropDownList: const [
        DropDownValueModel(name: 'Female', value: "F"),
        DropDownValueModel(name: 'Male', value: "M"),
      ],
    );
  }

  Widget DropdownNationality(
      {required Widget suffixIcon, required String hintText}) {
    return DropDownTextField(
      onChanged: (value) => {
        setState(() {
          _selectedNationality = value.name.toString();
        })
      },
      textFieldDecoration: InputDecoration(
        errorText: _validateNationality(_selectedNationality),
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        hintStyle: AppStyle.txtPoppinsSem16Blue,
        filled: true,
        fillColor: ColorConstant.blueNew4,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: suffixIcon,
      ),
      clearOption: false,
      textFieldFocusNode: textFieldFocusNode,
      searchDecoration:
          const InputDecoration(hintText: "Search your nationality"),
      dropDownItemCount: 5,
      searchShowCursor: false,
      enableSearch: true,
      dropdownColor: Colors.blue[50],
      searchKeyboardType: TextInputType.text,
      dropDownList: getList().map((map) {
        return DropDownValueModel(
            name: map['label'] ?? '', value: map['value'] ?? '');
      }).toList(),
    );
  }
}
