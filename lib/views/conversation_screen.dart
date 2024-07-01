import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/MessageModel.dart';
import '../config.dart';

class ConversationScreen extends StatefulWidget {
  final int conversationId;

  const ConversationScreen({Key? key, required this.conversationId}) : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Message> messages = [];
  TextEditingController messageController = TextEditingController();
  bool isAuthenticated = true;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      setState(() {
        isAuthenticated = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('${Config.API_URL}/api/v1/messages/conversation/${widget.conversationId}'),
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
      print('Erreur lors de la récupération des messages: ${response.body}');
    }
  }

  Future<void> sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) {
      setState(() {
        isAuthenticated = false;
      });
      return;
    }

    final messageContent = messageController.text;
    if (messageContent.isEmpty) return;

    final response = await http.post(
      Uri.parse('${Config.API_URL}/api/v1/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': messageContent,
        'sentById': userId,
        'conversationId': widget.conversationId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      messageController.clear();
      fetchMessages();
    } else {
      print('Erreur lors de l\'envoi du message: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message.sentByName),
                  subtitle: Text(message.content),
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
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message...',
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
}
