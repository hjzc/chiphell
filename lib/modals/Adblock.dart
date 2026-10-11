import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String adbCss = ".banner, .banners, .ads, .ad, .advert, .widget-ads, .ad-unit, .a_pt, .a_pb";
const adbUrlFilters = [
  ".*.doubleclick.net/.*",
  ".*.ads.pubmatic.com/.*",
  ".*.googlesyndication.com/.*",
  ".*.google-analytics.com/.*",
  ".*.adservice.google.*/.*",
  ".*.adbrite.com/.*",
  ".*.exponential.com/.*",
  ".*.quantserve.com/.*",
  ".*.scorecardresearch.com/.*",
  ".*.zedo.com/.*",
  ".*.adsafeprotected.com/.*",
  ".*.teads.tv/.*",
  ".*.outbrain.com/.*",
];

class AdBlock {
  static final AdBlock _instance = AdBlock._internal();

  // 私有命名构造函数
  AdBlock._internal();

  // 工厂构造函数，总是返回唯一的实例
  factory AdBlock() {
    return _instance;
  }

  final List<ContentBlocker> _contentBlockers = [];
  //无图模式 ios  "[{trigger:{url-filter:.*,resource-type:[image]},action:{type:block}}]";
  final ContentBlocker imageBlock = ContentBlocker(
    trigger: ContentBlockerTrigger(urlFilter: '.*', resourceType: [ContentBlockerTriggerResourceType.IMAGE]),
    action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
  );

  void make() {
    //内容拦截器
    // for each Ad URL filter, add a Content Blocker to block its loading.
    for (final adUrlFilter in adbUrlFilters) {
      _contentBlockers.add(
        ContentBlocker(
          trigger: ContentBlockerTrigger(urlFilter: adUrlFilter),
          action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
        ),
      );
    }
    // apply the "display: none" style to some HTML elements
    _contentBlockers.add(
      ContentBlocker(
        trigger: ContentBlockerTrigger(urlFilter: ".*"),
        action: ContentBlockerAction(type: ContentBlockerActionType.CSS_DISPLAY_NONE, selector: adbCss),
      ),
    );
  }

  List<ContentBlocker> get contentBlockers => _contentBlockers;
}
