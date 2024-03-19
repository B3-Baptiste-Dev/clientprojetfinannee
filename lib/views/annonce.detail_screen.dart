import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../model/Annonce.dart';

class AnnonceDetailPage extends StatelessWidget {
  final Annonce annonce;

  const AnnonceDetailPage({Key? key, required this.annonce}) : super(key: key);

  Future<void> _navigateAndDisplayMessageScreen(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final userId = prefs.getInt('userId');

    print("Token: $token");
    print("UserId: $userId");
    print("OwnerId: ${annonce.ownerId}");

    if (token == null) {
      print("Token est null, utilisateur non connecté.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour envoyer un message.')),
      );
      return;
    }

    if (annonce.ownerId == null || annonce.ownerId <= 0) {
      print("OwnerId invalide: ${annonce.ownerId}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur interne, impossible d\'envoyer le message.')),
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

                print("Message Data: $messageData");

                final response = await http.post(
                  Uri.parse('${Config.API_URL}/api/v1/messages'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: messageData,
                );

                print("Response Status Code: ${response.statusCode}");
                print("Response Body: ${response.body}");

                if (response.statusCode == 200 || response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message envoyé avec succès.')),
                  );
                  Navigator.of(context).pop(); // Fermez la boîte de dialogue après le succès
                } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Échec de l\'envoi du message : ${response.body}')),
                );
                Navigator.of(context).pop(); // Fermez la boîte de dialogue également en cas d'échec
              }

            }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(annonce.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(annonce.imageUrl),
            const SizedBox(height: 8),
            Text(
              annonce.title,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            Text(
              '${annonce.km.toStringAsFixed(1)} km',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            ElevatedButton(
              onPressed: () => _navigateAndDisplayMessageScreen(context),
              child: const Text('Contacter et Louer'),
            ),
          ],
        ),
      ),
    );
  }
}
