import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class Annonce {
  final int id;
  final String imageUrl;
  final String title;
  final String description;
  double km;
  final double latitude;
  final double longitude;
  final int ownerId;
  Uint8List? imageData;

  Annonce({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
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
      id: object['id'] as int? ?? -1,
      imageUrl: imageUrl,
      imageData: imageData,
      title: object['title'] as String? ?? 'Titre inconnu',
      description: object['description'] as String? ?? 'Description inconnue',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      ownerId: object['ownerId'] as int? ?? -1,
    );
  }

  ImageProvider<Object> getImageProvider() {
    if (imageUrl.startsWith('data:application/octet-stream;base64,')) {
      final correctImageUrl = imageUrl.replaceFirst('application/octet-stream', 'image/jpeg');
      final Uint8List bytes = base64Decode(correctImageUrl.split(',')[1]);
      return MemoryImage(bytes);
    } else if (imageUrl.startsWith('data:image')) {
      final String base64String = imageUrl.split(',')[1];
      final Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } else if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage('assets/images/default_image.png');
    }
  }

  void calculateDistance({required double userLat, required double userLon}) {
    final double distance = Geolocator.distanceBetween(userLat, userLon, this.latitude, this.longitude);
    this.km = distance / 1000;
  }

  String getFormattedDistance() {
    return km.toStringAsFixed(2);
  }
}
