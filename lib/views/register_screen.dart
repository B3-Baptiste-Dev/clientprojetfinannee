import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/config.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _passwordError = '';
  String _confirmPasswordError = '';

  bool _isPasswordValid(String password) {
    if (password.length < 8) {
      setState(() {
        _passwordError = 'Le mot de passe doit comporter au moins 8 caractères.';
      });
      return false;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$').hasMatch(password)) {
      setState(() {
        _passwordError = 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un symbole.';
      });
      return false;
    } else {
      setState(() {
        _passwordError = '';
      });
      return true;
    }
  }

  bool _arePasswordsMatching(String password, String confirmPassword) {
    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'Les mots de passe ne correspondent pas.';
      });
      return false;
    } else {
      setState(() {
        _confirmPasswordError = '';
      });
      return true;
    }
  }

  Future<void> _register() async {
    if (!_isPasswordValid(_passwordController.text) || !_arePasswordsMatching(_passwordController.text, _confirmPasswordController.text)) {
      return;
    }

    final body = json.encode({
      'email': _emailController.text,
      'password': _passwordController.text,
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
    });

    final response = await http.post(
      Uri.parse('${Config.API_URL}/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final String token = data['data']['access_token'];
      final int userId = data['data']['user_id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtToken', token);
      await prefs.setInt('userId', userId);

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacementNamed(context, '/');
    } else {
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  errorText: _passwordError.isNotEmpty ? _passwordError : null,
                ),
                obscureText: true,
                onChanged: (value) {
                  _isPasswordValid(value);
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  errorText: _confirmPasswordError.isNotEmpty ? _confirmPasswordError : null,
                ),
                obscureText: true,
                onChanged: (value) {
                  _arePasswordsMatching(_passwordController.text, value);
                },
              ),
              ElevatedButton(
                onPressed: _register,
                child: Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
