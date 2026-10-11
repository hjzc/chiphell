import 'dart:io';

//import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

// class Utils {
//   static void toast(String msg) {
//     Fluttertoast.showToast(
//       msg: msg,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.CENTER,
//       timeInSecForIosWeb: 1,
//       textColor: Colors.white,
//       fontSize: 16.0,
//       backgroundColor: Colors.black,
//     );
//   }
// }

class PermissionUtil {
  static List<Permission> androidPermissions = <Permission>[Permission.storage];

  static List<Permission> iosPermissions = <Permission>[Permission.storage];

  static Future<Map<Permission, PermissionStatus>> requestAll() async {
    if (Platform.isIOS) {
      return await iosPermissions.request();
    }
    return await androidPermissions.request();
  }

  static Future<Map<Permission, PermissionStatus>> request(
    Permission permission,
  ) async {
    final List<Permission> permissions = <Permission>[permission];
    return await permissions.request();
  }

  static bool isDenied(Map<Permission, PermissionStatus> result) {
    var isDenied = false;
    result.forEach((key, value) {
      if (value == PermissionStatus.denied) {
        isDenied = true;
        return;
      }
    });
    return isDenied;
  }

  static Future<bool> checkGranted(Permission permission) async {
    PermissionStatus storageStatus = await permission.status;
    if (storageStatus == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}
