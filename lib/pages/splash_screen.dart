import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/components/FadeThroughPageRoute.dart';
import 'package:sigfrontend/pages/home.dart';
import 'package:sigfrontend/pages/login.dart';
import 'package:sigfrontend/pages/registerPages/register.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import '../components/BottonChange.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserFromStorage();

    final isValid = await userProvider.isSessionValid();

    if (!mounted) return;

    if (isValid) {
      Navigator.of(
        context,
      ).pushReplacement(FadeThroughPageRoute(page: const HomePage()));
    }
  }

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
                      const SizedBox(height: 30),
                      BottonChange(
                        colorBack: Colors.white70,
                        colorFont: Colors.black,
                        textTile: 'Aplicar Ahora',
                        onPressed: () {
                          Navigator.of(context).push(
                            FadeThroughPageRoute(
                              page: const RegistroPaso1Page(),
                            ),
                          );
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
