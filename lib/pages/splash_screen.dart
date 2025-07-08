import 'package:flutter/material.dart';
import 'package:sigfrontend/components/FadeThroughPageRoute.dart';
import 'package:sigfrontend/pages/login.dart';
import '../components/BottonChange.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/image_splash.jpg',
                  fit: BoxFit.cover,
                  width: width,
                  height: width * 0.9,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Bienvenido/a a la app de entrega',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 80),
                      BottonChange(
                        colorBack: Colors.black,
                        colorFont: Colors.white,
                        textTile: 'Iniciar Sesión',
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(FadeThroughPageRoute(page: const LoginPage()));
                        },
                        width: width * 0.8,
                        height: 55,
                        fontSize: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }
}
