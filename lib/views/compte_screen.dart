import 'package:client/config.dart';
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    await prefs.remove('userId');
    setState(() {
      isLoggedIn = false;
      firstName = '';
      lastName = '';
    });
    // Relancer l'application
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isLargeScreen
          ? null
          : AppBar(
        title: const Text('Compte'),
        backgroundColor: Config.lightBlue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoggedIn) ...[
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Config.lightBlue,
                  child: Text(
                    '${firstName[0]}${lastName[0]}',
                    style: TextStyle(fontSize: 40, color: Config.white),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Bienvenue, $firstName $lastName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Config.darkGray,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: Icon(Icons.logout),
                  label: const Text('Se déconnecter'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Config.white,
                    backgroundColor: Config.brightOrange,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/myannonces'),
                  icon: Icon(Icons.list),
                  label: const Text('Mes annonces'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Config.white,
                    backgroundColor: Config.lightBlue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ] else ...[
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Se connecter'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Config.white,
                    backgroundColor: Config.lightBlue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("S'inscrire"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Config.white,
                    backgroundColor: Config.lightBlue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
