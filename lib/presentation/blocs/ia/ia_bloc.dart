import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'ia_event.dart';
part 'ia_state.dart';

class IABloc extends Bloc<IAEvent, IAState> {
  final SupabaseClient supabaseClient;
  static const bool _functionsEnabled = bool.fromEnvironment(
    'SUPABASE_FUNCTIONS_ENABLED',
    defaultValue: false,
  );

  IABloc({required this.supabaseClient}) : super(IAInitial()) {
    on<ChatMessageSent>(_onMessageSent);
    on<DiagnosticRequested>(_onDiagnosticRequested);
    on<RationCalculateRequested>(_onRationCalculate);
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<IAState> emit,
  ) async {
    final currentMessages = state is IAMessagesLoaded
        ? (state as IAMessagesLoaded).messages
        : state is IALoading
            ? (state as IALoading).messages
            : <ChatMessage>[];
    emit(IALoading(messages: currentMessages));
    try {
      final messages = [...currentMessages, event.message];
      emit(IAMessagesLoaded(messages: messages, isGenerating: true));

      if (!_functionsEnabled) {
        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              'Fonction IA non disponible (non deployee). Activez SUPABASE_FUNCTIONS_ENABLED=true une fois vos Edge Functions en place.',
          isFromUser: false,
          timestamp: DateTime.now(),
        );
        emit(IAMessagesLoaded(
          messages: [...messages, aiMessage],
          isGenerating: false,
        ));
        return;
      }
      
      final response = await supabaseClient.functions.invoke(
        'ai-router',
        body: {
          'action': 'complete',
          'prompt': event.message.content,
          'complexity': 'medium',
        },
      );
      
      final aiResponse = response.data['response'] as String? ?? 'Désolé, je ne peux pas répondre pour le moment.';
      
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse,
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      
      emit(IAMessagesLoaded(
        messages: [...messages, aiMessage],
        isGenerating: false,
      ));
    } catch (e) {
      final messages = [...currentMessages, event.message];
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'Fonction IA indisponible pour le moment (verifiez que les Edge Functions sont deployees et accessibles).',
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      emit(IAMessagesLoaded(messages: [...messages, aiMessage]));
    }
  }

  Future<void> _onDiagnosticRequested(
    DiagnosticRequested event,
    Emitter<IAState> emit,
  ) async {
    emit(IALoading());
    try {
      if (!_functionsEnabled) {
        emit(const IAError(
          message:
              'Diagnostic indisponible (fonction non deployee). Activez SUPABASE_FUNCTIONS_ENABLED=true une fois deploye.',
        ));
        return;
      }
      final response = await supabaseClient.functions.invoke(
        'diagnose-symptoms',
        body: {
          'lapinId': event.lapinId,
          'symptomes': event.symptomes,
          'userId': supabaseClient.auth.currentUser?.id,
        },
      );
      
      emit(DiagnosticLoaded(diagnostic: response.data));
    } catch (e) {
      emit(IAError(message: e.toString()));
    }
  }

  Future<void> _onRationCalculate(
    RationCalculateRequested event,
    Emitter<IAState> emit,
  ) async {
    emit(IALoading());
    try {
      if (!_functionsEnabled) {
        emit(const IAError(
          message:
              'Calcul de ration indisponible (fonction non deployee). Activez SUPABASE_FUNCTIONS_ENABLED=true une fois deploye.',
        ));
        return;
      }
      final response = await supabaseClient.functions.invoke(
        'calculate-ration',
        body: {
          'lapinId': event.lapinId,
          'poidsG': event.poidsG,
          'stade': event.stade,
          'temperature': event.temperature,
        },
      );
      
      emit(RationLoaded(ration: response.data));
    } catch (e) {
      emit(IAError(message: e.toString()));
    }
  }
}

class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
  });
}
