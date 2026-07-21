import '../../entities/chat_message.dart';
import '../../repositories/chatbot_repository.dart';

class EnviarMensajeUseCase {
  EnviarMensajeUseCase(this.repository);

  final ChatbotRepository repository;

  Future<ChatMessage> execute(String mensaje, Map<String, dynamic> contexto) {
    return repository.enviarMensaje(mensaje, contexto);
  }
}
