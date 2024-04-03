import 'package:client/config.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Annonce.dart';
import '../widgets/MonWidgetImage.dart';
import 'annonce.detail_screen.dart';

class ListeScreen extends StatefulWidget {
  @override
  _ListeScreenState createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  late Future<List<Annonce>> futureAnnonces;

  @override
  void initState() {
    super.initState();
    futureAnnonces = fetchAnnonces();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<Annonce>> fetchAnnonces() async {
    final prefs = await SharedPreferences.getInstance();
    final maxDistance = prefs.getDouble('annonceDistance') ?? 100;
    final userId = prefs.getInt('userId');
    final position = await _determinePosition();
    final token = prefs.getString('jwtToken');
    http.Response response;

    if (token == null) {
      response = await http.get(
        Uri.parse('${Config.API_URL}/api/v1/annonces'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } else {
      response = await http.get(
        Uri.parse(
            '${Config.API_URL}/api/v1/annonces/with-objects?userId=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    }

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((annonce) {
        final annonceObj = Annonce.fromJson(annonce);
        annonceObj.calculateDistance(
            userLat: position.latitude, userLon: position.longitude);
        return annonceObj;
      }).where((annonce) {
        return annonce.km <= maxDistance;
      }).toList();
    } else {
      throw Exception('Échec du chargement des annonces');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des annonces'),
      ),
      body: FutureBuilder<List<Annonce>>(
        future: futureAnnonces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Aucune annonce disponible.'));
          } else {
            List<Annonce> annonces = snapshot.data!;
            return ListView.builder(
              itemCount: annonces.length,
              itemBuilder: (context, index) {
                final annonce = annonces[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AnnonceDetailPage(annonce: annonces[index]),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(
                        8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(
                                  8.0)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image(
                              image: annonce.getImageProvider(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.all(8.0),
                          child: Text(
                            annonce.title,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
