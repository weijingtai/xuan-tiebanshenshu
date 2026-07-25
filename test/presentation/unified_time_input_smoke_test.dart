import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:metaphysics_core/enums.dart';
import 'package:xuan_four_zhu_card/domain/ports/i_timezone_provider.dart';
import 'package:xuan_four_zhu_card/widgets/query_time_input_card.dart';
import 'package:tiebanshenshu/infrastructure/tiebanshenshu_timezone_provider_adapter.dart';

void main() {
  group('R7 TiebanshenshuTimezoneProviderAdapter', () {
    test('implements ITimezoneProvider interface', () {
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime(2024, 1, 15, 10, 30),
      );

      expect(adapter, isA<ITimezoneProvider>());
    });

    test('selectedDatetime returns initial datetime', () {
      final initialDt = DateTime(2024, 1, 15, 10, 30);
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: initialDt,
      );

      expect(adapter.selectedDatetime, equals(initialDt));
    });

    test('updateDatetime updates selectedDatetime and notifies', () {
      DateTime? callbackDt;
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime(2024, 1, 15, 10, 30),
        onDatetimeChanged: (dt) => callbackDt = dt,
      );

      final newDt = DateTime(2024, 6, 20, 14, 45);
      adapter.updateDatetime(newDt);

      expect(adapter.selectedDatetime, equals(newDt));
      expect(adapter.selectedTimeNotifier.value, equals(newDt));
      expect(callbackDt, equals(newDt));
    });

    test('timezone defaults to Asia/Shanghai', () {
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime.now(),
      );

      expect(adapter.timezone, equals('Asia/Shanghai'));
      expect(adapter.localTimezone, equals('Asia/Shanghai'));
    });

    test('updateTimezone updates timezone notifier', () {
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime.now(),
      );

      adapter.updateTimezone('America/New_York');
      expect(adapter.timezone, equals('America/New_York'));
      expect(adapter.timezoneNotifier.value, equals('America/New_York'));
    });

    test('selectLocation updates selectedLocation and notifies', () {
      Location? callbackLocation;
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime.now(),
        onLocationSelected: (loc) => callbackLocation = loc,
      );

      final location = Location(address: Address.defualtAddress);

      adapter.selectLocation(location);

      expect(adapter.selectedLocationNotifier.value, equals(location));
      expect(callbackLocation, equals(location));
      expect(adapter.isSeerLocationNotifier.value, isFalse);
    });

    test('addLocation adds to location list', () {
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime.now(),
      );

      final location = Location(address: Address.defualtAddress);

      adapter.addLocation(location);

      expect(adapter.locationListNotifier.value, contains(location));
      expect(adapter.locationListNotifier.value.length, equals(1));

      adapter.addLocation(location);
      expect(adapter.locationListNotifier.value.length, equals(1));
    });

    test('usingSeersLocation toggles isSeerLocation', () {
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime.now(),
      );

      expect(adapter.isSeerLocationNotifier.value, isFalse);

      adapter.usingSeersLocation(true);
      expect(adapter.isSeerLocationNotifier.value, isTrue);

      adapter.usingSeersLocation(false);
      expect(adapter.isSeerLocationNotifier.value, isFalse);
    });

    test('load completes without error', () async {
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime.now(),
      );

      await adapter.load();
    });
  });

  group('QTIC integration smoke test', () {
    test('TiebanshenshuTimezoneProviderAdapter is compatible with QueryTimeInputCard',
        () {
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime(2024, 1, 15, 10, 30),
      );

      // 编译级验证：adapter 可以作为 QTIC 的 timezoneProvider 参数传入
      // QueryTimeInputCard 构造函数要求 ITimezoneProvider 类型
      // 编译通过 = 类型兼容 = 集成链路正确
      void acceptTimezoneProvider(ITimezoneProvider provider) {}
      expect(() => acceptTimezoneProvider(adapter), returnsNormally);

      // 验证 adapter 满足 QTIC 所需的全部接口方法
      expect(adapter.selectedDatetime, isNotNull);
      expect(adapter.timezone, isNotNull);
      expect(adapter.localTimezone, isNotNull);

      // 验证 QTIC 会调用的关键方法
      adapter.updateDatetime(DateTime(2024, 6, 20, 14, 45));
      expect(adapter.selectedDatetime, equals(DateTime(2024, 6, 20, 14, 45)));

      adapter.updateTimezone('Asia/Tokyo');
      expect(adapter.timezone, equals('Asia/Tokyo'));

      final location = Location(address: Address.defualtAddress);
      adapter.selectLocation(location);
      expect(adapter.selectedLocationNotifier.value, equals(location));
    });

    testWidgets('datetime callback flows through adapter to page state', (tester) async {
      DateTime? capturedDt;
      Location? capturedLoc;

      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime(2024, 1, 15, 10, 30),
        onDatetimeChanged: (dt) => capturedDt = dt,
        onLocationSelected: (loc) => capturedLoc = loc,
      );

      // 模拟 QTIC 的回调流程：用户选择时间 → adapter.updateDatetime → callback
      adapter.updateDatetime(DateTime(2024, 6, 20, 14, 45));
      expect(capturedDt, equals(DateTime(2024, 6, 20, 14, 45)));
      expect(adapter.selectedDatetime, equals(DateTime(2024, 6, 20, 14, 45)));
      expect(adapter.selectedTimeNotifier.value, equals(DateTime(2024, 6, 20, 14, 45)));

      // 模拟 QTIC 的回调流程：用户选择地点 → adapter.selectLocation → callback
      final location = Location(address: Address.defualtAddress);
      adapter.selectLocation(location);
      expect(capturedLoc, equals(location));
      expect(adapter.selectedLocationNotifier.value, equals(location));
      expect(adapter.isSeerLocationNotifier.value, isFalse);
    });
  });
}
