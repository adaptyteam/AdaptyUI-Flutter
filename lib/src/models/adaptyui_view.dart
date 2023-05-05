import 'package:adapty_flutter/src/models/private/json_builder.dart';
import 'package:meta/meta.dart' show immutable;

import '../adaptyui.dart';

part 'private/adaptyui_view_json_builder.dart';

@immutable
class AdaptyUIView {
  final String id;
  final String templateId;
  final String paywallId;
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

  Future<void> present() => AdaptyUI().presentPaywallView(this);

  Future<void> dismiss() => AdaptyUI().dismissPaywallView(this);
}
