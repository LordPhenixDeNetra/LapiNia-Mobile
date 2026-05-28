import 'package:equatable/equatable.dart';

class DashboardTimelineEvent extends Equatable {
  final DateTime date;
  final String? primary;
  final String? secondary;
  final String? route;
  final String type;

  const DashboardTimelineEvent({
    required this.date,
    this.primary,
    this.secondary,
    this.route,
    required this.type,
  });

  @override
  List<Object?> get props => [date, primary, secondary, route, type];
}
