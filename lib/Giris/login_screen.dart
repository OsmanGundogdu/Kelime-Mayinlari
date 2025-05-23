import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:proje2/home_screen.dart';
import 'dart:convert';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  void _signIn() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı adı ve şifre boş olamaz.")),
      );
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kullanıcı bulunamadı.")),
        );
        return;
      }

      final userDoc = snapshot.docs.first;
      final storedPassword = userDoc['password'];

      if (storedPassword == hashPassword(password)) {
        final String userId = userDoc.id;
        final String username = userDoc['username'];
        final int gamesPlayed = userDoc['gameplayed'] ?? 0;
        final int gamesWon = userDoc['gamewon'] ?? 0;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userId: userId,
              username: username,
              gamesPlayed: gamesPlayed,
              gamesWon: gamesWon,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yanlış şifre.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Giriş başarısız: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    labelStyle:
                        const TextStyle(color: Colors.white, fontSize: 16),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    labelStyle:
                        const TextStyle(color: Colors.white, fontSize: 16),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blueGrey.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      const Text('Giriş Yap', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Hesabın yok mu? Kayıt Ol',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
