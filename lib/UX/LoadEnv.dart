import 'dart:convert';
import 'package:flutter/services.dart';

class EnvConfig {
  final String baseUrl;

  EnvConfig({required this.baseUrl});

  static Future<EnvConfig> load(String environment) async {
    final String jsonString =
        await rootBundle.loadString('assets/env_config.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    if (!jsonMap.containsKey(environment)) {
      throw Exception(
          "Environment '$environment' not found in env_config.json");
    }

    final envData = jsonMap[environment];
    return EnvConfig(baseUrl: envData['baseUrl']);
  }
}
