import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config.dart';
import '../model/Annonce.dart';

class AnnonceDetailPage extends StatelessWidget {
  final Annonce annonce;

  const AnnonceDetailPage({Key? key, required this.annonce}) : super(key: key);

  Future<void> _navigateAndDisplayMessageScreen(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final userId = prefs.getInt('userId');

    if (token == null) {
      Fluttertoast.showToast(
        msg: 'Vous devez être connecté pour envoyer un message.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (annonce.ownerId == null || annonce.ownerId <= 0) {
      Fluttertoast.showToast(
        msg: 'Erreur interne, impossible d\'envoyer le message.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Envoyer un message à propos de "${annonce.title}"'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(hintText: "Tapez votre message ici"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final message = messageController.text;
              if (message.isNotEmpty) {
                final messageData = json.encode({
                  'content': message,
                  'sentById': userId,
                  'receivedById': annonce.ownerId,
                });

                final response = await http.post(
                  Uri.parse('${Config.API_URL}/api/v1/messages'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: messageData,
                );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  Fluttertoast.showToast(
                    msg: 'Message envoyé avec succès.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(
                    msg: 'Échec de l\'envoi du message : ${response.body}',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    try {
      if (imageUrl.startsWith('data:image') && imageUrl.contains('base64,')) {
        final base64String = imageUrl.split('base64,')[1];
        final decodedBytes = base64Decode(base64String);
        return Image.memory(decodedBytes, fit: BoxFit.cover);
      } else {
        return Image.network(imageUrl, fit: BoxFit.cover);
      }
    } catch (e) {
      print("Erreur de décodage base64 : $e");
      return const Icon(Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(annonce.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: _buildImage(annonce.imageUrl),
              ),
              const SizedBox(height: 16),
              Text(
                annonce.title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${annonce.km.toStringAsFixed(1)} km',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                annonce.description,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateAndDisplayMessageScreen(context),
                  icon: const Icon(Icons.message),
                  label: const Text('Contacter et Louer'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
