import '../modals/AppState.dart';

class WebViewJsClient {
  Future<void> handleWebSiteInfo(AppState? appState, Map val) async {
    if (val.containsKey('siteinfo')) {
      var r0 = val['siteinfo'];
      if (r0 is Map) {
        if (r0.containsKey('type') && r0.containsKey('info')) {
          var r1 = r0['type'];
          if (r1 is int) {
            //r1 == 1 discuz
            var r2 = r0['info'];
            if (r2 is Map<String, dynamic>) {
              //DiscuzInfo? r = DiscuzInfo.fromMap(r2);
            }
          }
        }
      }
    }
  }
}
