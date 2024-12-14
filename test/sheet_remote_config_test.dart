import 'package:dart_gsheet_remote_config/src/sheet_remote_config.dart';
import 'package:dart_gsheet_remote_config/src/sheet_remote_config_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('SheetRemoteConfig', () {
    test('initializes and fetches config successfully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            '"key1","value1"\n"key2","true"\n"key3","1.0"\n"key4","100"', 200);
      });

      final config = SheetRemoteConfig(client: mockClient);
      await config.initilize(id: 'test_id', sheetName: 'test_sheet');

      expect(config.getString('key1'), 'value1');
      expect(config.getBool('key2'), true);
      expect(config.getDouble('key3'), 1.0);
      expect(config.getInt('key4'), 100);
      expect(config.getAll(), {
        'key1': 'value1',
        'key2': 'true',
        'key3': '1.0',
        'key4': '100',
      });
    });

    test('initializes and fetches config successfully but response is empty',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 200);
      });

      final config = SheetRemoteConfig(client: mockClient);
      await config.initilize(id: 'test_id', sheetName: 'test_sheet');

      expect(config.getString('key1'), null);
      expect(config.getBool('key2'), null);
      expect(config.getDouble('key3'), null);
      expect(config.getInt('key4'), null);
      expect(config.getAll(), {});
    });

    test('throws exception when request fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final config = SheetRemoteConfig(client: mockClient);

      expect(
        () async =>
            await config.initilize(id: 'test_id', sheetName: 'test_sheet'),
        throwsA(isA<SheetRemoteConfigException>()),
      );
    });

    test('returns default value if key is not found', () async {
      final mockClient = MockClient((request) async {
        return http.Response('"key1","value1"', 200);
      });

      final config = SheetRemoteConfig(client: mockClient);
      await config.initilize(id: 'test_id', sheetName: 'test_sheet');

      expect(config.getString('key2', defaultValue: 'default'), 'default');
    });

    test('handles invalid CSV format', () async {
      final mockClient = MockClient((request) async {
        return http.Response('invalid,json,format', 200);
      });

      final config = SheetRemoteConfig(client: mockClient);

      expect(
        () async =>
            await config.initilize(id: 'test_id', sheetName: 'test_sheet'),
        throwsA(isA<SheetRemoteConfigException>()),
      );
    });
  });
}
