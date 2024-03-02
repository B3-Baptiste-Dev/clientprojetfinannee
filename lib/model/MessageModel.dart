class Message {
  final int id;
  final String content;
  final int sentById;
  final String sentByName;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.content,
    required this.sentById,
    required this.sentByName,
    required this.createdAt
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    String sentByName = "${json['sentBy']['first_name']} ${json['sentBy']['last_name']}";
    return Message(
      id: json['id'],
      content: json['content'],
      sentById: json['sentById'],
      sentByName: sentByName,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
