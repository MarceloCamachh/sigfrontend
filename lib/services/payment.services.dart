import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sigfrontend/utils/constants.dart';

class PaymentServices {
  Future<String> createPaymentIntent(int amount, String currency) async {
    final response = await http.post(
      Uri.parse('${Constantes.urlRender}/stripe/movil'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'amount': amount, 'currency': currency}),
    );

    final paymentData = json.decode(response.body);
    return paymentData['clientSecret'];
  }

  Future<void> presentPaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Optivision',
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
