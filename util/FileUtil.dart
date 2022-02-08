import 'dart:convert';
import 'dart:io';

import 'JsonUtil.dart';

class FileUtil {
  static String getStringFromFile(String filePath) {
    return File(filePath).readAsStringSync();
  }

  static Map<String, dynamic> readJsonFile(String filePath) {
    String text = getStringFromFile(filePath);
    try {
      return JsonUtil.decode(text);
    } catch (e) {
      return {};
    }
  }
}
