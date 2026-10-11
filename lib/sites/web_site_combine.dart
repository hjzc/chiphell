import 'package:chiphell/sites/main_site.dart';

class WebSiteCombine {
  MainSite site;
  List<MainSite> sites = [];

  MainSite mainSite() {
    return sites.first;
  }

  WebSiteCombine({required this.site});
}
