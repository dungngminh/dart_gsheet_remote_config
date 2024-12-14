import 'package:dart_gsheet_remote_config/src/sheet_remote_config_exception.dart';
import 'package:test/test.dart';

void main() {
  group('SheetRemoteConfigException', () {
    test('should return correct message', () {
      final exception = SheetRemoteConfigException(message: 'Test error');
      expect(exception.message, 'Test error');
    });

    test('should return correct stack trace', () {
      final stackTrace = StackTrace.current;
      final exception = SheetRemoteConfigException(
          message: 'Test error', stackTrace: stackTrace);
      expect(exception.stackTrace, stackTrace);
    });

    test('should use current stack trace if none provided', () {
      final exception = SheetRemoteConfigException(message: 'Test error');
      expect(exception.stackTrace, isNotNull);
    });

    test('toString should return correct format', () {
      final exception = SheetRemoteConfigException(message: 'Test error');
      expect(exception.toString(), 'SheetRemoteConfigException: Test error');
    });
  });
}
