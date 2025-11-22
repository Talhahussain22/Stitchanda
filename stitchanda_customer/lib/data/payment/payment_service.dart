import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../stripe_config.dart';

class PaymentIntentResult {
  final String id;
  final String clientSecret;
  final String status;
  PaymentIntentResult({required this.id, required this.clientSecret, required this.status});
}

class PaymentService {
  Future<PaymentIntentResult> createPaymentIntent({
    required double amountMajor,
    required String description,
    required String destinationAccount,
  }) async {
    final amountCents = StripeConfig.amountToCents(amountMajor);
    final feeCents = StripeConfig.applicationFeeCents(amountMajor);

    final body = {
      'amount': amountCents.toString(),
      'currency': StripeConfig.currency,
      'payment_method_types[]': 'card',
      'application_fee_amount': feeCents.toString(),
      'description': description,
      'transfer_data[destination]': destinationAccount,
    };

    final headers = {
      'Authorization': 'Bearer ${StripeConfig.secretKey}',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final resp = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: headers,
      body: body,
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Stripe error ${resp.statusCode}: ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final clientSecret = (data['client_secret'] ?? '').toString();
    final id = (data['id'] ?? '').toString();
    if (clientSecret.isEmpty || id.isEmpty) {
      throw Exception('Invalid PaymentIntent response');
    }
    return PaymentIntentResult(id: id, clientSecret: clientSecret, status: (data['status'] ?? '').toString());
  }
}
