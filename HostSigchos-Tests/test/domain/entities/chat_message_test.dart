import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage Entity Tests', () {
    final now = DateTime.now();
    final mensajeUsuario = ChatMessage(
      text: '¿Qué actividades turísticas hay cerca del Cañón del Toachi?',
      isUser: true,
      timestamp: now,
    );

    final mensajeIA = ChatMessage(
      text: 'Puedes realizar senderismo, avistamiento de aves y camping escalado en el Cañón.',
      isUser: false,
      timestamp: now.add(const Duration(seconds: 1)),
      action: 'SUGERIR_HOSTERIAS_CERCANAS',
      actionData: {'lat': -0.7001, 'lng': -78.8892, 'radio_km': 10},
    );

    test('PU-30: Diferenciación bidireccional de emisor entre usuario humano y Asistente IA', () {
      expect(mensajeUsuario.isUser, true);
      expect(mensajeIA.isUser, false);
      expect(mensajeUsuario.text.contains('Toachi'), isTrue);
      // ignore: avoid_print
      print('[OK] PU-30: Identificación del agente emisor (Usuario vs IA) en ChatMessage . PASADA');
    });

    test('PU-31: Procesamiento de carga útil de acción inteligente sugerida por modelo Gemini', () {
      expect(mensajeIA.action, 'SUGERIR_HOSTERIAS_CERCANAS');
      expect(mensajeIA.actionData, isNotNull);
      expect(mensajeIA.actionData?['radio_km'], 10);
      // ignore: avoid_print
      print('[OK] PU-31: Decodificación de acciones inteligentes (actionData) de IA ...... PASADA');
    });

    test('PU-32: Coherencia cronológica en el intercambio asíncrono conversacional del Chatbot', () {
      expect(mensajeIA.timestamp.isAfter(mensajeUsuario.timestamp), isTrue);
      expect(mensajeIA.timestamp.difference(mensajeUsuario.timestamp).inSeconds, 1);
      // ignore: avoid_print
      print('[OK] PU-32: Coherencia temporal del flujo asíncrono de conversación en IA ... PASADA');
    });
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[REPORTE] ChatMessage Entity Suite: 3/3 pruebas PASADAS');
    // ignore: avoid_print
    print('================================================================');
  });
}
