import 'dart:ui';

import 'package:flutter/material.dart';

class UtilLocal {
  /// return zh_Hans_CN
  static Locale findLocale({BuildContext? context}) {
    Locale? locale;
    if (context != null) {
      locale = Localizations.maybeLocaleOf(context);
    }
    locale ??= PlatformDispatcher.instance.locale;
    // if (state.debugLogging) {
    // current locale: zh_Hans_CN
    //print('upgrader: current locale: $locale');
    // }
    return locale;
  }

  /// Determine the current country code, either from the context, or
  /// from the system-reported default locale of the device. The default
  /// is `US`.
  /// final country = findCountryCode(locale: findLocale(ctx));
  /// return "CN"
  static String? findCountryCode({required Locale locale}) {
    final code = locale.countryCode ?? 'US';
    return code;
  }

  /// Determine the current language code, either from the context, or
  /// from the system-reported default locale of the device. The default
  /// is `en`.
  ///  final language =  findLanguageCode(locale: locale);
  ///  return "zh"
  static String? findLanguageCode({required Locale locale}) {
    final code = locale.languageCode;
    return code;
  }
}
