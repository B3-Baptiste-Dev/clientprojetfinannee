import 'package:geolocator/geolocator.dart';

class Annonce {
  String imageUrl;
  String title;
  double km;
  double latitude;
  double longitude;

  Annonce({required this.imageUrl, required this.title, this.km = 0.0, required this.latitude, required this.longitude});

  factory Annonce.fromJson(Map<String, dynamic> json) {
    var object = json['object'] ?? {};
    return Annonce(
      imageUrl: object['imageUrl'] ?? 'https://via.placeholder.com/150',
      title: object['title'] ?? 'Titre inconnu',
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }

  void calculateDistance({required double userLat, required double userLon}) {
    final double distance = Geolocator.distanceBetween(
      userLat,
      userLon,
      this.latitude,
      this.longitude,
    );
    this.km = distance / 1000;
  }
}
