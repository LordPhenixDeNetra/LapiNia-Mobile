part of 'ia_bloc.dart';

abstract class IAEvent extends Equatable {
  const IAEvent();

  @override
  List<Object?> get props => [];
}

class ChatMessageSent extends IAEvent {
  final ChatMessage message;

  const ChatMessageSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class DiagnosticRequested extends IAEvent {
  final String lapinId;
  final List<String> symptomes;

  const DiagnosticRequested({
    required this.lapinId,
    required this.symptomes,
  });

  @override
  List<Object?> get props => [lapinId, symptomes];
}

class RationCalculateRequested extends IAEvent {
  final String lapinId;
  final int poidsG;
  final String stade;
  final int temperature;

  const RationCalculateRequested({
    required this.lapinId,
    required this.poidsG,
    required this.stade,
    this.temperature = 30,
  });

  @override
  List<Object?> get props => [lapinId, poidsG, stade, temperature];
}
