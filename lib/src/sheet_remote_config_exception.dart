/// A [SheetRemoteConfigException] class for handling errors related to the Simple Remote Config.
///
/// This exception can be used to indicate various issues that may arise when
/// working with the Simple Remote Config, such as network errors, parsing errors,
/// or configuration issues.
///
/// Example usage:
/// ```dart
/// try {
///   // Code that might throw a `SheetRemoteConfigException`
/// } catch (e) {
///   if (e is SheetRemoteConfigException) {
///     // Handle the exception
///   }
/// }
/// ```
class SheetRemoteConfigException implements Exception {
  /// The error message associated with this exception.
  final String message;

  /// The stack trace associated with this exception.
  final StackTrace? stackTrace;

  SheetRemoteConfigException({required this.message, StackTrace? stackTrace})
      : stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    return 'SheetRemoteConfigException: $message';
  }
}

class UnauthorizedException extends SheetRemoteConfigException {
  UnauthorizedException({super.message = 'Unauthorized'});
}