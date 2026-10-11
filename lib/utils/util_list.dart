import 'dart:typed_data';

class UtilList {
  static List<String>? dyToListStrings(dynamic rs) {
    List<String>? r;
    if (rs != null && (rs is List)) {
      if (rs is List<String>) {
        r = rs;
      } else {
        r = [];
        for (int i = 0; i < rs.length; i++) {
          var item = rs[i];
          if (item is String) {
            r.add(item);
          }
        }
      }
    }
    return r;
  }

  static List<int> dyListToListInt(List<dynamic> dynamicList) {
    List<int> r = dynamicList.map((e) {
      if (e is num) {
        return e.toInt(); // 处理数字类型
      }
      if (e is String) {
        return int.tryParse(e) ?? 0; // 处理字符串，失败则默认0
      }
      return 0; // 其他类型默认值
    }).toList();
    return r;
  }

  static Uint8List dyListToUint8List(List<dynamic> dynamicList) {
    return Uint8List.fromList(dyListToListInt(dynamicList));
  }
}
