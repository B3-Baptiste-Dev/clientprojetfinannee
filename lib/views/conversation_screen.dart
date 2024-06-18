import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/MessageModel.dart';
import '../config.dart';

class ConversationScreen extends StatefulWidget {
  final int otherUserId;

  const ConversationScreen({Key? key, required this.otherUserId}) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Message> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
        print('Error fetching conversation: ${response.body}');
      }
    }
  }

  Future<void> sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final userId = prefs.getInt('userId');

    if (token != null && userId != null && _messageController.text.isNotEmpty) {
      final messageData = jsonEncode({
        "content": _messageController.text,
        "sentById": userId,
        "receivedById": widget.otherUserId,
      });

      final response = await http.post(
        Uri.parse('${Config.API_URL}/api/v1/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: messageData,
      );

      if (response.statusCode == 201) {
        print('Message sent successfully');
        _messageController.clear();
        fetchConversation();
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        print('Error sending message: ${response.body}');
      }
    } else {
      print("Please make sure all fields are correctly filled.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isMe = messages[index].sentById != widget.otherUserId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Card(
                    color: isMe ? Colors.blue : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        messages[index].content,
                        style: TextStyle(color: isMe ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 40.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
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
    _scrollController.dispose();
    super.dispose();
  }
}
