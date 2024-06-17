/// status_code : "1"
/// message : "Customer login OTP Send"
/// customer_id : 4
/// customer_type : "already"
/// otp : 802549

class LoginRespo {
  String? statusCode;
  String? message;
  dynamic customerId;
  String? customerType;
  dynamic otp;

  LoginRespo({
      this.statusCode, 
      this.message, 
      this.customerId, 
      this.customerType, 
      this.otp});

  LoginRespo.fromJson(Map<String, dynamic> json) {
    statusCode = json["status_code"];
    message = json["message"];
    customerId = json["customer_id"];
    customerType = json["customer_type"];
    otp = json["otp"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["status_code"] = statusCode;
    map["message"] = message;
    map["customer_id"] = customerId;
    map["customer_type"] = customerType;
    map["otp"] = otp;
    return map;
  }

}