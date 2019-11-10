import 'package:flutter/material.dart';

final ThemeData _androidTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  accentColor: Colors.blueAccent,
  buttonColor: Colors.blueAccent,
  inputDecorationTheme: InputDecorationTheme(
    errorStyle: TextStyle(
      color: Colors.red,
    ),
    hintStyle: TextStyle(
      color: Colors.indigo[100],
    ),
  ),
  textTheme: TextTheme(
    title: TextStyle(
      color: Colors.white,
    ),
  ),
  fontFamily: 'Raleway',
);

final ThemeData _iOSTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.grey,
  accentColor: Colors.blue,
  buttonColor: Colors.blue,
  inputDecorationTheme: InputDecorationTheme(
    errorStyle: TextStyle(
      color: Colors.red,
    ),
    hintStyle: TextStyle(
      color: Colors.indigo[100],
    ),
  ),
  textTheme: TextTheme(
    title: TextStyle(
      color: Colors.white,
    ),
  ),
  fontFamily: 'Raleway',
);

ThemeData getAdaptiveThemeData(context) {
  return Theme.of(context).platform == TargetPlatform.android ? _androidTheme : _iOSTheme;
}
