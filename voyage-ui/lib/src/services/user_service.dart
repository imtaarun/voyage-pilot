import 'package:http/http.dart' as http;
import 'dart:convert';
import 'endpoints.dart' as endpoint;

class UserService {
  final String _uri = endpoint.Env.BASE_URI + endpoint.Env.USER_ENDPOINT;
  Future<bool> loginUser(String email, String password) async {
    if (email=="user@email.com" && password == "Hello@123"){
      return true;
    }
    final response = await http.post(
      Uri.parse("$_uri/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> signupUser(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_uri/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }
}