import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');
    return regex.hasMatch(password);
  }

  bool isEmailValid(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifreler eşleşmiyor.")),
      );
      return;
    }

    final usernameExists = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (usernameExists.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı adı zaten mevcut.")),
      );
      return;
    }

    final emailExists = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (emailExists.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bu e-posta adresi zaten kullanılıyor.")),
      );
      return;
    }

    if (!isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doğru bir e-posta adresi giriniz.")),
      );
      return;
    }

    if (!isPasswordValid(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Şifre en az 8 karakter, büyük/küçük harf ve rakam içermelidir.")),
      );
      return;
    }

    String hashPassword(String password) {
      return sha256.convert(utf8.encode(password)).toString();
    }

    final hashedPassword = hashPassword(password);

    try {
      await _firestore.collection('users').add({
        'email': email,
        'username': username,
        'password': hashedPassword,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Başarılı bir şekilde kaydoldunuz. Şimdi giriş yapabilirsiniz!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kaydolurken bir hata çıktı: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Kayıt Ol'), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifreyi Tekrar Girin',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Kayıt Ol', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Zaten kaydoldum, giriş yap',
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
