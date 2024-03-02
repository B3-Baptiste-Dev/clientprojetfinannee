import 'package:client/config.dart';
import 'package:client/views/parametre_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CompteScreen extends StatefulWidget {
  @override
  _CompteScreenState createState() => _CompteScreenState();
}

class _CompteScreenState extends State<CompteScreen> {
  String firstName = "";
  String lastName = "";
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.API_URL}/api/v1/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          firstName = userData['first_name'];
          lastName = userData['last_name'];
          isLoggedIn = true;
        });
      } else {
        print('Erreur lors de la récupération des informations de l\'utilisateur: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoggedIn) ...[
              Text('Bienvenue, $firstName $lastName'),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('jwtToken');
                  setState(() {
                    isLoggedIn = false;
                    firstName = '';
                    lastName = '';
                  });
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Se déconnecter'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
                child: const Text("Paramètres"),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Se connecter'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("S'inscrire"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}