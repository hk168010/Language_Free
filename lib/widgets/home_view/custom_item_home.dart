import 'package:dashboard/app_export.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomItemHome extends StatelessWidget {
  ///[imagePath] is required parameter for showing png,jpg,etc image
  String? imagePath;
  VoidCallback? onTap;
  String? text;
  CustomItemHome({
    Key? key,
    this.text,
    this.imagePath,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: screenWidth * 0.26,
          height: screenWidth * 0.26,
          padding: EdgeInsets.all(screenWidth * 0.02),
          decoration: BoxDecoration(
            color: ColorConstant.greyNew,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  imagePath!,
                  width: screenWidth * 0.1,
                  height: screenWidth * 0.1,
                ),
              ),
              SizedBox(
                height: screenWidth * 0.01,
              ),
              Container(
                height: screenWidth * 0.11,
                child: Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Text(
                      textAlign: TextAlign.left,
                      "$text",
                      style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          fontWeight: FontWeight.w500,
                          color: ColorConstant.black900),
                    )),
              ),
            ],
          ),
        ));
  }
}
