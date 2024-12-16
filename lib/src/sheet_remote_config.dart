import 'package:http/http.dart' as http;

import 'sheet_remote_config_exception.dart';

/// A [SheetRemoteConfig] class that fetches a JSON config from a URL and
/// provides a way to access the config values.
class SheetRemoteConfig {
  SheetRemoteConfig({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// In-memory cache for the config values.
  final _inMemoryCachedConfig = <String, String>{};

  /// Fetches the config from the given URL and stores it in the in-memory cache.
  ///
  /// *Parameters:*
  ///
  /// [id] - The ID of the Google Sheet.
  /// You can find the ID of the Google Sheet in the URL of the sheet.
  /// For example, if the URL is `https://docs.google.com/spreadsheets/d/1a2b3c4d5e6f7g8h9i0j`, the ID is `1a2b3c4d5e6f7g8h9i0j`.
  ///
  /// [sheetName] - The name of the sheet to fetch the config from.
  /// If the sheet name is not provided, the first sheet in the Google Sheet will be used.
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
      if (response.statusCode != 200) {
        throw Exception('Failed to load remote config');
      }
      final payload = response.body;
      if (payload.isEmpty) return;
      if (!payload.startsWith('"')) throw FormatException();
      // "key","value"
      final keyValues = payload.split('\n').map((e) {
        final entries = e.split(',');
        final key = entries[0].replaceAll('"', '');
        final value = entries[1].replaceAll('"', '');
        return MapEntry(key, value);
      }).toList();
      _inMemoryCachedConfig.addAll(Map.fromEntries(keyValues));
    } catch (e, st) {
      throw SheetRemoteConfigException(
          message: switch (e) {
            FormatException() => 'Invalid remote config',
            _ => 'Error when handling: $e',
          },
          stackTrace: st);
    }
  }

  /// Builds a URI for accessing a Google Sheet in **CSV format**.
  ///
  /// This function constructs a URI that points to a specific Google Sheet
  /// and optionally to a specific sheet within the spreadsheet. The URI
  /// is formatted to request the sheet data in **CSV format**.
  ///
  /// The function filters out any null values from the query parameters.
  ///
  /// *Parameters:*
  ///
  /// - [id] is the unique identifier of the Google Sheet.
  ///
  /// - [sheetName] is the optional name of the specific sheet within the spreadsheet.
  ///
  /// *Returns:*
  ///
  /// Returns a [Uri] object that can be used to access the Google Sheet data.
  Uri _buildSheetUri({required String id, String? sheetName}) {
    return Uri.https(
        'docs.google.com',
        '/spreadsheets/d/$id/gviz/tq',
        {
          'tqx': 'out:csv',
          'sheet': sheetName,
        }.filterValues((value) => value != null));
  }

  /// Return the value of the given key from the in-memory cache as a [String].
  ///
  /// If the key is not found, return the default value.
  ///
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
  /// await config.initialize(id: 'eqweqdqdadqweqdfwsdf'); // "key1","value1"\n"key2","true"\n"key3","1.0"\n"key4","100"
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
  /// final value5 = config.getString('key5');
  /// print(value5); // null
  ///
  /// final value5Default = config.getString('key5', defaultValue: 'default value');
  /// print(value5Default); // default value
  /// ```
  /// {@endtemplate}
  String? getString(String key, {String? defaultValue}) {
    try {
      final valueAtKey = _inMemoryCachedConfig[key];
      return valueAtKey ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Return the value of the given key from the in-memory cache as a [bool].
  ///
  /// If the key is not found, return the default value.
  ///
  /// {@macro get_value}
  bool? getBool(String key, {bool? defaultValue}) {
    try {
      final value = _inMemoryCachedConfig[key];
      if (value == null && value!.isEmpty) return defaultValue;
      final boolValue = bool.tryParse(
        value,
        caseSensitive: false,
      );
      return boolValue ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Return the value of the given key from the in-memory cache as an [int].
  ///
  /// If the key is not found, return the default value.
  ///
  /// {@macro get_value}
  int? getInt(String key, {int? defaultValue}) {
    try {
      final valueAtKey = _inMemoryCachedConfig[key];
      if (valueAtKey == null && valueAtKey!.isEmpty) return defaultValue;
      final intValue = int.tryParse(valueAtKey);
      return intValue ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Return the value of the given key from the in-memory cache as a [double].
  ///
  /// If the key is not found, return the default value.
  ///
  /// {@macro get_value}
  double? getDouble(String key, {double? defaultValue}) {
    try {
      final valueAtKey = _inMemoryCachedConfig[key];
      if (valueAtKey == null && valueAtKey!.isEmpty) return defaultValue;
      final doubleValue = double.tryParse(valueAtKey);
      return doubleValue ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Return all the values from the in-memory cache.
  ///
  /// Returns:
  ///
  /// A [Map] containing all the values from the in-memory cache.
  Map<String, String> getAll() {
    return _inMemoryCachedConfig;
  }
}

extension _MapExtension<K, V> on Map<K, V> {
  Map<K, V> filterValues(bool Function(V value) test) {
    return Map.fromEntries(entries.where((element) => test(element.value)));
  }
}
