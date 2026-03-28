class ChatThreadModel {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime? updatedAt;
  final int unreadCount;

  const ChatThreadModel({
    required this.id,
    required this.title,
    required this.lastMessage,
    this.updatedAt,
    this.unreadCount = 0,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    return ChatThreadModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      lastMessage: json['lastMessage']?.toString() ?? '',
      updatedAt: _parseDate(json['updatedAt']),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'updatedAt': updatedAt?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  ChatThreadModel copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return ChatThreadModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String sender;
  final String content;
  final bool isMine;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.sender,
    required this.content,
    required this.isMine,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isMine: json['isMine'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'sender': sender,
      'content': content,
      'isMine': isMine,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
