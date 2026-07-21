import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/env.dart';

class ChatbotDataSource {
  static const String _systemPrompt = r'''
Eres un asistente virtual inteligente y amigable para la aplicación 'HostSigchos', una app de reserva de hosterías en el cantón Sigchos, Ecuador.
Tu objetivo es ayudar a los usuarios a encontrar habitaciones, dar sugerencias y resolver dudas.

REGLAS DE NEGOCIO (Debes respetarlas y mencionarlas si el usuario pregunta):
- Capacidad Máxima por Reserva: 8 huéspedes.
- Estadía Máxima: 30 noches.
- Horarios: Check-In a las 14:00 (2:00 PM), Check-Out a las 12:00 PM.
- Moneda de Operación: Dólares Estadounidenses (USD, $).
- Ubicación Base: Sigchos (Latitud: -0.7033, Longitud: -78.8878).

REGLAS IMPORTANTES DEL SISTEMA:
1. SIEMPRE responde en formato JSON válido. 
2. El JSON debe tener exactamente esta estructura:
{
    "text": "Tu respuesta amigable al usuario (DEBES mencionar el nombre de la hostería si estás haciendo una sugerencia)",
    "action": "SHOW_SUGGESTIONS" (opcional, usa null si no aplica),
    "action_data": {
      "suggestions": [
        {
          "hosteriaId": "id_de_la_hosteria_aqui",
          "hosteriaNombre": "Nombre de la Hostería",
          "habitaciones": [
            {"id": "id_de_la_habitacion", "tipo": "Suite", "precio": 50}
          ]
        }
      ]
    } (opcional, usa null si no aplica)
}
3. Las acciones permitidas en `action` son:
    - "SHOW_SUGGESTIONS": Cuando recomiendas revisar una lista de habitaciones o sugerencias de una o varias hosterías. DEBES incluir "suggestions" en "action_data" agrupadas por hostería con las habitaciones específicas que sugieres, basándote en la lista "habitaciones_disponibles" del contexto.
    - "NAVIGATE_TO_HOSTERIAS": Cuando recomiendas revisar la lista general de hosterías.
4. MUY IMPORTANTE: Debes responder en el mismo idioma en el que el usuario te está hablando (español, inglés, etc.).
5. Si el usuario te da fechas en el contexto, úsalas para recomendar.
6. Mantén tus respuestas concisas y amables.
''';

  Future<Map<String, dynamic>> enviarMensaje(
    String mensaje,
    Map<String, dynamic> contexto, {
    bool isAudioText = false,
  }) async {
    final apiKey = Env.groqApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Falta GROQ_API_KEY en el .env');
    }

    final idiomaApp = contexto['idioma'] == 'en' ? 'INGLÉS (ENGLISH)' : 'ESPAÑOL (SPANISH)';
    final contextStr = jsonEncode(contexto);
    final userMessage = isAudioText
        ? 'Contexto actual del usuario: $contextStr\n\nMensaje del usuario (transcrito de un audio): $mensaje'
        : 'Contexto actual del usuario: $contextStr\n\nMensaje del usuario: $mensaje';

    final promptConIdioma = '$_systemPrompt\n\nMUY IMPORTANTE: EL IDIOMA ACTUAL DE LA APP ES $idiomaApp. DEBES RESPONDER ESTRICTAMENTE EN ESE IDIOMA.';

    final response = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'llama-3.3-70b-versatile',
            'messages': [
              {'role': 'system', 'content': promptConIdioma},
              {'role': 'user', 'content': userMessage},
            ],
            'temperature': 0.5,
            'response_format': {'type': 'json_object'},
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final jsonResponseStr = data['choices'][0]['message']['content'];
      return jsonDecode(jsonResponseStr);
    } else {
      throw Exception(
        'Error Groq Chat: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> enviarAudio(
    String filePath,
    Map<String, dynamic> contexto,
  ) async {
    final apiKey = Env.groqApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Falta GROQ_API_KEY en el .env');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions'),
    );
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = 'whisper-large-v3';
    request.fields['response_format'] = 'json';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      String transcribedText = data['text'] ?? '';
      if (transcribedText.trim().isEmpty) {
        transcribedText = '(Audio ininteligible o vacío)';
      }
      return enviarMensaje(transcribedText, contexto, isAudioText: true);
    } else {
      throw Exception(
        'Error Groq Whisper: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
