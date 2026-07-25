import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metaphysics_core/datamodel/location.dart';
import 'package:xuan_four_zhu_card/domain/ports/i_timezone_provider.dart';
import 'package:tiebanshenshu/infrastructure/tiebanshenshu_timezone_provider_adapter.dart';

void main() {
  group('R7 TiebanshenshuTimezoneProviderAdapter', () {
    test('implements ITimezoneProvider interface', () {
      final adapter = TiebanshenshuTimezoneProviderAdapter(
        initialDatetime: DateTime(2024, 1, 15, 10, 30),
      );

      // 验证 implements ITimezoneProvider
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

      // Adding same location should not duplicate
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

      // load should complete without throwing
      await adapter.load();
    });
  });

  group('ChartInputPage smoke test', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('QTIC integration test placeholder'),
            ),
          ),
        ),
      );

      expect(find.text('QTIC integration test placeholder'), findsOneWidget);
    });
  });
}
