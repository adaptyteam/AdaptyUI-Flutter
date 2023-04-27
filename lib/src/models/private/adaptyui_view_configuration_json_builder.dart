part of '../adaptyui_view_configuration.dart';

extension AdaptyUIViewConfigurationJSONBuilder on AdaptyUIViewConfiguration {
  dynamic get jsonValue => {
        _Keys.id: id,
        _Keys.templateId: templateId,
        _Keys.paywallId: paywallId,
        _Keys.paywallVariationId: paywallVariationId,
      };

  static AdaptyUIViewConfiguration fromJsonValue(Map<String, dynamic> json) {
    return AdaptyUIViewConfiguration._(
      json.string(_Keys.id),
      json.string(_Keys.templateId),
      json.string(_Keys.paywallId),
      json.string(_Keys.paywallVariationId),
    );
  }
}

class _Keys {
  static const id = 'id';
  static const templateId = 'template_id';
  static const paywallId = 'paywall_id';
  static const paywallVariationId = 'paywall_variation_id';
}
