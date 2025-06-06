/// device_id : "74533257c68e1ba1"
/// locale : "en"
library;

class LoginReq {
  String? email;
  String? mobile;
  String? deviceId;
  String? fcmToken;
  String? referCode;
  String? latitude;
  String? longitude;
  LoginReq({this.email,this.mobile, this.deviceId, this.fcmToken, this.referCode,
    this.latitude,
    this.longitude});

  LoginReq.fromJson(Map<String, String> json) {
    email = json["email"];
    mobile = json["mobile"];
    deviceId = json["device_id"];
    fcmToken = json["fcmToken"];
    referCode = json["refer_code"];
    latitude = json["latitude"];
    longitude = json["longitude"];
  }

  Map<String, String> toJson() {
    var map = <String, String>{};
    map["email"] = email!;
    map["mobile"] = mobile!;
    map["device_id"] = deviceId!;
    map["fcmToken"] = fcmToken!;
    map["refer_code"] = referCode!;
    map["latitude"] = latitude!;
    map["longitude"] = longitude!;
    return map;
  }
}
