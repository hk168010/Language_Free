import 'package:dashboard/widgets/login_view.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      title: 'Login View',
      home: Container(
        width: screenWidth,
        height: screenHeight,
        child: LoginView(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
