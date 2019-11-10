import 'package:flutter_easy_order/models/category.dart';
import 'package:flutter_easy_order/widgets/form_inputs/image_input_adapter.dart';

class Validator {
  static String validateEmail(String value) {
    return (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value))
        ? 'Please enter a valid email'
        : null;
  }

  static String validatePassword(String value) {
    return (value.isEmpty || value.length < 6) ? 'Password is invalid' : null;
  }

  static String validateConfirmPassword(String value) {
    return null;
  }

  static String validateName(String value) {
    return (value.isEmpty || value.length < 3 || value.length > 50)
        ? 'Name is required and should be 3+ characters long'
        : null;
  }

  static String validateCategory(Category value) {
    return (value == null)
        ? 'Category is required'
        : null;
  }

  static String validateDescription(String value) {
    return (value.isNotEmpty && value.length > 50) ?
        'Description should be max 50 characters long'
        : null;
  }

  static String validatePrice(String value) {
    return (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value))
        ? 'Price is required and should be a number'
        : null;
  }

  static String validateImage(ImageInputAdapter value) {
    if (value.file == null) {
//          return 'Please choose an image';
    }
    return null;
  }

  static String validateClientId(String value) {
    return (value.isEmpty || value.length > 50)
        ? 'Client ID is required and should be max 50 characters long'
        : null;
  }

  static String validateOrderDate(DateTime value) {
    return (value == null || value.compareTo(DateTime.now()) > 1)
        ? 'Date is empty or invalid'
        : null;
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
