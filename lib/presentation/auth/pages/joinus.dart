import 'package:flutter/material.dart';
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http;
import 'package:ikantest/presentation/auth/pages/bahasa.dart';
import 'package:ikantest/presentation/auth/pages/signup.dart';
import 'package:shared_preferences/shared_preferences.dart'; // To store the token locally

class JoinUs extends StatefulWidget {
  const JoinUs({super.key});

  @override
  State<JoinUs> createState() => _LoginPageState();
}

class _LoginPageState extends State<JoinUs> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://ikanapi-465762037323.asia-southeast2.run.app/api/users/login'), // Ganti dengan URL API login Anda
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        // Save token using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to another page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Bahasa()),
        );
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['error'] ?? 'Login gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40.0),
            Row(
              children: [
                Image.asset(
                  'assets/images/ikan.png',
                  width: 70.0,
                  height: 70.0,
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Masukkan email Anda untuk mendaftar atau masuk.',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an Account?",
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUp(),
                      ),
                    );
                  },
                  child: Text(
                    ' Sign Up Now',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13.0),
            Text(
              'Dengan melanjutkan, saya\nmenyetujui Kebijakan Privasi dan\nKetentuan Penggunaan.',
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 50.0),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
