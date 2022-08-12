import 'dart:convert' as convert;
import 'package:diamon_rose_app/services/GoogleSheetsAPI/form.dart';
import 'package:http/http.dart' as http;

/// PayoutController is a class which does work of saving PayoutForm in Google Sheets using
/// HTTP GET request on Google App Script Web URL and parses response and sends result callback.
class PayoutController {
  // Google App Script Web URL.
  static Uri URL = Uri.parse(
      "https://script.google.com/macros/s/AKfycbyYWr_LoredlKVqe-z-xryssXjXx01X6V-HFR_-xix7ANBPldk4OlMpXunVYlgoNe3J/exec");

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  /// Async function which saves feedback, parses [PayoutForm] parameters
  /// and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void submitForm(PayoutForm PayoutForm, void Function(String) callback) async {
    try {
      await http.post(URL, body: PayoutForm.toJson()).then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(Uri.parse(url!)).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
