import 'dart:io';
import 'package:chiphell/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';
import '../utils/zs_log.dart';
import 'upgrade_content.dart';
import 'upgrade_device.dart';

typedef UpgradeCallback = void Function(BuildContext ctx, int event);
typedef UpgradeChildCallback = Widget? Function(BuildContext ctx);

class UpgradeView extends StatefulWidget {
  static late Version osVersion;

  final String macosAppcastURL;
  final String windowsAppcastURL;
  final String androidAppcastURL;
  final GlobalKey<NavigatorState> navigatorKey;
  final UpgradeCallback callback;
  final UpgradeChildCallback childWidgetCallBack;

  const UpgradeView({
    super.key,
    required this.macosAppcastURL,
    required this.windowsAppcastURL,
    required this.androidAppcastURL,
    required this.navigatorKey,
    required this.callback,
    required this.childWidgetCallBack,
  });

  static Future<void> init() async {
    // if (kDebugMode) {
    //   await Upgrader.clearSavedSettings();
    // }
    try {
      osVersion = await UpgraderDevice.getCurrentOSVersion();
    } catch (e) {
      ZsLog.e('UpgradeView init failed!', error: e);
    }
  }

  //用户在开关 更新后调用
  static Future<void> resetUpdateConfig() async {
    await Upgrader.clearSavedSettings();
  }

  @override
  UpgradeViewState createState() => UpgradeViewState();
}

class UpgradeViewState extends State<UpgradeView> {
  late Upgrader grader;
  http.Client getUpgradeClient() {
    var httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) {
      return true;
    };
    var ioClient = IOClient(httpClient);
    return ioClient;
  }

  @override
  void initState() {
    super.initState();
    grader = Upgrader(
      client: getUpgradeClient(),
      messages: UpgradeContent(),
      storeController: UpgraderStoreController(
        onWindows: () => UpgraderAppcastStore(appcastURL: widget.windowsAppcastURL, osVersion: UpgradeView.osVersion.toString()),
        onMacOS: () => UpgraderAppcastStore(appcastURL: widget.macosAppcastURL, osVersion: UpgradeView.osVersion.toString()),
        onAndroid: () => UpgraderAppcastStore(appcastURL: widget.macosAppcastURL, osVersion: UpgradeView.osVersion.toString()),
        //oniOS: () => UpgraderAppcastStore(appcastURL: appcastURL, osVersion: osVersion.toString()),
      ),
      // debugLogging: kDebugMode,
      // debugDisplayAlways: kDebugMode,
      durationUntilAlertAgain: const Duration(days: 7),
      // debugDisplayAlways: false,
      willDisplayUpgrade: ({required display, installedVersion, versionInfo}) {
        if (display) {
          widget.callback(context, 0);
          //gotoWebMainPage(context, false);
        } else {
          widget.callback(context, -1);
        }
      },
    );
    grader.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: (Utils.isIOS() || Utils.isMacOS()) ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material,
      showIgnore: true,
      showLater: true,
      upgrader: grader,
      onUpdate: () {
        widget.callback(context, 1);
        //gotoWebMainPage(context, true);
        return true;
      },
      onIgnore: () {
        widget.callback(context, 2);
        // gotoWebMainPage(context, true);
        return true;
      },
      onLater: () {
        widget.callback(context, 3);
        // gotoWebMainPage(context, true);
        return true;
      },
      shouldPopScope: () {
        return true;
      },
      navigatorKey: widget.navigatorKey,
      child: widget.childWidgetCallBack(context) ?? Scaffold(body: const Center(child: Text('Checking...'))),
    );
  }
}
