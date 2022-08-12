import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  var logger = Logger(printer: PrettyPrinter());

  Future<dynamic> charge(Map<String, dynamic> data) async {
    Map<String, dynamic> charge = {
      "source": data["token"],
      "amount": data["amount"],
      "currency": data["currency"],
    };
    final response =
        await http.post(Uri.parse('/stripe/payment/charge'), body: charge);

    logger.wtf(response);
    // if (response.body.contains("results")) {
    //   return ChargeResult.fromMap(response["results"]);
    // } else {
    //   String errorMessage = response["errors"][0]["description"];
    //   return errorMessage;
    // }
  }
}
