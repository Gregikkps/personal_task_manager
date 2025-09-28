import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  );
}
