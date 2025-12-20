// lib/data/models/bank_details.dart
class BankDetails {
  // Prefer tokenized data from your PSP; these fields are only for demo/testing.
  final String? cardHolderName;
  final String? cardNumber;     // store only masked or last4 in prod
  final String? expiry;         // MM/YY
  final String? cvv;            // avoid storing in prod
  final String? bankAccount;    // avoid storing in prod
  final String? routingNumber;  // avoid storing in prod

  BankDetails({
    this.cardHolderName,
    this.cardNumber,
    this.expiry,
    this.cvv,
    this.bankAccount,
    this.routingNumber,
  });

  Map<String, dynamic> toJson() => {
    'cardHolderName': cardHolderName,
    'cardNumber': cardNumber,
    'expiry': expiry,
    'cvv': cvv,
    'bankAccount': bankAccount,
    'routingNumber': routingNumber,
  };

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
    cardHolderName: json['cardHolderName'],
    cardNumber: json['cardNumber'],
    expiry: json['expiry'],
    cvv: json['cvv'],
    bankAccount: json['bankAccount'],
    routingNumber: json['routingNumber'],
  );
}
