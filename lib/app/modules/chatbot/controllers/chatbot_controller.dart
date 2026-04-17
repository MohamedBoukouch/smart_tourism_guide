import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatbotController extends GetxController {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
  late final GenerativeModel _model;
  late final ChatSession _chat;

  final messages = <ChatMessage>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final isLoading = false.obs;

  bool get _hasValidApiKey {
    return apiKey.isNotEmpty &&
        !apiKey.contains('VotreVraieCleSansGuillemetsIci');
  }

  @override
  void onInit() {
    super.onInit();
    if (!_hasValidApiKey) {
      messages.add(
        ChatMessage(
          text:
              "Bonjour je suis votre assistant Ai, Comment je peux vous aidez.",
          isUser: false,
        ),
      );
      return;
    }
    // Initialize the Gemini model with specific instructions for tourism
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      systemInstruction: Content.system(
        '''Tu es un guide touristique virtuel nommé "Mini Girouette" pour l'application "Girouette". Ton but est de répondre aux questions des utilisateurs concernant notre application de balades historiques et insolites, de suggérer des lieux à visiter, de les aider à utiliser l'application, et de fournir des anecdotes culturelles intéressantes. Réponds en français de manière polie et concise. Évite de répondre à des sujets qui ne sont pas liés au tourisme, à l'histoire ou à l'application Girouette.''',
      ),
    );
    _chat = _model.startChat();

    // Initial welcome message
    messages.add(
      ChatMessage(
        text:
            "Bonjour ! Je suis l\'assistant Girouette. Comment puis-je vous aider à explorer la ville aujourd'hui ?",
        isUser: false,
      ),
    );
  }

  void sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    if (!_hasValidApiKey) {
      messages.add(
        ChatMessage(
          text:
              "Clé API Gemini manquante ou invalide. Ajoutez votre clé dans .env puis redémarrez l'application.",
          isUser: false,
        ),
      );
      return;
    }

    // Add user message
    messages.add(ChatMessage(text: text, isUser: true));
    textController.clear();
    _scrollToBottom();
    isLoading.value = true;

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        messages.add(ChatMessage(text: responseText.trim(), isUser: false));
      } else {
        messages.add(
          ChatMessage(
            text: "Désolé, je n'ai pas pu comprendre votre demande.",
            isUser: false,
          ),
        );
      }
    } catch (e) {
      messages.add(
        ChatMessage(
          text:
              "Une erreur est survenue lors de la communication. Veuillez réessayer.",
          isUser: false,
        ),
      );
      print(e);
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
