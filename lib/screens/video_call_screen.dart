/*
 * Dr. Saathi - Video Call Screen
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/communication.dart';
import '../services/communication_service.dart';
import '../widgets/chat_overlay.dart';

class VideoCallScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final CallType callType;

  const VideoCallScreen({
    super.key,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    this.callType = CallType.video,
  });

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final CommunicationService _communicationService = CommunicationService();
  CallSession? _currentCall;
  StreamSubscription<CallSession>? _callSubscription;
  
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isSpeakerOn = false;
  bool _isConnecting = true;
  bool _showChatOverlay = false;
  bool _isCallEnded = false;
  
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _setupCallListener();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _callSubscription?.cancel();
    super.dispose();
  }

  void _initializeCall() async {
    try {
      CallSession call;
      if (widget.callType == CallType.video) {
        call = await _communicationService.startVideoCall(
          appointmentId: widget.appointmentId,
          doctorId: widget.doctorId,
          patientId: widget.patientId,
        );
      } else {
        call = await _communicationService.startAudioCall(
          appointmentId: widget.appointmentId,
          doctorId: widget.doctorId,
          patientId: widget.patientId,
        );
      }
      
      setState(() {
        _currentCall = call;
        _isConnecting = false;
      });
      
      _startCallTimer();
    } catch (e) {
      _showErrorDialog('Failed to start call: $e');
    }
  }

  void _setupCallListener() {
    _callSubscription = _communicationService.callStream.listen((call) {
      if (!mounted || _isCallEnded) return;
      if (call.id == _currentCall?.id) {
        setState(() {
          _currentCall = call;
        });
        
        if (call.status == CallStatus.ended) {
          _endCall();
        }
      }
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCall?.startedAt != null) {
        setState(() {
          _callDuration = DateTime.now().difference(_currentCall!.startedAt!);
        });
      }
    });
  }

  void _toggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
    });
    
    if (_currentCall != null) {
      _communicationService.toggleAudio(_currentCall!.id, _isMicOn);
    }
    
    HapticFeedback.lightImpact();
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    
    if (_currentCall != null) {
      _communicationService.toggleVideo(_currentCall!.id, _isCameraOn);
    }
    
    HapticFeedback.lightImpact();
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    HapticFeedback.lightImpact();
  }

  void _endCall() {
    if (_isCallEnded) return;
    _isCallEnded = true;

    _callSubscription?.cancel();
    _callSubscription = null;
    _callTimer?.cancel();

    // Navigate away immediately so the user isn't stuck on the call screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        // If we can't pop (e.g. root route), replace with the previous screen
        navigator.pushReplacementNamed('/');
      }
    });

    // Mark the call as ended in the service without awaiting
    final callId = _currentCall?.id;
    if (callId != null) {
      Future.microtask(() {
        try {
          _communicationService.endCall(callId).catchError((_) {});
        } catch (_) {}
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video feed area
            _buildVideoArea(),
            
            // Top bar with call info
            _buildTopBar(),
            
            // Bottom controls
            _buildBottomControls(),
            
            // Connection status overlay
            if (_isConnecting) _buildConnectingOverlay(),
            
            // Chat overlay
            if (_showChatOverlay)
              ChatOverlay(
                appointmentId: widget.appointmentId,
                doctorId: widget.doctorId,
                patientId: widget.patientId,
                doctorName: widget.doctorName,
                patientName: widget.patientName,
                onClose: () {
                  setState(() {
                    _showChatOverlay = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: widget.callType == CallType.video
          ? Stack(
              children: [
                // Remote video (doctor's video)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[900],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.lightBlue[100],
                          child: Text(
                            widget.doctorName.split(' ').map((n) => n[0]).take(2).join(),
                            style: TextStyle(
                              color: Colors.lightBlue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.doctorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getCallStatusText(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Local video (patient's video) - small overlay
                if (_isCameraOn)
                  Positioned(
                    top: 80,
                    right: 20,
                    child: Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.lightBlue[100],
                                child: Text(
                                  widget.patientName.split(' ').map((n) => n[0]).take(2).join(),
                                  style: TextStyle(
                                    color: Colors.lightBlue[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : // Audio call UI
          Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.lightBlue[800]!,
                    Colors.lightBlue[900]!,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.doctorName.split(' ').map((n) => n[0]).take(2).join(),
                          style: TextStyle(
                            color: Colors.lightBlue[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      widget.doctorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getCallStatusText(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _endCall,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
            const Spacer(),
            Column(
              children: [
                Text(
                  _formatDuration(_callDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.callType == CallType.video ? 'Video Call' : 'Audio Call',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(width: 48), // Balance the back button
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mic toggle
            _buildControlButton(
              icon: _isMicOn ? Icons.mic : Icons.mic_off,
              isActive: _isMicOn,
              onPressed: _toggleMic,
              backgroundColor: _isMicOn ? Colors.white.withOpacity(0.2) : Colors.red,
            ),
            
            // Camera toggle (only for video calls)
            if (widget.callType == CallType.video)
              _buildControlButton(
                icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                isActive: _isCameraOn,
                onPressed: _toggleCamera,
                backgroundColor: _isCameraOn ? Colors.white.withOpacity(0.2) : Colors.red,
              ),
            
            // End call button
            _buildControlButton(
              icon: Icons.call_end,
              isActive: false,
              onPressed: _endCall,
              backgroundColor: Colors.red,
              size: 65,
            ),
            
            // Speaker toggle
            _buildControlButton(
              icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              isActive: _isSpeakerOn,
              onPressed: _toggleSpeaker,
              backgroundColor: _isSpeakerOn ? Colors.lightBlue : Colors.white.withOpacity(0.2),
            ),
            
            // Chat button
            _buildControlButton(
              icon: Icons.chat_bubble_outline,
              isActive: _showChatOverlay,
              onPressed: () {
                setState(() {
                  _showChatOverlay = !_showChatOverlay;
                });
                HapticFeedback.lightImpact();
              },
              backgroundColor: _showChatOverlay ? Colors.lightBlue : Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required Color backgroundColor,
    double size = 55,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.45,
        ),
      ),
    );
  }

  Widget _buildConnectingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
            ),
            SizedBox(height: 20),
            Text(
              'Connecting...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCallStatusText() {
    if (_isConnecting) return 'Connecting...';
    
    switch (_currentCall?.status) {
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.connected:
        return 'Connected';
      case CallStatus.ringing:
        return 'Ringing...';
      default:
        return 'In call';
    }
  }
}
