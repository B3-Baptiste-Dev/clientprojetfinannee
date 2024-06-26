import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../model/Annonce.dart';
import 'annonce.detail_screen.dart';
import '../config.dart';

class ListeScreen extends StatefulWidget {
  @override
  _ListeScreenState createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  late Future<List<Annonce>> futureAnnonces;
  double maxDistance = 100;

  @override
  void initState() {
    super.initState();
    _fetchAndSetAnnonces();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAndSetAnnonces();
  }

  Future<void> _fetchAndSetAnnonces() async {
    setState(() {
      futureAnnonces = fetchAnnonces();
    });
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
        Uri.parse('${Config.API_URL}/api/v1/annonces/excludeUserId?excludeUserId=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    }

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map<Annonce>((annonce) {
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

  void _showFilterDialog() {
    double tempDistance = maxDistance;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filtrer par distance'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Distance maximale (km): ${tempDistance.toInt()}'),
                  Slider(
                    value: tempDistance,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: tempDistance.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        tempDistance = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  maxDistance = tempDistance;
                  _fetchAndSetAnnonces();
                });
                Navigator.of(context).pop();
              },
              child: Text('Appliquer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isLargeScreen ? null : AppBar(
        title: Text('Liste des annonces'),
        backgroundColor: Config.lightBlue,
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
            int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 1;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: AlignedGridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
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
                      margin: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15.0)),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                color: Colors.grey[200],
                                child: annonce.imageData != null
                                    ? Image.memory(
                                  annonce.imageData!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error,
                                      stackTrace) =>
                                      Icon(Icons.error),
                                )
                                    : Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                annonce.title,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Config.navyBlue,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${annonce.getFormattedDistance()} km',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Config.darkGray,
                                    ),
                                  ),
                                  Text(
                                    annonce.description,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Config.darkGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: annonces.length,
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterDialog,
        child: Icon(Icons.filter_list),
        backgroundColor: Config.lightBlue,
      ),
    );
  }
}
