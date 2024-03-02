import 'package:client/config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Si vous avez un champ nom

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
        'name': _nameController.text, // Optionnel, selon votre API
      }),
    );

    if (response.statusCode == 201) {
      // Redirection vers la page de connexion
      Navigator.of(context).pop();
    } else {
      // Gérer l'erreur d'inscription
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text("Échec de l'inscription. Veuillez réessayer."),
            actions: [
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Nom'), // Optionnel
        ),
        ElevatedButton(
          onPressed: _register,
          child: Text("S'inscrire"),
          ),
          ],
        ),
      ),
    );
  }
}
