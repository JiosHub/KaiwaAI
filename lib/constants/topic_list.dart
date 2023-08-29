import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<List<Map<String, String>>> readTopicsFromFile() async {
  final String filePath = 'lib/constants/topics.txt';  // Replace with your actual file path
  final content = await rootBundle.loadString(filePath);
  final lines = content.split('\n');

  final List<Map<String, String>> topics = [];

  for (int i = 0; i < lines.length; i += 2) {
    if (i + 1 < lines.length) {
      topics.add({
        'title': lines[i],
        'content': lines[i + 1],
      });
    }
  }

  return topics;
}