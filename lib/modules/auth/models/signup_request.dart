/// Signup form data. customerName is built from firstName + lastName for the API.
class SignupRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String? referralCode;

  const SignupRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    this.referralCode,
  });

  String get customerName => '$firstName $lastName'.trim();
  String get fullAddress => '$address, $city, $state $zip'.trim();

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'address': address,
        'city': city,
        'state': state,
        'zip': zip,
        if (referralCode != null && referralCode!.isNotEmpty) 'referralCode': referralCode,
      };
}
