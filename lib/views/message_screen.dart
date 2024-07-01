import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/MessageModel.dart';
import '../widgets/buildNotAuthenticatedMessage.dart';
import 'conversation_screen.dart';
import '../config.dart';

class Conversation {
  final int conversationId;
  final String lastMessage;
  final String userName;
  final String objectTitle;

  Conversation({
    required this.conversationId,
    required this.lastMessage,
    required this.userName,
    required this.objectTitle,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'],
      lastMessage: json['lastMessage'],
      userName: json['userName'],
      objectTitle: json['objectTitle'],
    );
  }
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
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      setState(() {
        isAuthenticated = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('${Config.API_URL}/api/v1/messages/received'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> conversationsJson = json.decode(response.body);
      setState(() {
        conversations = conversationsJson.map((json) => Conversation.fromJson(json)).toList();
      });
    } else {
      print('Erreur lors de la récupération des conversations: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isLargeScreen
          ? null
          : AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isAuthenticated ? buildConversationList() : buildNotAuthenticatedMessage(),
    );
  }

  Widget buildConversationList() {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ConversationScreen(conversationId: conversation.conversationId),
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.lastMessage),
                  Text('Objet: ${conversation.objectTitle}'), // Display object title
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
