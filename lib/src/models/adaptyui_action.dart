import 'package:adapty_flutter/src/models/private/json_builder.dart';
import 'package:meta/meta.dart' show immutable;

part 'private/adaptyui_action_json_builder.dart';

enum AdaptyUIActionType { close, openUrl, custom, androidSystemBack }

@immutable
class AdaptyUIAction {
  /// The unique identifier of the view.
  final AdaptyUIActionType type;
  final String? value;

  const AdaptyUIAction(this.type, this.value);
}
