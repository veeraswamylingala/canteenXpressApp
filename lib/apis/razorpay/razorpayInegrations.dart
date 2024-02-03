import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayIntegration {
  final Razorpay _razorpay = Razorpay(); //Instance of razor pay
  final razorPayKey = dotenv.get("RAZOR_KEY");
  final razorPaySecret = dotenv.get("RAZOR_SECRET");

  intiateRazorPay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log(response.toString(), name: "_handlePaymentSuccess");
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log(response.toString(), name: "_handlePaymentError");
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log(response.toString(), name: "_handleExternalWallet");

    // Do something when an external wallet is selected
  }

  openSession({required num amount}) {
    createOrder(amount: amount).then((orderId) {
      print(orderId);
      if (orderId.toString().isNotEmpty) {
        var options = {
          'key': razorPayKey, //Razor pay API Key
          'amount': amount, //in the smallest currency sub-unit.
          'name': 'CanteeXpress',
          'order_id': orderId, // Generate order_id using Orders API
          'description':
              'Description for order', //Order Description to be shown in razor pay page
          'timeout': 60, // in seconds
          'prefill': {
            'contact': '8328395332',
            'email': 'veer@gmail.com'
          } //contact number and email id of user
        };
        _razorpay.open(options);
      } else {}
    });
  }

  createOrder({
    required num amount,
  }) async {
    final myData = await razorPayApi(amount, "rcp_id_1");
    if (myData["status"] == "success") {
      print(myData);
      return myData["body"]["id"];
    } else {
      return "";
    }
  }

  razorPayApi(num amount, String recieptId) async {
    var auth =
        'Basic ${base64Encode(utf8.encode('$razorPayKey:$razorPaySecret'))}';
    var headers = {'content-type': 'application/json', 'Authorization': auth};
    var request =
        http.Request('POST', Uri.parse('https://api.razorpay.com/v1/orders'));
    request.body = json.encode({
      "amount": amount * 100, // Amount in smallest unit like in paise for INR
      "currency": "INR", //Currency
      "receipt": recieptId //Reciept Id
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      return {
        "status": "success",
        "body": jsonDecode(await response.stream.bytesToString())
      };
    } else {
      return {"status": "fail", "message": (response.reasonPhrase)};
    }
  }
}
