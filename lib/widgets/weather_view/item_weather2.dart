import 'package:dashboard/utils/color_constant.dart';
import 'package:flutter/material.dart';

class CustomItemWeather2 extends StatelessWidget {
  ///[url] is required parameter for fetching network image
  String? url;

  String? text1;

  String? text2;
  CustomItemWeather2({
    Key? key,
    this.text1,
    this.text2,
    this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.20,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: ColorConstant.purpleNew5.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        color: ColorConstant.purpleNew5,
        borderRadius: BorderRadius.circular(
          screenWidth * 0.02,
        ),
      ),
      padding: EdgeInsets.only(
          left: screenWidth * 0.02,
          right: screenWidth * 0.02,
          top: screenWidth * 0.01,
          bottom: screenWidth * 0.01),
      child: Column(
        children: [
          Image.network(
            url!,
            scale: 0.5,
          ),
     
          Text(
            text1!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.03,
                fontFamily: 'Inter'),
          ),
     
          Text(
            text2!,
            style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.03,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
