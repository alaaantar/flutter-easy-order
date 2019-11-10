import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

class UiHelper {
  static Flushbar createSuccess(
      {@required String message,
        String title,
        Duration duration = const Duration(seconds: 3)}) {
    return Flushbar(
      title: title,
      message: message,
      icon: Icon(
        Icons.check_circle,
        color: Colors.green[300],
      ),
      leftBarIndicatorColor: Colors.green[300],
      duration: duration,
      isDismissible: true,
    );
  }

  static Flushbar createError(
      {@required String message,
        String title,
        Duration duration = const Duration(seconds: 3)}) {
    return Flushbar(
      title: title,
      message: message,
      icon: Icon(
        Icons.warning,
        size: 28.0,
        color: Colors.red[300],
      ),
      leftBarIndicatorColor: Colors.red[300],
      duration: duration,
    );
  }
}