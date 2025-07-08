import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sigfrontend/providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final userProvider = Provider.of<UserProvider>(context);
    print(userProvider.email);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to the Home Page',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: const Text('Click Me')),
            ],
          ),
        ),
      ),
    );
  }
}
