import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:voyageui/src/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:voyageui/src/screens/signup_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message ="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/voyage-icon.png', height: 120),
            SizedBox(height: 5),
            Text("Voyage Pilot", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text("Login"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              // onPressed: _handleGoogleSignIn,
              onPressed: () {},
              child: Text("Sign in with Google"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
              },
              child: Text("Don't have an account? Sign Up"),
            ),
            const SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final url = Uri.parse('http://10.0.2.2:3000/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body)['user'];
        setState(() {
          _message = 'Login successful!';
        });
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(userData);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        }
      } else {
        setState(() {
          _message = jsonDecode(response.body)['message'] ?? 'Login failed.';
        });
      }
    } catch (e) {
      developer.log(e.toString());
      setState(() {
        _message = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}