import 'package:client/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/MessageModel.dart';

class ConversationScreen extends StatefulWidget {
  final int otherUserId;

  const ConversationScreen({Key? key, required this.otherUserId}) : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Message> messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchConversation();
  }

  Future<void> fetchConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    if (token != null) {
      final response = await http.get(
        Uri.parse('${Config.API_URL}/api/v1/messages/conversation/${widget.otherUserId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        setState(() {
          messages = messagesJson.map((json) => Message.fromJson(json)).toList();
        });
      } else {
        print('Erreur lors de la récupération de la conversation: ${response.body}');
      }
    }
  }

  Future<void> sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final userId = prefs.getInt('userId'); // Assurez-vous que vous enregistrez l'userId lors de la connexion

    if (token != null && userId != null && _messageController.text.isNotEmpty) {
      final messageData = jsonEncode({
        "content": _messageController.text,
        "sentById": userId, // Utilisez votre ID d'utilisateur enregistré ou récupéré lors de la connexion
        "receivedById": widget.otherUserId, // L'ID de l'utilisateur destinataire
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
        print('Message envoyé avec succès');
        _messageController.clear();
        fetchConversation(); // Rafraîchir la liste des messages
      } else {
        print('Erreur lors de l\'envoi du message: ${response.body}');
      }
    } else {
      print("Veuillez vous assurer que tous les champs sont correctement remplis.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isMe = messages[index].sentById != widget.otherUserId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      messages[index].content,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
