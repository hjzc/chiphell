import 'package:chiphell/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import '../common/constants.dart';
import '../common/type_utils.dart';
import '../utils/utils.dart';

class WebMorePopMenu {
  static bool isShowedMenu = false;
  static MenuButtonItem setting() {
    return (label: Constants.kSeting, icon: Icon(Icons.settings), event: MenuButtonItemEvent.setting, onPressed: null);
  }

  static MenuButtonItem siteManager() {
    return (label: Constants.kSiteManager, icon: Icon(Icons.web_rounded), event: MenuButtonItemEvent.siteManger, onPressed: null);
  }

  static MenuButtonItem login() {
    return (label: Constants.kTipLogin, icon: Icon(Icons.login_outlined), event: MenuButtonItemEvent.login, onPressed: null);
  }

  static MenuButtonItem copy() {
    return (label: Constants.kCopyOptions, icon: Icon(Icons.copy), event: MenuButtonItemEvent.copy, onPressed: null);
  }

  static MenuButtonItem userHome() {
    return (label: Constants.kSiteUserHomeOpen, icon: Icon(Icons.person_2_outlined), event: MenuButtonItemEvent.userHome, onPressed: null);
  }

  static MenuButtonItem siteHome() {
    return (label: Constants.kSiteHomeOpen, icon: Icon(Icons.home), event: MenuButtonItemEvent.home, onPressed: null);
  }

  static MenuButtonItem areaHome() {
    return (label: Constants.kSiteForumOpen, icon: Icon(Icons.person_2_outlined), event: MenuButtonItemEvent.area, onPressed: null);
  }

  static MenuButtonItem blackList() {
    return (label: Constants.kMGFilterUser, icon: Icon(Icons.group), event: MenuButtonItemEvent.blackList, onPressed: null);
  }

  static MenuButtonItem history() {
    return (label: Constants.kMGRecord, icon: Icon(Icons.stars), event: MenuButtonItemEvent.history, onPressed: null);
  }

  static MenuButtonItem inBrowser() {
    return (
      label: Utils.isDesktopSystem ? Constants.kUrlNewWindowsOpen : Constants.kUrlInPageOpen,
      icon: Icon(Icons.open_in_browser),
      event: MenuButtonItemEvent.inBrowser,
      onPressed: null,
    );
  }

  static MenuButtonItem outBrowser() {
    return (
      label: Constants.kOutBrowserOpen,
      icon: const Icon(Icons.explore), //open_in_new_outlined
      event: MenuButtonItemEvent.outBrowser,
      onPressed: null,
    );
  }

  static MenuButtonItem userAgent(bool ismobile) {
    return (
      label: ismobile ? Constants.kDesktopUA : Constants.kMobileUA,
      icon: Icon(ismobile ? Icons.desktop_windows_outlined : Icons.mobile_friendly),
      event: MenuButtonItemEvent.userAgent,
      onPressed: null,
    );
  }

  static MenuButtonItem filterUser(bool isAdded) {
    return (
      label: isAdded ? Constants.kCancelFiltering : Constants.kAddToFilter,
      icon: Icon(isAdded ? Icons.remove : Icons.add_circle_outline),
      event: isAdded ? MenuButtonItemEvent.addFilter : MenuButtonItemEvent.delFilter,
      onPressed: null,
    );
  }

  static MenuButtonItem imageGallery() {
    return (
      label: Constants.kImageLook,
      icon: Icon(Icons.photo_album, color: Colors.red),
      event: MenuButtonItemEvent.imgGallery,
      onPressed: null,
    );
  }

  static MenuButtonItem more() {
    return (label: Constants.kMoreOptions, icon: const Icon(Icons.more_horiz_rounded), event: MenuButtonItemEvent.more, onPressed: null);
  }

  static void showWebPagePopMenu(
    BuildContext? ctx,
    bool isTabMode, {
    RelativeRect? position,
    void Function(MenuButtonItemEvent event)? selectedFn,
    bool? addFilter,
    bool haveUserHome = false,
    bool isGoLogin = false,
    bool haveCopy = false,
    bool haveimageGallery = false,
    bool haveArea = false,
    bool haveInBrowserOpen = false,
    bool haveOutBrowserOpen = false,
    bool isMobileUA = false,
    bool haveBlackList = true,
    bool haveSiteManager = false,
    void Function()? dismissFn,
  }) async {
    bool delayShow = false;
    if (ctx == null || ctx.mounted == false) {
      if (dismissFn != null) {
        dismissFn();
      }
      return;
    }
    if (isShowedMenu) {
      isShowedMenu = false;
      Navigator.of(ctx).maybePop();
      delayShow = true;
    }
    List<MenuButtonItem> r = [];
    r.add(more());
    if (addFilter != null) {
      r.add(filterUser(addFilter));
    }
    if (isGoLogin) {
      r.add(login());
    }
    if (haveCopy) {
      r.add(copy());
    }
    if (haveInBrowserOpen) {
      r.add(inBrowser());
    }
    if (haveOutBrowserOpen) {
      r.add(outBrowser());
    }
    if (haveArea) {
      r.add(areaHome());
    }
    if (haveUserHome) {
      r.add(userHome());
    }
    if (haveimageGallery) {
      r.add(imageGallery());
    }
    r.add(history());
    if (haveBlackList) {
      r.add(blackList());
    }
    if (haveSiteManager) {
      r.add(siteManager());
    }
    r.add(userAgent(isMobileUA));
    r.add(setting());

    if (ctx.mounted) {
      if (delayShow) {
        Future.delayed(Duration(milliseconds: 500), () {
          isShowedMenu = true;
          Uiutils.showMenuListDialog(
            ctx.mounted ? ctx : null,
            r,
            position: position,
            selectedFn: (MenuButtonItem item) {
              if (selectedFn != null) {
                selectedFn(item.event);
              }
            },
            dismissFn: () {
              if (isShowedMenu == true) {
                isShowedMenu = false;
              }
              if (dismissFn != null) {
                dismissFn();
              }
            },
          );
        });
      } else {
        isShowedMenu = true;
        await Uiutils.showMenuListDialog(
          ctx.mounted ? ctx : null,
          r,
          position: position,
          selectedFn: (MenuButtonItem item) {
            if (selectedFn != null) {
              selectedFn(item.event);
            }
          },
          dismissFn: () {
            if (isShowedMenu == true) {
              isShowedMenu = false;
            }
            if (dismissFn != null) {
              dismissFn();
            }
          },
        );
      }
    }
  }
}
