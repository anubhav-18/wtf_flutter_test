import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppFeedback {
  const AppFeedback._();

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        action: isError
            ? SnackBarAction(
                label: 'Copy error',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                },
              )
            : null,
      ));
  }
}
