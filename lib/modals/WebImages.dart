import 'dart:convert';

class WebImages {
  final String url;
  final List<String> images;
  final int index = 0;
  WebImages({required this.url, required this.images});

  // final imageMap = jsonDecode(jsonString) as Map<String, dynamic>;
  // final webImages = WebImages.fromJson(imageMap);
  //String json = jsonEncode(webImages);
  // WebImages.fromJson(Map<String, dynamic> json)
  //   : url = json['url'] as String,
  //     images = json['images'] as List<String>;
  factory WebImages.fromJson(Map<String, dynamic> json) {
    return WebImages(
      url: json['url'] as String,
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'url': url, 'images': images};
  }

  String toJsonString() {
    return jsonEncode(this);
  }

  int get count => images.length;

  String? imageAtIndex(int index) {
    String? r;
    if (index >= 0 && index < images.length) {
      r = images[index];
    }
    return r;
  }
}
