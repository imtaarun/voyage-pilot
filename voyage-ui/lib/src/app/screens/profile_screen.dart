import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              // You can add a user image here later
              child: Icon(Icons.person_rounded, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              'Yonko Luffy', // Placeholder name
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'luffy@example.com', // Placeholder email
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: () {},
                child: const Text('Edit Profile')
            )
          ],
        ),
      ),
    );
  }
}