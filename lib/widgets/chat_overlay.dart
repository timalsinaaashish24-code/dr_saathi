/*
 * Dr. Saathi - Chat Overlay Widget
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/communication.dart';
import '../services/communication_service.dart';

class ChatOverlay extends StatefulWidget {
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final VoidCallback onClose;

  const ChatOverlay({
    super.key,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    required this.onClose,
  });

  @override
  _ChatOverlayState createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  final CommunicationService _communicationService = CommunicationService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  ChatSession? _chatSession;
  List<ChatMessage> _messages = [];
  StreamSubscription<ChatMessage>? _messageSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _setupMessageListener();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() async {
    try {
      // Create or get existing chat session
      final session = await _communicationService.createChatSession(
        appointmentId: widget.appointmentId,
        doctorId: widget.doctorId,
        patientId: widget.patientId,
      );
      
      setState(() {
        _chatSession = session;
        _messages = _communicationService.getMessages(session.id);
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to initialize chat: $e');
    }
  }

  void _setupMessageListener() {
    _messageSubscription = _communicationService.messageStream.listen((message) {
      if (_chatSession != null && message.sessionId == _chatSession!.id) {
        setState(() {
          final existingIndex = _messages.indexWhere((m) => m.id == message.id);
          if (existingIndex != -1) {
            _messages[existingIndex] = message;
          } else {
            _messages.add(message);
          }
        });
        _scrollToBottom();
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatSession == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      await _communicationService.sendMessage(
        sessionId: _chatSession!.id,
        senderId: widget.patientId,
        senderName: widget.patientName,
        senderRole: SenderRole.patient,
        content: content,
      );
      
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar('Failed to send message: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMessagesList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[800],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Text(
              widget.doctorName.split(' ').map((n) => n[0]).take(2).join(),
              style: TextStyle(
                color: Colors.lightBlue[800],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat with ${widget.doctorName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'During consultation',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with ${widget.doctorName}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[900],
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isPatient = message.senderRole == SenderRole.patient;
          
          return _buildMessageBubble(message, isPatient);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isPatient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isPatient ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isPatient) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.lightBlue[100],
              child: Text(
                message.senderName.split(' ').map((n) => n[0]).take(2).join(),
                style: TextStyle(
                  color: Colors.lightBlue[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isPatient ? Colors.lightBlue[600] : Colors.grey[700],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      if (isPatient) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.sent
                              ? Icons.done
                              : message.status == MessageStatus.delivered
                                  ? Icons.done_all
                                  : Icons.access_time,
                          size: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isPatient) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green[100],
              child: Text(
                message.senderName.split(' ').map((n) => n[0]).take(2).join(),
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.lightBlue[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
