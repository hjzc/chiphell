
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class WebImageUrlDownloader {
  Map<String,Stream<FileResponse>> urlDownloadMap ={};


  bool hasItem(String url){
    return urlDownloadMap.containsKey(url);
  }

  void addItem(String url,Stream<FileResponse> imageSteam ){
    urlDownloadMap.addAll({url:imageSteam});
  }

  void remove(String url){
    urlDownloadMap.remove(url);
  }



}