import 'package:adapty_flutter/src/models/private/json_builder.dart';
import 'package:meta/meta.dart' show immutable;

part 'private/adaptyui_dialog_json_builder.dart';

@immutable
class AdaptyUIDialogAction {
  final String title;
  final void Function() onPressed;

  const AdaptyUIDialogAction({
    required this.title,
    required this.onPressed,
  });
}

@immutable
class AdaptyUIDialog {
  final String? title;
  final String? content;

  final AdaptyUIDialogAction defaultAction;
  final AdaptyUIDialogAction? secondaryAction;

  const AdaptyUIDialog({
    this.title,
    this.content,
    required this.defaultAction,
    this.secondaryAction,
  });
}
