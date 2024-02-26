import 'package:adapty_flutter/src/models/private/json_builder.dart';
import 'package:meta/meta.dart' show immutable;

import '../adaptyui.dart';
import 'adaptyui_dialog.dart';

part 'private/adaptyui_view_json_builder.dart';

@immutable
class AdaptyUIView {
  /// The unique identifier of the view.
  final String id;

  /// The template identifier, which will be rendered.
  final String templateId;

  /// The identifier of paywall.
  final String paywallId;

  /// The identifier of paywall variation.
  final String paywallVariationId;

  const AdaptyUIView._(
    this.id,
    this.templateId,
    this.paywallId,
    this.paywallVariationId,
  );

  @override
  String toString() => '(id: $id, '
      'id: $id, '
      'templateId: $templateId, '
      'paywallId: $paywallId, '
      'paywallVariationId: $paywallVariationId';

  /// Call this function if you wish to present the view.
  Future<void> present() => AdaptyUI().presentPaywallView(this);

  /// Call this function if you wish to dismiss the view.
  Future<void> dismiss() => AdaptyUI().dismissPaywallView(this);

  /// Call this function if you wish to present the dialog.
  ///
  /// **Parameters**
  /// - [dialog]: an [AdaptyUIDialog] object, description of the desired dialog.
  Future<void> showDialog(AdaptyUIDialog dialog) => AdaptyUI().showDialog(this, dialog);
}
