class ChatModel {
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;
  final String messageType;
  final DateTime timeSent;
  String? messageId;

  ChatModel({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.messageType,
    required this.timeSent,
    this.messageId,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, {String? msgId}) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      messageType: map['messageType'] ?? '',
      timeSent: DateTime.tryParse(map['timeSent'] ?? '') ?? DateTime.now(),
      messageId: map['messageId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'messageType': messageType,
      'timeSent': timeSent.toIso8601String(),
      'messageId': messageId,
    };
  }
}
