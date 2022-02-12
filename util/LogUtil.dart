import 'package:logger/logger.dart';
import "package:stack_trace/stack_trace.dart";
import '../Setting.dart';

class MyLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return Setting.showLog;
  }
}

class LogUtil {
  static final bool _showLogLevel = false;
  static final bool _showAppName = false;
  static final bool _showMethodName = true;
  static Logger _logger = new Logger(
    filter: MyLogFilter(),
    level: Setting.LogLevel,
    printer: new SimplePrinter(printTime: true, colors: true),
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