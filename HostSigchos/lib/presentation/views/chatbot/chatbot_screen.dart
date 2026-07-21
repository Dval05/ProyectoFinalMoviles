import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../themes/esquema_color.dart';
import '../../routes/app_routes.dart';
import '../../viewmodels/chatbot_viewmodel.dart';
import '../../viewmodels/habitacion_viewmodel.dart';
import '../../viewmodels/hosteria_viewmodel.dart';
import '../../viewmodels/locale_viewmodel.dart';
import '../../widgets/audio_visualizer.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  double _currentDecibels = -160;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitacionViewModel>().cargarTodasLasHabitaciones();
      final l10n = AppLocalizations.of(context)!;
      final localeVm = context.read<LocaleViewModel>();
      context.read<ChatbotViewModel>().updateLanguage(
            localeVm.locale.languageCode,
            l10n.chatbotWelcome,
          );
    });
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
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

    final habitacionVm = context.read<HabitacionViewModel>();
    final habitaciones = habitacionVm.todasLasHabitaciones
        .map(
          (h) => {
            'id': h.id,
            'hosteriaId': h.hosteriaId,
            'tipo': h.tipo,
            'precio': h.precioPorNoche,
            'capacidad': h.capacidad,
          },
        )
        .toList();

    return {
      'hosterias_disponibles': hosterias,
      'habitaciones_disponibles': habitaciones,
      'idioma': context.read<LocaleViewModel>().locale.languageCode,
    };
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/audio_msg_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);

      _amplitudeSubscription = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amplitude) {
        if (mounted) {
          setState(() {
            _currentDecibels = amplitude.current;
          });
        }
      });

      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    _amplitudeSubscription?.cancel();
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
    });

    if ( path != null) {
      context.read<ChatbotViewModel>().sendAudioMessage(
        path, 
        contexto: _buildContexto(), 
        voiceMessageLabel: AppLocalizations.of(context)!.voiceMessage,
      );
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
    } else if (action == 'SHOW_SUGGESTIONS') {
      final suggestions = data?['suggestions'] as List<dynamic>? ?? [];
      Navigator.pushNamed(
        context,
        AppRoutes.chatbotSuggestions,
        arguments: suggestions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatbotVm = context.watch<ChatbotViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ColorSchemeApp.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.virtualAssistant,
          style: const TextStyle(color: ColorSchemeApp.darkText, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              chatbotVm.isAudioEnabled ? Icons.volume_up : Icons.volume_off,
              color: ColorSchemeApp.darkText,
            ),
            onPressed: chatbotVm.toggleAudio,
          ),
        ],
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: ColorSchemeApp.pearlWhite,
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
                            child: Text(AppLocalizations.of(context)!.viewSuggestion),
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
                    child: _isRecording
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: AudioVisualizer(decibels: _currentDecibels),
                          )
                        : TextField(
                              controller: _textController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.typeMessage,
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
