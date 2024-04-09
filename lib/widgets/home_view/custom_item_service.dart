import 'package:dashboard/app_export.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomItemService extends StatelessWidget {
  ///[imagePath] is required parameter for showing png,jpg,etc image
  String? imagePath;
  VoidCallback? onTap;
  Color? color;
  String? text;
  Icon? icons;

  CustomItemService(
      {Key? key, this.text, this.imagePath, this.color, this.onTap, this.icons})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.18,
            height: screenWidth * 0.18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.1),
              color: color,
            ),
            child: icons!,
          ),
          SizedBox(
            height: screenWidth * 0.02,
          ),
          Align(
              alignment: AlignmentDirectional.center,
              child: Container(
                  alignment: Alignment.center,
                  width: screenWidth * 0.18,
                  child: Text(
                    textAlign: TextAlign.left,
                    "$text",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                        color: ColorConstant.black900),
                  ))),
        ],
      ),
    );
  }
}
