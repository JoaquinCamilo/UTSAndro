import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user!.uid).get();
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              user?.email ?? 'No email',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 40),
          _buildSection(
            'Account',
            [
              _buildListTile(
                'Email',
                user?.email ?? 'No email',
                Icons.email,
              ),
              _buildListTile(
                'Username',
                _userData?['username'] ?? 'Not set',
                Icons.person,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Settings',
            [
              _buildListTile(
                'Notifications',
                'Manage notifications',
                Icons.notifications,
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    secondary: const Icon(Icons.palette),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle app theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (bool value) {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            'Support',
            [
              _buildListTile(
                'Help & Feedback',
                'Get help or send feedback',
                Icons.help,
                onTap: () {
                  // Navigate to help screen
                },
              ),
              _buildListTile(
                'About',
                'App information',
                Icons.info,
                onTap: () {
                  // Navigate to about screen
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
} 