import 'package:equatable/equatable.dart';

enum ConsanguinityLevel {
  ok,
  warn,
  block,
  unknown;

  static ConsanguinityLevel fromApiValue(String value) {
    switch (value) {
      case 'OK':
        return ConsanguinityLevel.ok;
      case 'WARN':
        return ConsanguinityLevel.warn;
      case 'BLOCK':
        return ConsanguinityLevel.block;
      case 'UNKNOWN':
        return ConsanguinityLevel.unknown;
    }
    return ConsanguinityLevel.unknown;
  }
}

class ConsanguinityResult extends Equatable {
  final double f;
  final ConsanguinityLevel level;
  final List<String> commonAncestors;

  const ConsanguinityResult({
    required this.f,
    required this.level,
    required this.commonAncestors,
  });

  factory ConsanguinityResult.fromJson(Map<String, dynamic> json) {
    return ConsanguinityResult(
      f: (json['f'] as num?)?.toDouble() ?? 0,
      level: ConsanguinityLevel.fromApiValue((json['level'] as String?) ?? 'UNKNOWN'),
      commonAncestors: (json['commonAncestors'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [f, level, commonAncestors];
}

