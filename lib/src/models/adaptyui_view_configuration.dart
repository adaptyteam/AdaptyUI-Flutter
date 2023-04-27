import 'package:adapty_ui_flutter/src/models/private/json_builder.dart';
import 'package:meta/meta.dart' show immutable;

part 'private/adaptyui_view_configuration_json_builder.dart';

@immutable
class AdaptyUIViewConfiguration {
  final String id;
  final String templateId;
  final String paywallId;
  final String paywallVariationId;

  const AdaptyUIViewConfiguration._(
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
}
