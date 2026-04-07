import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/chat_models.dart';
import '../mock/mock_data.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  Future<List<ChatThreadModel>> getThreads() async {
    try {
      final response = await _apiClient.get('/chats');
      if (response.data is! List) {
        return MockData.mockChatThreads.cast<ChatThreadModel>();
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => ChatThreadModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Не удалось загрузить чаты: $e. Используем mock-данные');
      return MockData.mockChatThreads.cast<ChatThreadModel>();
    }
  }

  Future<List<ChatMessageModel>> getMessages(String chatId) async {
    try {
      final response = await _apiClient.get('/chats/$chatId/messages');
      if (response.data is! List) {
        return (MockData.mockChatMessagesByThread[chatId] ?? [])
            .cast<ChatMessageModel>();
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => ChatMessageModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Не удалось загрузить сообщения: $e. Используем mock-данные');
      return (MockData.mockChatMessagesByThread[chatId] ?? [])
          .cast<ChatMessageModel>();
    }
  }

  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post(
        '/chats/$chatId/messages',
        data: {'content': content},
      );
      return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Не удалось отправить сообщение: $e. Используем mock-данные');
      final created = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: 'user-001',
        sender: 'Вы',
        content: content,
        isMine: true,
        createdAt: DateTime.now(),
      );
      final list = MockData.mockChatMessagesByThread[chatId] ?? [];
      MockData.mockChatMessagesByThread[chatId] = [...list, created];
      return created;
    }
  }
}
