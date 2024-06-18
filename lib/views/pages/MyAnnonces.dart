import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
import '../../model/Annonce.dart';
import 'EditAnnoncePage.dart';

class MyAnnoncesPage extends StatefulWidget {
  @override
  _MyAnnoncesPageState createState() => _MyAnnoncesPageState();
}

class _MyAnnoncesPageState extends State<MyAnnoncesPage> {
  late Future<List<Annonce>> futureAnnonces;

  @override
  void initState() {
    super.initState();
    futureAnnonces = fetchMyAnnonces();
  }

  Future<List<Annonce>> fetchMyAnnonces() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) {
      throw Exception('Utilisateur non connecté ou ID utilisateur manquant');
    }

    final response = await http.get(
      Uri.parse(
          '${Config.API_URL}/api/v1/annonces/with-objects?userId=$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((annonce) => Annonce.fromJson(annonce)).toList();
    } else {
      throw Exception('Échec du chargement des annonces: ${response.statusCode}');
    }
  }


  Future<void> deleteAnnonce(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await http.delete(
      Uri.parse('${Config.API_URL}/api/v1/annonces/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Annonce supprimée')),
      );
      setState(() {
        futureAnnonces = fetchMyAnnonces();
      });
    } else {
      throw Exception('Échec de la suppression de l\'annonce: ${response.statusCode}');
    }
  }

  void editAnnonce(Annonce annonce) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAnnoncePage(annonce: annonce)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Annonces'),
      ),
      body: FutureBuilder<List<Annonce>>(
        future: futureAnnonces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune annonce à afficher.'));
          } else {
            return ListView(
              children: snapshot.data!.map((annonce) {
                return ListTile(
                  title: Text(annonce.title),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => editAnnonce(annonce),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteAnnonce(annonce.id),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO Logique pour naviguer vers la page de création d'une nouvelle annonce
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

