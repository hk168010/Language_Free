import 'dart:io';

import 'package:dashboard/app_localizations.dart';
import 'package:dashboard/models/defendency.dart';
import 'package:dashboard/screens/camera_screen.dart';
import 'package:dashboard/screens/chat_box_screen.dart';
import 'package:dashboard/screens/check_network_screen.dart';
import 'package:dashboard/screens/enter_name_email.dart';

import 'package:dashboard/screens/enter_name_phone.dart';
import 'package:dashboard/screens/help_screen.dart';
import 'package:dashboard/screens/home_screen.dart';
import 'package:dashboard/screens/intro_screen.dart';
import 'package:dashboard/screens/login_screen.dart';
import 'package:dashboard/screens/otp_screen.dart';
import 'package:dashboard/screens/profile_screen.dart';
import 'package:dashboard/screens/qr_screen.dart';
import 'package:dashboard/screens/rating_screen.dart';

import 'package:dashboard/screens/speed_screen.dart';
import 'package:dashboard/screens/weather_screen.dart';
import 'package:get/get.dart';
import 'package:dashboard/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/translation_screen.dart';
import 'package:path/path.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


void main() async {
  DependencyInjection.init();
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyB1DHA295-TI58fh0xkKB8dD07myGjYl_Q',
              appId: '1:344968909250:android:3ae21debdba873bbec065b',
              messagingSenderId: '344968909250',
              projectId: 'language-free-67116'))
      : Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return GetMaterialApp(
      title: 'Speech to Text Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: 
      IntroScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

