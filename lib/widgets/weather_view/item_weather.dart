import 'package:flutter/material.dart';

class CustomItemWeather extends StatelessWidget {
  ///[imagePath] is required parameter for showing png,jpg,etc image
  String? imagePath;

  String? text1;

  String? text2;
  CustomItemWeather({
    Key? key,
    this.text1,
    this.text2,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Image.asset(imagePath!),
            SizedBox(
              width: screenWidth * 0.01,
            ),
            Container(
                width: screenWidth * 0.12,
                alignment: Alignment.center,
                child: Text(
                  "$text1",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.03,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w200),
                )),
          ],
        ),
        Container(
          alignment: Alignment.center,
            width: screenWidth * 0.19,
            child: Text(
              "$text2",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold),
            ))
      ],
    );
  }
}
