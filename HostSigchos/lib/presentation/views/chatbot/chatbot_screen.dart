import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/chatbot_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void dispose() {
    _audioRecorder.dispose();
    _textController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildContexto() {
    final hosteriaVm = context.read<HosteriaViewModel>();
    final hosterias = hosteriaVm.todasHosterias
        .map(
          (h) => {
            'id': h.id,
            'nombre': h.nombre,
            'direccion': h.direccion,
            'precioPromedio': h.precioPorNoche,
            'latitud': h.latitud,
            'longitud': h.longitud,
            'rating': h.rating,
          },
        )
        .toList();

    return {
      'hosterias_disponibles': hosterias,
    };
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/audio_msg_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
    });

    if ( path != null) {
      context.read<ChatbotViewModel>().sendAudioMessage(path, contexto: _buildContexto());
    }
  }

  void _handleAction(
    BuildContext context,
    String action,
    Map<String, dynamic>? data,
  ) {
    if (action == 'NAVIGATE_TO_ROOMS') {
      final hosteriaId = data?['hosteriaId'];
      Navigator.pushNamed(
        context,
        AppRoutes.habitaciones,
        arguments: hosteriaId,
      );
    } else if (action == 'NAVIGATE_TO_HOSTERIAS') {
      Navigator.pushNamed(context, AppRoutes.hosteriasList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatbotVm = context.watch<ChatbotViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Virtual'),
        backgroundColor: ColorSchemeApp.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Para que el último mensaje aparezca abajo
              padding: const EdgeInsets.all(16),
              itemCount: chatbotVm.messages.length,
              itemBuilder: (context, index) {
                final msg = chatbotVm.messages[index];
                final bool isUser = msg.isUser;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? ColorSchemeApp.primaryGreen
                          : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: isUser
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        if (msg.action != null) ...[
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _handleAction(
                              context,
                              msg.action!,
                              msg.actionData,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: ColorSchemeApp.primaryGreen,
                            ),
                            child: const Text('Ver Sugerencia'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (chatbotVm.isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                color: ColorSchemeApp.primaryGreen,
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onSubmitted: (val) {
                        chatbotVm.sendMessage(val, contexto: _buildContexto());
                        _textController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: _isRecording
                        ? Colors.red
                        : Colors.grey[200],
                    child: IconButton(
                      icon: Icon(
                        _isRecording ? Icons.mic : Icons.mic_none,
                        color: _isRecording ? Colors.white : Colors.black87,
                      ),
                      onPressed: _isRecording
                          ? _stopRecording
                          : _startRecording,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: ColorSchemeApp.primaryGreen,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          chatbotVm.sendMessage(_textController.text);
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
