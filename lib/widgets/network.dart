import 'package:connectivity/connectivity.dart';
import 'package:dashboard/screens/check_network_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkCt extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    print('11111111111111111$connectivityResult');
    if (connectivityResult == ConnectivityResult.none) {
      _showNoNetworkDialog(); 
    } else {
      print('1111111111111111111');
      Get.until((route) => Get.currentRoute != '/CheckNetWorkScreen'); 
    }
  }
  void _showNoNetworkDialog() {
    Get.to(CheckNetWorkScreen()); 
  }
}
