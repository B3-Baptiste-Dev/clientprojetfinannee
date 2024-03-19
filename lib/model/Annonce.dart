import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class Annonce {
  final String imageUrl;
  final String title;
  double km;
  final double latitude;
  final double longitude;
  final int ownerId;
  Uint8List? imageData;

  Annonce({
    required this.imageUrl,
    required this.title,
    this.km = 0.0,
    required this.latitude,
    required this.longitude,
    required this.ownerId,
    this.imageData,
  });

  factory Annonce.fromJson(Map<String, dynamic> json) {
    var object = json['object'] ?? {};
    String imageUrl = object['imageUrl'] as String? ?? '';
    Uint8List? imageData;

    if (imageUrl.startsWith('data:image')) {
      String base64Data = imageUrl.split(',')[1];
      imageData = base64Decode(base64Data);
    }

    return Annonce(
      imageUrl: imageUrl,
      imageData: imageData,
      title: object['title'] as String? ?? 'Titre inconnu',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      ownerId: object['ownerId'] as int? ?? -1,
    );
  }

  ImageProvider<Object> getImageProvider() {
    if (imageUrl.startsWith('data:image')) {
      final String base64String = imageUrl.split(',')[1];
      final Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } else {
      return NetworkImage(imageUrl);
    }
  }

  void calculateDistance({required double userLat, required double userLon}) {
    final double distance = Geolocator.distanceBetween(userLat, userLon, this.latitude, this.longitude);
    this.km = distance / 1000;
  }
}
