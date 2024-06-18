import 'package:client/config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    print('Tentative de connexion avec email: ${_emailController.text}');

    try {
      print('Envoi de la requête de connexion...');
      final response = await http.post(
        Uri.parse('${Config.API_URL}/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Connexion réussie');
        final data = json.decode(response.body);
        final String token = data['access_token'];
        final int userId = data['user_id'];

        print('Token JWT reçu: $token');
        print('UserID reçu: $userId');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', token);
        await prefs.setInt('userId', userId);

        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/compte');
      } else {
        print('Échec de la connexion avec le code ${response.statusCode}');
        _showErrorDialog('Échec de la connexion. Veuillez réessayer.');
      }
    } catch (e) {
      print('Exception lors de la connexion: $e');
      _showErrorDialog('Une erreur est survenue. Veuillez réessayer.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Connexion'),
            ),
          ],
        ),
      ),
    );
  }
}
