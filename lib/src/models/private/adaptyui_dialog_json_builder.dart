part of '../adaptyui_dialog.dart';

extension AdaptyUIDialogActionStyleJSONBuilder on AdaptyUIDialogActionStyle {
  String get jsonValue {
    switch (this) {
      case AdaptyUIDialogActionStyle.standard:
        return 'standard';
      case AdaptyUIDialogActionStyle.cancel:
        return 'cancel';
      case AdaptyUIDialogActionStyle.destructive:
        return 'destructive';
    }
  }
}

extension AdaptyUIDialogActionJSONBuilder on AdaptyUIDialogAction {
  dynamic get jsonValue => {
        _ActionKeys.title: title,
        _ActionKeys.style: style.jsonValue,
      };
}

extension AdaptyUIDialogJSONBuilder on AdaptyUIDialog {
  dynamic get jsonValue => {
        if (title != null) _DialogKeys.title: title,
        if (message != null) _DialogKeys.message: message,
        if (actions != null) _DialogKeys.actions: actions!.map((e) => e.jsonValue).toList(),
      };
}

class _ActionKeys {
  static const title = 'title';
  static const style = 'style';
}

class _DialogKeys {
  static const title = 'title';
  static const message = 'message';
  static const actions = 'actions';
}
