import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
      primary: Colors.blue[700],
      secondary: Colors.teal[300],
      surface: Colors.grey[850],
      surfaceContainer: Colors.grey[800],
      onSurface: Colors.white,
      onSecondary: Colors.black,
      error: Colors.red[400],
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[800],
    ),
  );
}