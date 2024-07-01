class Object {
  final int id;
  final String title;
  final String description;

  Object({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Object.fromJson(Map<String, dynamic> json) {
    return Object(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}

class Message {
  final int id;
  final String content;
  final int sentById;
  final String sentByName;
  final int conversationId;
  final DateTime createdAt;
  final Object? object;

  Message({
    required this.id,
    required this.content,
    required this.sentById,
    required this.sentByName,
    required this.conversationId,
    required this.createdAt,
    this.object,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    String sentByName = "${json['sentBy']['first_name']} ${json['sentBy']['last_name']}";
    return Message(
      id: json['id'],
      content: json['content'],
      sentById: json['sentById'],
      sentByName: sentByName,
      conversationId: json['conversationId'],
      createdAt: DateTime.parse(json['createdAt']),
      object: json['conversation']['annonce']['object'] != null ? Object.fromJson(json['conversation']['annonce']['object']) : null,
    );
  }
}
