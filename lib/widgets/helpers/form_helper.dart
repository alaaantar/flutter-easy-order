import 'package:flutter/material.dart';

class FormHelper {
  static void changeFieldFocus(BuildContext context, FocusNode currentFocusNode, FocusNode nextFocusNodes) {
    currentFocusNode.unfocus();
    FocusScope.of(context).requestFocus(nextFocusNodes);
  }
}
