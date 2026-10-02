import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voyageui/src/screens/home_screen.dart';
import 'package:voyageui/src/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString("username");
  runApp(MyApp(isLoggedIn: username != null, username: username));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? username;

  const MyApp({super.key, required this.isLoggedIn, this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn ? HomeScreen(username: username!) : const LoginScreen(),
    );
  }
}