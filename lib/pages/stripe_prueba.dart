import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sigfrontend/components/BottonLoading.dart';
import 'package:sigfrontend/services/payment.services.dart';

class PruebaPago extends StatefulWidget {
  const PruebaPago({super.key});

  @override
  _PruebaPago createState() => _PruebaPago();
}

class _PruebaPago extends State<PruebaPago> {
  final PaymentServices _paymentServices = PaymentServices();
  bool isLoading = false;

  Future<void> makePayment() async {
    try {
      String clientSecret = await _paymentServices.createPaymentIntent(
        5000,
        'bob',
      );

      await _paymentServices.presentPaymentSheet(clientSecret);
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(content: Text("Pago realizado con éxito")),
      );
    } catch (e) {
      print('Error al procesar el pago: $e');
      setState(() {
        isLoading = false;
      });
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
          showDialog(
            context: context,
            builder:
                (_) => const AlertDialog(
                  content: Text("El pago fue cancelado por el usuario."),
                ),
          );
        } else {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  content: Text(
                    "Error en el pago: ${e.error.localizedMessage}",
                  ),
                ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text("Error en el pago: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 150),
            Center(
              child: BottonLoading(
                colorBack: Colors.deepPurpleAccent,
                colorFont: Colors.white,
                textTitle: "Realizar Pago",
                width: width * 0.8,
                height: 50,
                fontSize: 16,
                colorBackLoading: const Color.fromARGB(255, 157, 126, 244),
                textLoading: "Procesando...",
                isLoading: isLoading,
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await makePayment();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
