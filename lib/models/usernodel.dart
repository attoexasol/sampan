class UserModel {
  String? apiToken;
  String? customerName;
  String? customerTel;
  String? customerEmail;
  String? customerAddress;
  String? customerNotes;
  String? customerPassword;

  UserModel(
      {this.apiToken,
        this.customerName,
        this.customerTel,
        this.customerEmail,
        this.customerAddress,
        this.customerNotes,
        this.customerPassword});

  UserModel.fromJson(Map<String, dynamic> json) {
    apiToken = json['api_token'];
    customerName = json['customerName'];
    customerTel = json['customerTel'];
    customerEmail = json['customerEmail'];
    customerAddress = json['customerAddress'];
    customerNotes = json['customerNotes'];
    customerPassword = json['customerPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['api_token'] = apiToken;
    data['customerName'] = customerName;
    data['customerTel'] = customerTel;
    data['customerEmail'] = customerEmail;
    data['customerAddress'] = customerAddress;
    data['customerNotes'] = customerNotes;
    data['customerPassword'] = customerPassword;
    return data;
  }
}
