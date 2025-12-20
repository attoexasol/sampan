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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['api_token'] = this.apiToken;
    data['customerName'] = this.customerName;
    data['customerTel'] = this.customerTel;
    data['customerEmail'] = this.customerEmail;
    data['customerAddress'] = this.customerAddress;
    data['customerNotes'] = this.customerNotes;
    data['customerPassword'] = this.customerPassword;
    return data;
  }
}
