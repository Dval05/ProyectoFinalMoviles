import '../../entities/chat_message.dart';
import '../../repositories/chatbot_repository.dart';

class EnviarAudioUseCase {
  EnviarAudioUseCase(this.repository);

  final ChatbotRepository repository;

  Future<ChatMessage> execute(String filePath, Map<String, dynamic> contexto) {
    return repository.enviarAudio(filePath, contexto);
  }
}
