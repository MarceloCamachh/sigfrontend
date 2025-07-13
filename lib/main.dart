import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/pages/splash_screen.dart';
import 'package:sigfrontend/providers/user_provider.dart';
import 'package:sigfrontend/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = Constantes.publicKey;

  try {
    await Stripe.instance.applySettings();
  } catch (e) {
    print('Error inicializando Stripe: $e');
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: MaterialApp(
        title: 'SIG Rider',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(137, 90, 135, 218),
          ),
          textTheme: GoogleFonts.nunitoTextTheme(),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
