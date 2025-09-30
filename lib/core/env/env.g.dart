// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env
final class _Env {
  static const List<int> _enviedkeyweatherApiKey = <int>[
    1652833017,
    480373338,
    2426624061,
    1310445354,
    3932452542,
    3988584319,
    1292670846,
    918494344,
    3997950394,
    321288927,
    1624962912,
    852497952,
    3499418137,
    4045144923,
  ];

  static const List<int> _envieddataweatherApiKey = <int>[
    1652832896,
    480373301,
    2426624072,
    1300445400,
    3932452577,
    3984584223,
    1292670734,
    918494433,
    3997950437,
    321288885,
    1624962821,
    852498009,
    3496418010,
    4045144866,
  ];

  static final String weatherApiKey = String.fromCharCodes(
    List<int>.generate(
      _envieddataweatherApiKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddataweatherApiKey[i] ^ _enviedkeyweatherApiKey[i]),
  );
}
