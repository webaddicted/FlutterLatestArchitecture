class LoginUserBean {
  String? image;
  String? password;
  String? dob;
  String? name;
  String? emailId;
  String? mobileNo;

  LoginUserBean(
      this.name,
      this.emailId,
      this.mobileNo,
      this.dob,
      this.password,
      this.image);

  LoginUserBean.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    password = json['password'];
    dob = json['dob'];
    name = json['name'];
    emailId = json['emailId'];
    mobileNo = json['mobileNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = this.image;
    data['password'] = this.password;
    data['dob'] = this.dob;
    data['name'] = this.name;
    data['emailId'] = this.emailId;
    data['mobileNo'] = this.mobileNo;
    return data;
  }
}
