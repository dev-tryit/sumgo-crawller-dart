import 'dart:convert';

import 'package:logger/logger.dart';
import "package:stack_trace/stack_trace.dart";
import '../Setting.dart';
import 'DateTimeUtil.dart';

class MyLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return Setting.showLog;
  }
}

class MySimplePrinter extends SimplePrinter {
  MySimplePrinter({bool printTime = false, bool colors = true})
      : super(printTime: printTime, colors: colors);

  @override
  List<String> log(LogEvent event) {
    var messageStr = _stringifyMessage(event.message);
    var errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    var timeStr = printTime ? 'TIME: ${DateTimeUtil.now().toIso8601String()}' : '';

    return ['${_labelFor(event.level)} $timeStr $messageStr$errorStr'];
  }

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }

  String _labelFor(Level level) {
    var prefix = SimplePrinter.levelPrefixes[level]!;
    var color = SimplePrinter.levelColors[level]!;

    return colors ? color(prefix) : prefix;
  }
}

class LogUtil {
  static final bool _showLogLevel = false;
  static final bool _showAppName = false;
  static final bool _showMethodName = true;
  static Logger _logger = new Logger(
    filter: MyLogFilter(),
    level: Setting.LogLevel,
    printer: MySimplePrinter(printTime: true, colors: true),
    // printer: new PrettyPrinter(
    //     methodCount: 0,
    //     // // number of method calls to be displayed
    //     // errorMethodCount: 8,
    //     // // number of method calls if stacktrace is provided
    //     // lineLength: 600,
    //     // // width of the output
    //     colors: true,
    //     // // Colorful log messages
    //     // printEmojis: true,
    //     // // Print an emoji for each log message
    //     // printTime: true // Should each log print contain a timestamp
    //     ),
  );

  static void info(String msg) {
    _logger.i(makeLogString(msg));
  }

  static void debug(String msg) {
    _logger.d(makeLogString(msg));
  }

  static void warn(String msg) {
    _logger.w(makeLogString(msg));
  }

  static void error(String msg) {
    _logger.e(makeLogString(msg));
  }

  static String makeLogString(String msg) {
    String logStr = "";

    if (_showLogLevel) {
      String? logLevel = Trace?.current().frames[1].member;
      logLevel = logLevel != null ? logLevel.split(".")[1] : null;
      logStr += "[$logLevel] ";
    }

    if (_showAppName) {
      logStr += "[${Setting.appName}_APP] ";
    }

    if (_showMethodName) {
      String? methodName = Trace?.current().frames[2].member;
      logStr += "[$methodName] ";
    }

    logStr += "$msg";
    return logStr;
  }
}
