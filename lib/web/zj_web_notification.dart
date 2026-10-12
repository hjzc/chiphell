import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ZjWebNotificationPermission { GRANTED, DENIED, DEFAULT }

class ZjWebNotificationAction {
  final String? action;
  final String? title;
  final String? icon;

  ZjWebNotificationAction(this.action, this.title, this.icon);

  ZjWebNotificationAction.fromJson(Map<String, dynamic> json)
    : action = json['action'],
      title = json['title'].toString(),
      icon = json['icon'];

  @override
  String toString() {
    return 'WebNotificationAction{action: $action, title: $title, icon: $icon}';
  }
}

class ZjWebNotification {
  final int id;
  final List<ZjWebNotificationAction>? actions;
  final String? badge;
  final String? body;
  final dynamic data;
  final String? dir;
  final String? icon;
  final String? image;
  final String? lang;
  final bool? renotify;
  final bool? requireInteraction;
  final bool? silent;
  final String? tag;
  final int timestamp;
  final String title;
  final List<int>? vibrate;

  final InAppWebViewController _webViewController;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? snackBarController;

  ZjWebNotification(
    this.id,
    this.actions,
    this.badge,
    this.body,
    this.data,
    this.dir,
    this.icon,
    this.image,
    this.lang,
    this.renotify,
    this.requireInteraction,
    this.silent,
    this.tag,
    this.timestamp,
    this.title,
    this.vibrate,
    this._webViewController,
    this.snackBarController,
  );

  Future<dynamic> close() async {
    await _webViewController.evaluateJavascript(
      source:
          """
      if (window._flutter_inappweview_notifications[$id] != null) {
        window._flutter_inappweview_notifications[$id].close();
      }
    """,
    );
  }

  Future<dynamic> dispatchClick() async {
    await _webViewController.evaluateJavascript(
      source:
          """
      if (window._flutter_inappweview_notifications[$id] != null) {
        var notification = window._flutter_inappweview_notifications[$id];
        var event = new Event('click');
        notification.dispatchEvent(event);
        if (notification.onclick != null) {
          notification.onclick(event);
        }
      }
    """,
    );
  }

  ZjWebNotification.fromJson(Map<String, dynamic> json, this._webViewController)
    : id = json['id'],
      actions = json['actions'] != null
          ? (json['actions'].cast<Map<String, dynamic>>() as List<Map<String, dynamic>>)
                .map((e) => ZjWebNotificationAction.fromJson(e))
                .toList()
          : null,
      badge = json['badge'],
      body = json['body'],
      data = json['data'],
      dir = json['dir'],
      icon = json['icon'],
      image = json['image'],
      lang = json['lang'],
      renotify = json['renotify'],
      requireInteraction = json['requireInteraction'],
      silent = json['silent'],
      tag = json['tag'],
      timestamp = json['timestamp'],
      title = json['title'].toString(),
      vibrate = json['vibrate']?.cast<int>();

  @override
  String toString() {
    return 'WebNotification{id: $id, actions: $actions, badge: $badge, body: $body, data: $data, dir: $dir, icon: $icon, image: $image, lang: $lang, renotify: $renotify, requireInteraction: $requireInteraction, silent: $silent, tag: $tag, timestamp: $timestamp, title: $title, vibrate: $vibrate}';
  }
}

class ZjWebNotificationController {
  final Map<int, ZjWebNotification> notifications = {};
  final InAppWebViewController _webViewController;

  ZjWebNotificationController(this._webViewController);

  Future<void> requestPermission() async {
    await _webViewController.evaluateJavascript(
      source: """
      Notification.requestPermission();
    """,
    );
  }

  Future<ZjWebNotificationPermission> getPermission() async {
    final String? permission = await _webViewController.evaluateJavascript(
      source: """
      Notification.permission;
    """,
    );
    switch (permission) {
      case 'granted':
        return ZjWebNotificationPermission.GRANTED;
      case 'denied':
        return ZjWebNotificationPermission.DENIED;
    }
    return ZjWebNotificationPermission.DEFAULT;
  }

  Future<void> resetPermission() async {
    await _webViewController.evaluateJavascript(
      source: """
      Notification._permission = 'default';
    """,
    );
  }
}

abstract class ZjWebNotificationPermissionDb {
  static final Map<String, String> _db = {};
  static const key = 'WebNotificationPermissionDb';

  static Future<void> loadSavedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);
    if (json != null) {
      _db.addAll(jsonDecode(json).cast<String, String>());
    }
  }

  static int get length {
    return _db.length;
  }

  static int get deniedCounts {
    //var count = _db.values.map((e) => e == 'denied' ? e : null).where((e) => e != null).toList();
    final count = _db.values.where((v) => v == 'denied').length;
    return count;
  }

  static Future<bool> resetDenieds() async {
    int olens = _db.length;
    _db.removeWhere((key, value) => value == 'denied');
    if (olens != _db.length) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(_db));
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> clear() async {
    _db.clear();
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  static Future<bool> savePermission(String host, ZjWebNotificationPermission permission) async {
    _db[host] = permission.name.toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, jsonEncode(_db));
  }

  static Future<void> clearHost(String host) async {
    if (_db.containsKey(host)) {
      _db.remove(host);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(_db));
    }
  }

  static ZjWebNotificationPermission? getPermission(String host) {
    final permission = _db[host];
    if (permission != null) {
      switch (permission) {
        case 'granted':
          return ZjWebNotificationPermission.GRANTED;
        case 'denied':
          return ZjWebNotificationPermission.DENIED;
      }
    }
    return null;
  }

  static Map<String, String> getPermissions() {
    return Map.from(_db);
  }
}
