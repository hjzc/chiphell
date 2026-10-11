import 'package:upgrader/upgrader.dart';

class UpgradeContent extends UpgraderMessages {
  @override
  String? message(UpgraderMessage messageKey) {
    // if (languageCode == 'es') {
    //   switch (messageKey) {
    //     case UpgraderMessage.body:
    //       return 'es A new version of {{appName}} is available!';
    //     case UpgraderMessage.buttonTitleIgnore:
    //       return 'es Ignore';
    //     case UpgraderMessage.buttonTitleLater:
    //       return 'es Later';
    //     case UpgraderMessage.buttonTitleUpdate:
    //       return 'es Update Now';
    //     case UpgraderMessage.prompt:
    //       return 'es Want to update?';
    //     case UpgraderMessage.releaseNotes:
    //       return 'es Release Notes';
    //     case UpgraderMessage.title:
    //       return 'es Update App?';
    //   }
    // } else if (languageCode == 'zh') {
    //   switch (messageKey) {
    //     case UpgraderMessage.body:
    //       return 'es A new version of {{appName}} is available!';
    //     case UpgraderMessage.buttonTitleIgnore:
    //       return 'es Ignore';
    //     case UpgraderMessage.buttonTitleLater:
    //       return 'es Later';
    //     case UpgraderMessage.buttonTitleUpdate:
    //       return 'es Update Now';
    //     case UpgraderMessage.prompt:
    //       return 'es Want to update?';
    //     case UpgraderMessage.releaseNotes:
    //       return 'es Release Notes';
    //     case UpgraderMessage.title:
    //       return 'es Update App?';
    //   }
    // }
    // Messages that are not provided above can still use the default values.
    return super.message(messageKey);
  }
}
