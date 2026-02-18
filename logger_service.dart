import 'package:logger/logger.dart';

// 🔹 Singleton logger
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // show no method info
      colors: true,
      printEmojis: true,
      lineLength: 60,
    ),
  );

  static Logger get logger => _logger;
}

