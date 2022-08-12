/// PayoutForm is a data class which stores data fields of Feedback.
class PayoutForm {
  String date;
  String username;
  String email;
  String paypalLink;
  String amountToTransfer;
  String amountGeneratedForGD;

  PayoutForm(this.date, this.username, this.email, this.paypalLink,
      this.amountToTransfer, this.amountGeneratedForGD);

  factory PayoutForm.fromJson(dynamic json) {
    return PayoutForm(
      "${json['date']}",
      "${json['username']}",
      "${json['email']}",
      "${json['paypalLink']}",
      "${json['amountToTransfer']}",
      "${json['amountGeneratedForGD']}",
    );
  }

  // Method to make GET parameters.
  Map toJson() => {
        'date': date,
        'username': username,
        'email': email,
        'paypalLink': paypalLink,
        'amountToTransfer': amountToTransfer,
        'amountGeneratedForGD': amountGeneratedForGD,
      };
}
