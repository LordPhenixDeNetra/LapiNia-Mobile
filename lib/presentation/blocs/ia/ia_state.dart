part of 'ia_bloc.dart';

abstract class IAState extends Equatable {
  const IAState();

  @override
  List<Object?> get props => [];
}

class IAInitial extends IAState {
  @override
  List<Object?> get props => [];
}

class IALoading extends IAState {
  final List<ChatMessage> messages;

  const IALoading({this.messages = const []});

  @override
  List<Object?> get props => [messages];
}

class IAMessagesLoaded extends IAState {
  final List<ChatMessage> messages;
  final bool isGenerating;

  const IAMessagesLoaded({
    required this.messages,
    this.isGenerating = false,
  });

  @override
  List<Object?> get props => [messages, isGenerating];
}

class DiagnosticLoaded extends IAState {
  final Map<String, dynamic> diagnostic;

  const DiagnosticLoaded({required this.diagnostic});

  @override
  List<Object?> get props => [diagnostic];
}

class RationLoaded extends IAState {
  final Map<String, dynamic> ration;

  const RationLoaded({required this.ration});

  @override
  List<Object?> get props => [ration];
}

class IAError extends IAState {
  final String message;

  const IAError({required this.message});

  @override
  List<Object?> get props => [message];
}
