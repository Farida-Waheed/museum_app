import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = []; // {text: String, isUser: bool}
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initial greeting
    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage("Hello! I am your AI Guide. Ask me anything about the museum!", false);
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _controller.clear();
    _addMessage(text, true);
    setState(() => _isTyping = true);

    // Simulate AI thinking delay
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (mounted) {
        setState(() => _isTyping = false);
        _addMessage(_getRobotResponse(text), false);
      }
    });
  }

  // Simple AI Logic (Mock)
  String _getRobotResponse(String input) {
    final lowerInput = input.toLowerCase();
    if (lowerInput.contains("toilet") || lowerInput.contains("bathroom")) {
      return "Restrooms are located on the Ground Floor, near the main entrance.";
    } else if (lowerInput.contains("time") || lowerInput.contains("open")) {
      return "The museum is open daily from 9:00 AM to 6:00 PM.";
    } else if (lowerInput.contains("ticket") || lowerInput.contains("price")) {
      return "Tickets are \$15 for adults and free for children under 12.";
    } else if (lowerInput.contains("cafe") || lowerInput.contains("food")) {
      return "The Museum Cafe is on the 2nd floor offering snacks and coffee.";
    } else if (lowerInput.contains("map")) {
      return "You can access the Digital Map from the Home screen to navigate.";
    }
    return "I'm not sure about that. Try asking about tickets, restrooms, or opening hours!";
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add({"text": text, "isUser": isUser});
    });
    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask Robot"),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'];
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isUser ? Radius.zero : null,
                        bottomLeft: !isUser ? Radius.zero : null,
                      ),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Typing Indicator
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Robot is typing...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: isArabic ? "اكتب سؤالك..." : "Type your question...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _handleSubmitted(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}