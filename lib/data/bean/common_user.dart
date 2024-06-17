/// grant_type : "password"
/// username : "asdasd"
/// password : "asdas"
/// domain : "sdsdvsvs"
/// client_id : "1_3bcbxd9e24g0gk4swg0kwgcwg4o8k8g4g888kwc44gcc0gwwk4"
/// client_secret : "4ok2x70rlfokc8g0wws8c8kwcokw80k44sg48goc0ok4w0so0k"

class CommonUser {
  String? grantType;
  String? username;
  String? password;
  String? domain;
  String? clientId;
  String? clientSecret;

  CommonUser({
      this.grantType, 
      this.username, 
      this.password, 
      this.domain, 
      this.clientId, 
      this.clientSecret});

  CommonUser.fromJson(Map<String, String> json) {
    grantType = json["grant_type"];
    username = json["username"];
    password = json["password"];
    domain = json["domain"];
    clientId = json["client_id"];
    clientSecret = json["client_secret"];
  }

  Map<String, String?> toJson() {
    var map = <String, String?>{};
    map["grant_type"] = grantType;
    map["username"] = username;
    map["password"] = password;
    map["domain"] = domain;
    map["client_id"] = clientId;
    map["client_secret"] = clientSecret;
    return map;
  }

}