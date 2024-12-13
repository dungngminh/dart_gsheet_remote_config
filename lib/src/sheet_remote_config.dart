import 'package:http/http.dart' as http;

import 'sheet_remote_config_exception.dart';

/// A [SheetRemoteConfig] class that fetches a JSON config from a URL and
/// provides a way to access the config values.
class SheetRemoteConfig {
  SheetRemoteConfig({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// In-memory cache for the config values.
  final _inMemoryCachedConfig = <String, dynamic>{};

  /// Fetches the config from the given URL and stores it in the in-memory cache.
  ///
  /// *Parameters:*
  ///
  /// [configUrl] - The URL to fetch the config from.
  ///
  ///
  /// *Exceptions:*
  ///
  /// Throws a [SheetRemoteConfigException] if the request fails, no connection, invalid json config format, etc...
  Future<void> initilize({
    required String id,
    String? sheetName,
  }) {
    return _initilize(id: id, sheetName: sheetName);
  }

  Future<void> _initilize({
    required String id,
    String? sheetName,
  }) async {
    try {
      final requestUri = _buildSheetUri(id: id, sheetName: sheetName);
      final response = await _client.get(requestUri);
      if (response.statusCode == 200) {
        final payload = response.body;
      } else {
        throw Exception('Failed to load remote config');
      }
    } catch (e) {
      throw SheetRemoteConfigException(
          message: switch (e) {
        FormatException() => 'Invalid remote config',
        _ => 'Error when handling: $e',
      });
    }
  }

  Uri _buildSheetUri({required String id, String? sheetName}) {
    return Uri.https(
        'docs.google.com',
        '/spreadsheets/d/$id/gviz/tq?',
        {
          'tqx': 'out:json',
          'sheet': sheetName,
        }.filterValues((value) => value != null));
  }

  /// Returns the value of the given key from the in-memory cache.
  /// {@template get_value}
  ///
  /// *Parameters:*
  ///
  /// [key] - The key to get the value for.
  ///
  /// [defaultValue] - The default value to return if the key is not found in the cache.
  ///
  /// Returns:
  ///
  /// The value of the given key from the in-memory cache, or the default value if the key is not found.
  ///
  /// Example:
  ///
  /// ```dart
  /// final config = SheetRemoteConfig();
  /// await config.initilize(configUrl: 'http://example.com/config'); // {"key1": "value1", "key2": true, "key3": 1.0, "key4": 100, "key5": { "key6": "value5" }}
  ///
  /// final value = config.getString('key1');
  /// print(value); // value1
  ///
  /// final value2 = config.getBool('key2');
  /// print(value2); // true
  ///
  /// final value3 = config.getDouble('key3');
  /// print(value3); // 1.0
  ///
  /// final value4 = config.getInt('key4');
  /// print(value4); // 100
  ///
  /// final value5 = config.getMap('key5');
  /// print(value5); // { "key6": "value5" }
  ///
  /// final value6 = config.getString('key7');
  /// print(value6); // null
  ///
  /// final value6Default = config.getString('key7', defaultValue: 'default value');
  /// print(value6Default); // default value
  /// ```
  /// {@endtemplate}
  T? _get<T>(String key, {T? defaultValue}) {
    try {
      final value = _inMemoryCachedConfig[key] as T?;
      return value ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Return the value of the given key from the in-memory cache as a [String].
  ///
  /// If the key is not found, return the default value.
  ///
  /// {@macro get_value}
  String? getString(String key, {String? defaultValue}) {
    return _get<String>(key, defaultValue: defaultValue);
  }

  /// Return the value of the given key from the in-memory cache as a [bool].
  ///
  /// If the key is not found, return the default value.
  ///
  /// {@macro get_value}
  bool? getBool(String key, {bool? defaultValue}) {
    return _get<bool>(key, defaultValue: defaultValue);
  }

  /// Return the value of the given key from the in-memory cache as an [int].
  ///
  /// If the key is not found, return the default value.
  ///
  /// {@macro get_value}
  int? getInt(String key, {int? defaultValue}) {
    return _get<int>(key, defaultValue: defaultValue);
  }

  /// Return the value of the given key from the in-memory cache as a [double].
  ///
  /// If the key is not found, return the default value.
  ///
  /// {@macro get_value}
  double? getDouble(String key, {double? defaultValue}) {
    return _get<double>(key, defaultValue: defaultValue);
  }

  /// Return the value of the given key from the in-memory cache as a [Map].
  ///
  /// If the key is not found, return the default value.
  ///
  /// {@macro get_value}
  Map<String, dynamic>? getMap(
    String key, {
    Map<String, dynamic>? defaultValue,
  }) {
    return _get<Map<String, dynamic>>(key, defaultValue: defaultValue);
  }

  /// Return all the values from the in-memory cache.
  ///
  /// Returns:
  /// A [Map] containing all the values from the in-memory cache.
  Map<String, dynamic> getAll() {
    return _inMemoryCachedConfig;
  }
}

extension _MapExtension<K, V> on Map<K, V> {
  Map<K, V> filterValues(bool Function(V value) test) {
    return Map.fromEntries(entries.where((element) => test(element.value)));
  }
}
