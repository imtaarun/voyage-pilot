import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user['username'] ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/users/${widget.user['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': newUsername}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully.')),
        );
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false)
              .updateUserField('username', newUsername);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _resetPassword() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset Password'),
        content: Text('An email with password reset instructions will be sent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset email sent.')), // ToDo
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, size: 45, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),

            Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your name',
              ),
            ),

            const SizedBox(height: 20),
            Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              widget.user['email'] ?? 'N/A',
              style: TextStyle(fontSize: 16),
            ),

            if (widget.user['joined'] != null) ...[
              const SizedBox(height: 20),
              Text("Member since", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                widget.user['joined'],
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.save),
              label: Text(_isSaving ? "Saving..." : "Save Changes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _resetPassword,
              icon: Icon(Icons.lock_reset),
              label: Text("Reset Password"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueGrey,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                label: Text("Back to Dashboard"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
