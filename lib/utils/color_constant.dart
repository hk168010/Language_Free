import 'dart:ui';
import 'package:flutter/material.dart';

class ColorConstant {
  static Color blue = fromHex('#0666b2');
  
  static Color blue2 = fromHex('#686FA4');

  static Color blueNew = fromHex('#193978');

  static Color blueNew3 = fromHex('#007AF5');

  static Color blueNew4 = fromHex('#E7EEF6');

  static Color orangeNew = fromHex('#F28739');

  static Color redOrange = fromHex('#f17024');

    static Color green1 = fromHex('#6f95b6');

  static Color green2 = fromHex('#bde0e6');

  static Color green3 = fromHex('#E3EBED');

   static Color grey1 = fromHex('#F2F3EF');

  static Color greyNew = fromHex('#F4F4F4');

  static Color greyNew2 = fromHex('#ABABAB');
  
  static Color greyNew3 = fromHex('#FDFDFD');

  static Color greyNew4 = fromHex('#F4F3F8');

  static Color greyNew5 = fromHex('#AFAFAF');

  static Color greyNew6 = fromHex('#D7E4FF');

   static Color greyNew7 = fromHex('#807B7B');

   static Color greyNew8 = fromHex('#E8E9E8');

  static Color greyNew9 = fromHex('#8E8686');
  
  static Color greenNew = fromHex('#E0F8E8');
  
  static Color redNew = fromHex('#FEEAED');

  static Color purpleNew = fromHex('#F8F1FF');

  static Color purpleNew1 = fromHex('#A284BB');

  static Color purpleNew2 = fromHex('#1E1A60');

  static Color purpleNew3 = fromHex('#2F246C');

  static Color purpleNew4 = fromHex('#6F63A5');

  static Color purpleNew5 = fromHex('#1E1754');

  static Color blueNew2 = fromHex('#B3D5E8');

  static Color primary = fromHex('#f2f9fe');

  static Color buttoncolor = fromHex('#3e4784');

  static Color arrowbgColor = fromHex('#e4e9f7');

  static Color iconfb = fromHex('#1a4789');

  static Color green = fromHex('#14b04c');

  static Color greenNew2 = fromHex('#4BA45F');

  static Color blue1 = fromHex('#87C4FF');

  static Color grey = fromHex('#d9d9d9');

  static Color gray = fromHex('#aaaaaa');

  static Color purple = fromHex('#FBF0FF');

  static Color purple2 = fromHex('#DED6FE');

  static Color fullcolor = fromHex('#3482eb');

  static Color gray2 = fromHex('#f0f4f7');

  static Color yellow = fromHex('#FFFEE9');

  static Color yellow2 = fromHex('#FFCF8A');

  static Color orange2 = fromHex('#0C2333');

  static Color whiteA700 = fromHex('#ffffff');

  static Color blueA70026 = fromHex('#26005cff');

  static Color pink40026 = fromHex('#26e84c88');

  static Color lightBlue50026 = fromHex('#2600aff0');

  static Color indigoA100 = fromHex('#8982ff');

  static Color blueA70066 = fromHex('#660062f5');

  static Color lightBlue80026 = fromHex('#260274b3');

  static Color deepPurple300 = fromHex('#8871e4');

  static Color gray50 = fromHex('#f9f9f9');

  static Color teal300 = fromHex('#5bcaa1');

  static Color black900 = fromHex('#000000');

  static Color indigo5001 = fromHex('#e4e2ff');

  static Color indigo5002 = fromHex('#e4e3ff');

  static Color greenA70026 = fromHex('#261dd75f');

  static Color gray500 = fromHex('#aaaaaa');

  static Color blueGray100 = fromHex('#cccccc');

  static Color blueGray400 = fromHex('#888888');

  static Color indigo50 = fromHex('#ebeafd');

  static Color black9000f = fromHex('#0f000000');

  static Color black9000c = fromHex('#0c000000');

  static Color gray200 = fromHex('#eeeeee');

  static Color teal80026 = fromHex('#26007348');

  static Color gray300 = fromHex('#dddddd');

  static Color amber60026 = fromHex('#26ffb700');

  static Color gray100 = fromHex('#f3f3f3');

  static Color blue7005b = fromHex('#5b2472d5');

  static Color deepPurple50 = fromHex('#edecff');

  static Color indigo100 = fromHex('#ccd6eb');

  static Color black90011 = fromHex('#11000000');

  static Color gray40026 = fromHex('#26bbbbbb');

  static Color redA70026 = fromHex('#26e50812');

  static Color blueA7004c = fromHex('#4c0062f5');

  static Color black90014 = fromHex('#14000000');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
