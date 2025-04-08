import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _firestoreService = FirestoreService();

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final emailOrUsername = _emailOrUsernameController.text.trim();
        String? email;
        
        // Check if input is email or username
        if (emailOrUsername.contains('@')) {
          // Input is an email
          email = emailOrUsername;
        } else {
          // Input is a username, find the corresponding email
          final userId = await _firestoreService.findUserByUsername(emailOrUsername);
          if (userId == null) {
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No user found with this username',
            );
          }
          
          // Get the user data to find the email
          final userData = await _firestoreService.getUserData();
          if (userData == null || userData['email'] == null) {
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'User data not found',
            );
          }
          
          email = userData['email'];
        }
        
        // Sign in with email and password
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email!,
          password: _passwordController.text.trim(),
        );
        
        // Get user data from Firestore
        final user = userCredential.user;
        if (user != null) {
          final firestore = FirebaseFirestore.instance;
          final userDoc = await firestore.collection('users').doc(user.uid).get();
          
          if (!userDoc.exists) {
            // If user document doesn't exist, create it
            await firestore.collection('users').doc(user.uid).set({
              'email': user.email,
              'username': user.email?.split('@')[0] ?? 'User',
              'balance': 0,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred during login';
        if (e.code == 'user-not-found') {
          message = 'No user found with this email or username';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email address';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _resetPassword() async {
    final emailOrUsername = _emailOrUsernameController.text.trim();
    String? email;
    
    // Check if input is email or username
    if (emailOrUsername.contains('@')) {
      // Input is an email
      email = emailOrUsername;
    } else {
      // Input is a username, find the corresponding email
      final userId = await _firestoreService.findUserByUsername(emailOrUsername);
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found with this username'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Get the user data to find the email
      final userData = await _firestoreService.getUserData();
      if (userData == null || userData['email'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      email = userData['email'];
    }
    
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email or username'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent. Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred while sending reset email';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo or Icon
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Welcome Text
                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email or Username Field
                  TextFormField(
                    controller: _emailOrUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Email or Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email or username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  
                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Login Button
                  FilledButton(
                    onPressed: _isLoading ? null : _login,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Login'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 