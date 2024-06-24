import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/MessageModel.dart';
import 'conversation_screen.dart';
import '../config.dart';

class Conversation {
  final int otherUserId;
  final String lastMessage;
  final String userName;

  Conversation({
    required this.otherUserId,
    required this.lastMessage,
    required this.userName,
  });
}

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<Conversation> conversations = [];
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
      print('Utilisateur non connecté');
      setState(() {
        isAuthenticated = false;
      });
      return;
    }

    print('Token: $token');
    final response = await http.get(
      Uri.parse('${Config.API_URL}/api/v1/messages/received'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> messagesJson = json.decode(response.body);
      final Map<int, Message> latestMessages = {};

      for (var messageJson in messagesJson) {
        final message = Message.fromJson(messageJson);
        latestMessages[message.sentById] = message;
      }

      setState(() {
        conversations = latestMessages.values.map((message) {
          return Conversation(
            otherUserId: message.sentById,
            lastMessage: message.content,
            userName: message.sentByName,
          );
        }).toList();
      });
    } else {
      print('Erreur lors de la récupération des messages: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isLargeScreen ? null : AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isAuthenticated ? buildMessageList() : buildNotAuthenticatedMessage(),
    );
  }

  Widget buildMessageList() {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationScreen(otherUserId: conversation.otherUserId),
              ),
            );
          },
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  conversation.userName[0],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                conversation.userName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(conversation.lastMessage),
            ),
          ),
        );
      },
    );
  }

  Widget buildNotAuthenticatedMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            "Vous n'êtes pas connecté.",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            "Veuillez vous connecter pour voir les messages.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
