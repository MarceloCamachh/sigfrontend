import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sigfrontend/components/BottonLoading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sigfrontend/utils/constants.dart';

class PruebaPago extends StatefulWidget {
  final Map<String, dynamic>? order;
  const PruebaPago({super.key, this.order});

  @override
  _PruebaPago createState() => _PruebaPago();
}

class _PruebaPago extends State<PruebaPago> {
  bool isLoading = false;
  String? paymentUrl;
  String? errorMessage;

  Future<void> generatePaymentLink() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final amount =
          widget.order != null
              ? (widget.order!['total_payable']?.toDouble() ?? 50.00) * 100
              : 5000; // Convert to cents
      final currency = 'bob'; // Bolivian Boliviano
      final orderId = widget.order?['id'] ?? 'Test';

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/checkout/sessions'),
        headers: {
          'Authorization': 'Bearer ${Constantes.publicKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_method_types[]': 'card',
          'line_items[0][price_data][currency]': currency,
          'line_items[0][price_data][product_data][name]': 'Order $orderId',
          'line_items[0][price_data][unit_amount]': amount.toInt().toString(),
          'line_items[0][quantity]': '1',
          'mode': 'payment',
          'success_url':
              'https://your-app.com/success?session_id={CHECKOUT_SESSION_ID}',
          'cancel_url': 'https://your-app.com/cancel',
          'metadata[order_id]': orderId, // Optional: for webhook tracking
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          paymentUrl = data['url'];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enlace de pago generado. Escanea el QR para pagar.'),
          ),
        );
      } else {
        throw Exception('Error al generar el enlace de pago: ${response.body}');
      }
    } catch (e) {
      print('Error al procesar el pago: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Pago'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            else if (paymentUrl != null)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Escanea el QR para realizar el pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  QrImageView(
                    data: paymentUrl!,
                    version: QrVersions.auto,
                    size: width * 0.6,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Monto: Bs. ${(widget.order?['total_payable']?.toDouble() ?? 50.00).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: BottonLoading(
                  colorBack: Colors.deepPurpleAccent,
                  colorFont: Colors.white,
                  textTitle: "Generar QR de Pago",
                  width: width * 0.8,
                  height: 50,
                  fontSize: 16,
                  colorBackLoading: const Color.fromARGB(255, 157, 126, 244),
                  textLoading: "Generando QR...",
                  isLoading: isLoading,
                  onPressed: generatePaymentLink,
                ),
              ),
            if (paymentUrl != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: generatePaymentLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Generar Nuevo QR'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
