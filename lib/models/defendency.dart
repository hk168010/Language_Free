import 'package:dashboard/widgets/network.dart';
import 'package:get/get.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkCt>(NetworkCt(), permanent: true);
  }
}