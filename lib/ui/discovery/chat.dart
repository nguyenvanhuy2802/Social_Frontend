import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  final String friend;

  const ChatScreen({super.key, required this.friend});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Map<String, dynamic>>> _messages;
  late String currentUsername;
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  String _audioPath = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
    _messages = fetchMessages();
    _audioRecorder.openRecorder();
    _audioPlayer.openPlayer();
  }

  Future<void> _loadCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('username') ?? '';
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages = prefs.getStringList(widget.friend);
    if (savedMessages == null) {
      return [];
    } else {
      return savedMessages.map((msg) => Map<String, dynamic>.from(jsonDecode(msg))).toList();
    }
  }

  void _startRecording() async {
    // Request permission before starting the recorder
    PermissionStatus status = await Permission.microphone.request();

    if (status.isGranted) {
      final tempDir = await getTemporaryDirectory();
      _audioPath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder.startRecorder(toFile: _audioPath);

      setState(() {
        _isListening = true;
      });
    } else {
      // If permission is denied, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access microphone is required.')),
      );
    }
  }

  void _stopRecording() async {
    await _audioRecorder.stopRecorder();
    setState(() {
      _isListening = false;
    });

    _sendVoiceMessage();

    // After stopping, try to play the recorded file
    _playRecordedAudio();
  }

  void _sendVoiceMessage() async {
    if (_audioPath.isNotEmpty) {
      try {
        final newMessage = {
          'sender': currentUsername,
          'message': 'Voice message',
          'audio': _audioPath,
        };

        final prefs = await SharedPreferences.getInstance();
        List<String> currentMessages = prefs.getStringList(widget.friend) ?? [];
        currentMessages.add(jsonEncode(newMessage));
        await prefs.setStringList(widget.friend, currentMessages);

        setState(() {
          _messages = fetchMessages();
        });

        _audioPath = '';
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _playRecordedAudio() async {
    if (_audioPath.isNotEmpty) {
      try {
        // Check if player is not already playing
        if (_audioPlayer.isPlaying) {
          await _audioPlayer.stopPlayer();
        }

        // Start playing the audio file
        await _audioPlayer.startPlayer(
          fromURI: _audioPath,
          whenFinished: () {
            setState(() {});
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      }
    }
  }

  void _clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(widget.friend);

    setState(() {
      _messages = fetchMessages();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All messages cleared')));
  }

  void _confirmClearMessages() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete all messages?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _clearMessages(); // Proceed to delete all messages
    }
  }

  @override
  void dispose() {
    super.dispose();
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.friend}'),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _confirmClearMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(  // Display messages
              future: _messages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                } else {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser = message['sender'] == currentUsername;
                      return Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,  // Align messages
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20), // Keep rounded corners
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Limit the size of the Row
                            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start, // Adjust message alignment
                            children: [
                              message['audio'] != null
                                  ? IconButton(
                                icon: Icon(Icons.play_arrow, color: isCurrentUser ? Colors.white : Colors.black),
                                onPressed: () {
                                  _audioPath = message['audio'];
                                  _playRecordedAudio();
                                },
                              )
                                  : Text(
                                message['message']!,
                                style: TextStyle(
                                  color: isCurrentUser ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.stop : Icons.mic),
                  onPressed: _isListening ? _stopRecording : _startRecording,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      try {
        final newMessage = {
          'sender': currentUsername,
          'message': _controller.text,
        };

        final prefs = await SharedPreferences.getInstance();
        List<String> currentMessages = prefs.getStringList(widget.friend) ?? [];
        currentMessages.add(jsonEncode(newMessage));
        await prefs.setStringList(widget.friend, currentMessages);

        setState(() {
          _messages = fetchMessages();
        });

        _controller.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
