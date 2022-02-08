import 'dart:convert';
import 'dart:io';

import 'JsonUtil.dart';

class FileUtil {
  static void writeFile(String filePath, String text) {
    File(filePath).writeAsStringSync(text);
  }

  static String readFile(String filePath) {
    return File(filePath).readAsStringSync();
  }

  static Map<String, dynamic> readJsonFile(String filePath) {
    String text = readFile(filePath);
    try {
      return JsonUtil.decode(text);
    } catch (e) {
      return {};
    }
  }
}
