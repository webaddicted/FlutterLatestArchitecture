
class UpdateProfileReq {
  String? statusCode;
  String? message;
  String? customerId = '';
  String? name = '';
  String? email = '';
  String? dob = '';
  String? mobile = '';
  String? address = '';
  String? customerImage = '';
  String? cityId = '';
  String? centerId = '';
  String? referrelCode = '';
  String? officeOpenTime;
  String? officeCloseTime;
  String? whatsappNo;
  String? aadharVerified;
  UpdateProfileReq({
    this.statusCode,
    this.message,
    this.customerId,
    this.name,
    this.email,
    this.dob,
    this.mobile,
    this.address,
    this.customerImage,
    this.cityId,
    this.centerId,
    this.referrelCode,
    this.officeOpenTime,
    this.officeCloseTime,
    this.whatsappNo,
    this.aadharVerified
  });

  UpdateProfileReq.fromJson(Map<String, dynamic> json) {
    statusCode = json["status_code"];
    message = json["message"];
    customerId = json["customer_id"];
    name = json["name"];
    email = json["email"];
    dob = json["dob"];
    mobile = json["mobile"];
    address = json["address"];
    customerImage = json["customer_image"];
    cityId = json["city_id"];
    centerId = json["center_id"];
    referrelCode = json["referrelCode"];
    officeOpenTime = json["office_open_time"];
    officeCloseTime = json["office_close_time"];
    whatsappNo = json["whatsapp_no"];
    aadharVerified = json["aadhar_verified"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["status_code"] = statusCode;
    map["message"] = message;
    map["customer_id"] = customerId;
    map["name"] = name;
    map["email"] = email;
    map["dob"] = dob;
    map["mobile"] = mobile;
    map["address"] = address;
    map["customer_image"] = customerImage;
    map["city_id"] = cityId;
    map["center_id"] = centerId;
    map["referrelCode"] = referrelCode;
    map["office_open_time"] = officeOpenTime;
    map["office_close_time"] = officeCloseTime;
    map["whatsapp_no"] = whatsappNo;
    map["aadhar_verified"] = aadharVerified;
    return map;
  }
}
