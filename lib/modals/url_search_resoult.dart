enum USRType { row, section }

enum USRSourceType { db, suggest, history }

class UrlSearchResult {
  final String name;
  final String? subName;
  final String? value;
  final USRType type;
  final dynamic other;
  final USRSourceType source;

  const UrlSearchResult({
    required this.name,
    required this.subName,
    required this.value,
    required this.type,
    required this.other,
    required this.source,
  });

  static UrlSearchResult? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = UrlSearchResult(
      name: map['name'],
      subName: map['subName'],
      value: map['value'],
      type: map['type'],
      other: map['other'],
      source: map['source'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "subName": subName,
      "value": value,
      "type": type,
      "other": other,
      "source": source,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'UrlSearchResult{name: $name, subName: $subName, value: $value, type: $type,source:$source}';
  }

  Uri? faviconUri() {
    //Uri.parse("${aurl.origin}/favicon.ico");
    if (value == null || value!.startsWith('http') == false) {
      return null;
    }

    return Uri.parse("${Uri.parse(value!).origin}/favicon.ico");
  }
}
