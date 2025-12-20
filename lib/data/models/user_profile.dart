class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String? name;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    this.name,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'address': address,
    'name': name,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    fullName: json['fullName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    name: json['name'],
  );
}
