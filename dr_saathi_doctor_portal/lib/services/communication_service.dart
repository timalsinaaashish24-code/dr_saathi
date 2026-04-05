/*
 * Dr. Saathi - Communication Service
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/communication.dart';

class CommunicationService {
  static final CommunicationService _instance = CommunicationService._internal();
  factory CommunicationService() => _instance;
  CommunicationService._internal();

  // Stream controllers for real-time communication
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  final StreamController<CallSession> _callController = StreamController<CallSession>.broadcast();
  
  // In-memory storage for demo purposes (replace with actual backend)
  final Map<String, CallSession> _activeCalls = {};
  final Map<String, ChatSession> _chatSessions = {};
  final Map<String, List<ChatMessage>> _messages = {};

  /// Start a video call session
  Future<CallSession> startVideoCall({
    required String appointmentId,
    required String doctorId,
    required String patientId,
  }) async {
    final roomId = 'room_${const Uuid().v4()}';
    final callSession = CallSession(
      id: const Uuid().v4(),
      appointmentId: appointmentId,
      doctorId: doctorId,
      patientId: patientId,
      type: CallType.video,
      status: CallStatus.initiated,
      createdAt: DateTime.now(),
      roomId: roomId,
    );

    _activeCalls[callSession.id] = callSession;
    _callController.add(callSession);
    
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));
    final connectedCall = callSession.copyWith(
      status: CallStatus.connecting,
      startedAt: DateTime.now(),
    );
    
    _activeCalls[callSession.id] = connectedCall;
    _callController.add(connectedCall);

    return connectedCall;
  }

  /// Start an audio call session
  Future<CallSession> startAudioCall({
    required String appointmentId,
    required String doctorId,
    required String patientId,
  }) async {
    final roomId = 'room_${const Uuid().v4()}';
    final callSession = CallSession(
      id: const Uuid().v4(),
      appointmentId: appointmentId,
      doctorId: doctorId,
      patientId: patientId,
      type: CallType.audio,
      status: CallStatus.initiated,
      createdAt: DateTime.now(),
      roomId: roomId,
    );

    _activeCalls[callSession.id] = callSession;
    _callController.add(callSession);
    
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));
    final connectedCall = callSession.copyWith(
      status: CallStatus.connecting,
      startedAt: DateTime.now(),
    );
    
    _activeCalls[callSession.id] = connectedCall;
    _callController.add(connectedCall);

    return connectedCall;
  }

  /// Send a chat message in a session
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required SenderRole senderRole,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final message = ChatMessage(
      id: const Uuid().v4(),
      sessionId: sessionId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    // Store message
    if (!_messages.containsKey(sessionId)) {
      _messages[sessionId] = [];
    }
    _messages[sessionId]!.add(message);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final sentMessage = ChatMessage(
      id: message.id,
      sessionId: message.sessionId,
      senderId: message.senderId,
      senderName: message.senderName,
      senderRole: message.senderRole,
      content: message.content,
      type: message.type,
      timestamp: message.timestamp,
      status: MessageStatus.sent,
    );
    
    // Update stored message
    final index = _messages[sessionId]!.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages[sessionId]![index] = sentMessage;
    }
    
    _messageController.add(sentMessage);
    return sentMessage;
  }

  /// Create a new chat session
  Future<ChatSession> createChatSession({
    required String appointmentId,
    required String doctorId,
    required String patientId,
  }) async {
    final session = ChatSession(
      id: const Uuid().v4(),
      appointmentId: appointmentId,
      doctorId: doctorId,
      patientId: patientId,
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    
    _chatSessions[session.id] = session;
    return session;
  }
  
  /// Get messages for a chat session
  List<ChatMessage> getMessages(String sessionId) {
    return _messages[sessionId] ?? [];
  }
  
  /// Get chat session by ID
  ChatSession? getChatSession(String sessionId) {
    return _chatSessions[sessionId];
  }
  
  /// Get active call session
  CallSession? getActiveCall(String callId) {
    return _activeCalls[callId];
  }
  
  /// End a call session
  Future<CallSession> endCall(String callId) async {
    final call = _activeCalls[callId];
    if (call != null) {
      final endedCall = call.copyWith(
        status: CallStatus.ended,
        endedAt: DateTime.now(),
        duration: call.startedAt != null 
            ? DateTime.now().difference(call.startedAt!) 
            : null,
      );
      
      _activeCalls[callId] = endedCall;
      _callController.add(endedCall);
      return endedCall;
    }
    throw Exception('Call not found');
  }
  
  /// Stream of chat messages
  Stream<ChatMessage> get messageStream => _messageController.stream;
  
  /// Stream of call updates
  Stream<CallSession> get callStream => _callController.stream;
  
  /// Toggle audio in call
  Future<void> toggleAudio(String callId, bool enabled) async {
    final call = _activeCalls[callId];
    if (call != null) {
      // Update call metadata
      final metadata = Map<String, dynamic>.from(call.metadata);
      metadata['audioEnabled'] = enabled;
      
      final updatedCall = call.copyWith(metadata: metadata);
      _activeCalls[callId] = updatedCall;
      _callController.add(updatedCall);
    }
  }
  
  /// Toggle video in call
  Future<void> toggleVideo(String callId, bool enabled) async {
    final call = _activeCalls[callId];
    if (call != null) {
      // Update call metadata
      final metadata = Map<String, dynamic>.from(call.metadata);
      metadata['videoEnabled'] = enabled;
      
      final updatedCall = call.copyWith(metadata: metadata);
      _activeCalls[callId] = updatedCall;
      _callController.add(updatedCall);
    }
  }
  
  /// Dispose resources
  void dispose() {
    _messageController.close();
    _callController.close();
  }
}

