import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/storage/shared_prefs_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPrefsStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await SharedPrefsStorage.create();
  });

  test('writes and reads values', () async {
    await storage.setString('a', 'x');
    await storage.setBool('b', true);
    await storage.setInt('c', 3);
    expect(storage.getString('a'), 'x');
    expect(storage.getBool('b'), true);
    expect(storage.getInt('c'), 3);
    expect(storage.containsKey('a'), true);
  });

  test('remove and clear', () async {
    await storage.setString('a', 'x');
    await storage.remove('a');
    expect(storage.getString('a'), isNull);
    await storage.setInt('c', 1);
    await storage.clear();
    expect(storage.containsKey('c'), false);
  });

  test('type mismatch throws CacheException', () async {
    await storage.setString('a', 'x');
    expect(() => storage.getInt('a'), throwsA(isA<CacheException>()));
  });
}
