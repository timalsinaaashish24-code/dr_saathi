/*
 * Dr. Saathi - Communication Models
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:uuid/uuid.dart';

class CallSession {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final CallType type;
  final CallStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final Duration? duration;
  final String? roomId;
  final Map<String, dynamic> metadata;
  final List<CallParticipant> participants;

  CallSession({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.type,
    this.status = CallStatus.initiated,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.duration,
    this.roomId,
    this.metadata = const {},
    this.participants = const [],
  });

  factory CallSession.fromJson(Map<String, dynamic> json) {
    return CallSession(
      id: json['id'],
      appointmentId: json['appointmentId'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      type: CallType.values.byName(json['type']),
      status: CallStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      duration: json['duration'] != null ? Duration(seconds: json['duration']) : null,
      roomId: json['roomId'],
      metadata: json['metadata'] ?? {},
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => CallParticipant.fromJson(p))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'patientId': patientId,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'duration': duration?.inSeconds,
      'roomId': roomId,
      'metadata': metadata,
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }

  CallSession copyWith({
    String? id,
    String? appointmentId,
    String? doctorId,
    String? patientId,
    CallType? type,
    CallStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    Duration? duration,
    String? roomId,
    Map<String, dynamic>? metadata,
    List<CallParticipant>? participants,
  }) {
    return CallSession(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      roomId: roomId ?? this.roomId,
      metadata: metadata ?? this.metadata,
      participants: participants ?? this.participants,
    );
  }
}

class CallParticipant {
  final String userId;
  final String name;
  final ParticipantRole role;
  final ParticipantStatus status;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final bool audioEnabled;
  final bool videoEnabled;
  final String? deviceId;

  CallParticipant({
    required this.userId,
    required this.name,
    required this.role,
    this.status = ParticipantStatus.connecting,
    required this.joinedAt,
    this.leftAt,
    this.audioEnabled = true,
    this.videoEnabled = true,
    this.deviceId,
  });

  factory CallParticipant.fromJson(Map<String, dynamic> json) {
    return CallParticipant(
      userId: json['userId'],
      name: json['name'],
      role: ParticipantRole.values.byName(json['role']),
      status: ParticipantStatus.values.byName(json['status']),
      joinedAt: DateTime.parse(json['joinedAt']),
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt']) : null,
      audioEnabled: json['audioEnabled'] ?? true,
      videoEnabled: json['videoEnabled'] ?? true,
      deviceId: json['deviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'role': role.name,
      'status': status.name,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'audioEnabled': audioEnabled,
      'videoEnabled': videoEnabled,
      'deviceId': deviceId,
    };
  }
}

class ChatMessage {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderName;
  final SenderRole senderRole;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? replyToMessageId;
  final List<MessageAttachment> attachments;
  final Map<String, dynamic> metadata;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.replyToMessageId,
    this.attachments = const [],
    this.metadata = const {},
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sessionId: json['sessionId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderRole: SenderRole.values.byName(json['senderRole']),
      content: json['content'],
      type: MessageType.values.byName(json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      status: MessageStatus.values.byName(json['status']),
      replyToMessageId: json['replyToMessageId'],
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => MessageAttachment.fromJson(a))
          .toList() ?? [],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole.name,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'replyToMessageId': replyToMessageId,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'metadata': metadata,
    };
  }
}

class MessageAttachment {
  final String id;
  final String fileName;
  final String fileUrl;
  final AttachmentType type;
  final int fileSize;
  final String? mimeType;
  final String? thumbnailUrl;

  MessageAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.type,
    required this.fileSize,
    this.mimeType,
    this.thumbnailUrl,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      type: AttachmentType.values.byName(json['type']),
      fileSize: json['fileSize'],
      mimeType: json['mimeType'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'type': type.name,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

class ChatSession {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final ChatSessionStatus status;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final List<ChatMessage> messages;
  final int unreadCount;
  final Map<String, dynamic> metadata;

  ChatSession({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    this.status = ChatSessionStatus.active,
    required this.createdAt,
    this.lastActivityAt,
    this.messages = const [],
    this.unreadCount = 0,
    this.metadata = const {},
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      appointmentId: json['appointmentId'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      status: ChatSessionStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      lastActivityAt: json['lastActivityAt'] != null 
          ? DateTime.parse(json['lastActivityAt']) : null,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => ChatMessage.fromJson(m))
          .toList() ?? [],
      unreadCount: json['unreadCount'] ?? 0,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'patientId': patientId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'unreadCount': unreadCount,
      'metadata': metadata,
    };
  }
}

enum CallType {
  audio,
  video,
}

enum CallStatus {
  initiated,
  ringing,
  connecting,
  connected,
  ended,
  failed,
  cancelled,
  missed,
}

enum ParticipantRole {
  doctor,
  patient,
  moderator,
}

enum ParticipantStatus {
  connecting,
  connected,
  disconnected,
  reconnecting,
}

enum MessageType {
  text,
  image,
  file,
  voice,
  system,
  prescription,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum SenderRole {
  doctor,
  patient,
  system,
}

enum AttachmentType {
  image,
  document,
  audio,
  video,
  prescription,
}

enum ChatSessionStatus {
  active,
  ended,
  archived,
}
