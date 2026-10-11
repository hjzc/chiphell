///提醒消息
class PromptMsg {
  String name; //用户称昵
  String uid; //用户id
  int count; //提醒消息条数 提醒(1)
  int stamp;
  PromptMsg({required this.name, required this.uid, required this.count, required this.stamp});

  static PromptMsg fromMap(Map<String, dynamic> map) {
    final instance = PromptMsg(name: map['name'], uid: map['uid'], count: map['count'], stamp: map['stamp']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"name": name, "uid": uid, "count": count, 'stamp': stamp};
  }

  //手动反序列化
  factory PromptMsg.fromJson(Map<String, dynamic> json) => PromptMsg.fromMap(json);

  ///Converts instance to a map.  手动序列化
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PrompMsg{name: $name, uid: $uid, count: $count,stamp:$stamp}';
  }

  bool updateMsg(PromptMsg msg) {
    int r = 0;
    if (msg.name != name) {
      name = msg.name;
      r++;
    }
    if (msg.uid != uid) {
      uid = msg.uid;
      r++;
    }
    if (msg.count != count) {
      count = msg.count;
      r++;
      if (msg.stamp != stamp) {
        stamp = msg.stamp;
        r++;
      }
    }
    return r > 0;
  }

  void clear() {
    count = 0;
    stamp = 0;
    uid = '';
    name = '';
  }
}

class WebUser {
  String? name;
  String? url;
  String? iconUrl;
  String? cookieAuth;
  String? uid;
  PromptMsg? msg;

  WebUser({this.name, this.url, this.iconUrl, this.cookieAuth, this.uid, this.msg});

  @override
  bool operator ==(Object other) {
    bool r = false;
    if (other is WebUser) {
      r =
          (cookieAuth != null && cookieAuth!.isNotEmpty && other.cookieAuth == cookieAuth) ||
          (uid != null && uid!.isNotEmpty && other.uid == uid) ||
          (name != null && name!.isNotEmpty && other.name == name);
    } else {
      r = super == other;
    }
    return r;
  }

  @override
  int get hashCode {
    // 使用关键字段的组合生成哈希值
    var r = (cookieAuth != null && cookieAuth!.isNotEmpty) ? cookieAuth : null;
    r ??= (uid != null && uid!.isNotEmpty) ? uid : null;
    r ??= (name != null && name!.isNotEmpty) ? name : null;
    return Object.hash(cookieAuth, uid, [(name != null && name!.isNotEmpty) ? name : '']);
  }

  static WebUser fromMap(Map<String, dynamic> map) {
    final instance = WebUser(
      name: map['name'],
      url: map['url'],
      iconUrl: map['iconUrl'],
      cookieAuth: map['cookieAuth'],
      uid: map['uid'],
      msg: map['msg'] is PromptMsg ? map['msg'] : (PromptMsg.fromJson(map['msg'] as Map<String, dynamic>)),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"name": name, "url": url, "iconUrl": iconUrl, "cookieAuth": cookieAuth, "uid": uid, "msg": msg};
  }

  factory WebUser.fromJson(Map<String, dynamic> json) => WebUser.fromMap(json);

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return {"name": name, "url": url, "iconUrl": iconUrl, "cookieAuth": cookieAuth, "uid": uid, "msg": msg?.toJson()};
  }

  @override
  String toString() {
    return 'WebUser{name: $name, url: $url, iconUrl: $iconUrl, cookieAuth: $cookieAuth,"uid":$uid,msg:$msg}';
  }

  bool isLogin() {
    return (cookieAuth != null) && (cookieAuth!.isNotEmpty);
  }

  bool updateCookieAuth(String? auth) {
    bool r = false;
    if ((cookieAuth != auth)) {
      cookieAuth = auth;
      name = null;
      url = null;
      iconUrl = null;
      uid = null;
      msg?.uid = '';
      msg?.name = '';
      msg?.count = 0;
      r = true;
    }
    return r;
  }

  bool updateUid(String? val) {
    bool r = false;
    if (uid != val) {
      uid = val;
      msg?.uid = uid ?? '';
      r = true;
    }
    return r;
  }

  bool updateName(String? val) {
    bool r = false;
    if (name != val) {
      name = val;
      msg?.name = name ?? '';
      r = true;
    }
    return r;
  }

  bool updateUrl(String? val) {
    bool r = false;
    if (val != url) {
      url = val;
      r = true;
    }
    return r;
  }

  bool updateIconUrl(String? val) {
    bool r = false;
    if (val != iconUrl) {
      iconUrl = val;
      r = true;
    }
    return r;
  }

  bool updatePromptMessage(PromptMsg val) {
    bool r = false;
    if (msg == null) {
      msg = val;
      r = true;
    } else if (msg?.updateMsg(val) == true) {
      r = true;
    }
    return r;
  }

  bool isValidName() {
    return (name != null) && name!.isNotEmpty;
  }

  bool isValidUserSpaceUrl() {
    return (url != null) && url!.isNotEmpty;
  }
}
