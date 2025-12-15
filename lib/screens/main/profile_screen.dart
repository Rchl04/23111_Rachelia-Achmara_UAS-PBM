// lib/screens/main/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Memuat...';
  String _userId = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final storedUsername = prefs.getString('username') ?? 'Pengguna MarkasDone';
    final storedUserId = prefs.getString('userId') ?? 'Tidak Ditemukan';

    if (mounted) {
      setState(() {
        _username = storedUsername;
        _userId = storedUserId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          Text(
            _username,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Anggota MarkasDone',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),

          const Divider(),

          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 1,
            child: ListTile(
              leading: const Icon(Icons.badge, color: Colors.blue),
              title: const Text('User ID'),
              subtitle: Text(_userId),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 1,
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email'),
              subtitle: const Text(
                'Email tidak disimpan lokal untuk keamanan.',
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
