//
//  adapty_error_json_builder.dart
//  Adapty
//
//  Created by Aleksei Valiano on 25.11.2022.
//

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:adapty_ui_flutter/src/models/private/json_builder.dart';

import '../adaptyui_sdk_native.dart';

extension AdaptyUIErrorJSONBuilder on AdaptyError {
  static AdaptyError fromJsonValue(Map<String, dynamic> json) {
    return AdaptyError(
      json.string(_Keys.message),
      json.integer(_Keys.code),
      AdaptyUISDKNative.isAndroid ? null : json.string(_Keys.detail),
    );
  }
}

class _Keys {
  static const message = 'message';
  static const detail = 'detail';
  static const code = 'adapty_code';
}
