import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;

  // Define users
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
        "https://logowik.com/content/uploads/images/google-ai-gemini91216.logowik.com.webp",
  );

  // Chat messages list
  List<ChatMessage> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gemini Chat"),
      ),
      body: DashChat(
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages,
      ),
    );
  }

  // Handle sending messages
  void _sendMessage(ChatMessage chatMessage) {
    debugPrint("User sent: ${chatMessage.text}");

    // Add user's message
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      String question = chatMessage.text;

      // Create an empty AI message first
      ChatMessage aiMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: "",
      );

      setState(() {
        messages = [aiMessage, ...messages]; // Show Gemini's message first
      });

      // Stream Gemini AI response
      gemini.promptStream(parts: [Part.text(question)]).listen((event) {
        if (event!.content != null && event.content!.parts != null) {
          // Extract text from response parts
          String response = event.content!.parts!
              .whereType<TextPart>() // Get only TextPart
              .map((part) => part.text) // Extract text
              .join(" "); // Join into a single string

          debugPrint("Gemini responded: $response");

          // Update the existing AI message instead of adding a new one
          setState(() {
            aiMessage.text += response;
          });
        }
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}
