import 'package:material_ui/material_ui.dart';

/// Data model representing an Expressive snack bar notification.
@immutable
class Snack {
  Snack({
    String? id,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 4),
    this.isError = false,
  }) : id = id ?? UniqueKey().toString();

  final String id;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final bool isError;

  bool matches(Snack other) {
    return message == other.message && icon == other.icon;
  }
}
