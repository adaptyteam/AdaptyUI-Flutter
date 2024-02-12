import 'package:adapty_flutter/src/models/private/json_builder.dart';
import 'package:meta/meta.dart' show immutable;

part 'private/adaptyui_dialog_json_builder.dart';

enum AdaptyUIDialogActionStyle { standard, cancel, destructive }

@immutable
class AdaptyUIDialogAction {
  final String title;
  final AdaptyUIDialogActionStyle style;

  const AdaptyUIDialogAction({
    required this.title,
    required this.style,
  });
}

@immutable
class AdaptyUIDialog {
  final String? title;
  final String? message;
  final List<AdaptyUIDialogAction>? actions;

  const AdaptyUIDialog({
    this.title,
    this.message,
    this.actions,
  });
}
