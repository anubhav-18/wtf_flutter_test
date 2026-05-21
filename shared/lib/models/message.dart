enum MessageStatus {
  sending,
  sent,
  read;

  String toJson() => name;

  static MessageStatus fromJson(String value) {
    return MessageStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => MessageStatus.sent,
    );
  }
}

class Message {
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    required this.status,
    this.isSystem = false,
    this.imageData,
    this.fileName,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;
  final bool isSystem;
  /// Base64-encoded image or PDF data for attachment messages.
  final String? imageData;
  /// Original filename for attachment messages.
  final String? fileName;

  bool get isImage {
    if (fileName == null) return false;
    final lower = fileName!.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  bool get isPdf {
    return fileName?.toLowerCase().endsWith('.pdf') ?? false;
  }

  bool get hasAttachment => imageData != null;

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? createdAt,
    MessageStatus? status,
    bool? isSystem,
    String? imageData,
    String? fileName,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isSystem: isSystem ?? this.isSystem,
      imageData: imageData ?? this.imageData,
      fileName: fileName ?? this.fileName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toJson(),
      'isSystem': isSystem,
      'imageData': imageData,
      'fileName': fileName,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: MessageStatus.fromJson(json['status'] as String? ?? 'sent'),
      isSystem: json['isSystem'] as bool? ?? false,
      imageData: json['imageData'] as String?,
      fileName: json['fileName'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Message &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            status == other.status &&
            imageData == other.imageData;
  }

  @override
  int get hashCode => Object.hash(id, status, imageData);
}
