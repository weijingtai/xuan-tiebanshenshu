import 'package:flutter/material.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:enumeration/enums.dart';
import 'package:xuan_four_zhu_card/four_zhu_card.dart';
import 'package:xuan_four_zhu_card/widgets/query_time_input_card.dart';
import 'package:tiebanshenshu/infrastructure/tiebanshenshu_timezone_provider_adapter.dart';
import 'package:tiebanshenshu/presentation/components/glass_scaffold.dart';
import 'package:tiebanshenshu/presentation/theme/app_colors.dart';

/// 铁板神数排盘输入页面
///
/// 使用统一时间输入组件 QTIC（替代原生 showDatePicker / showTimePicker）
class ChartInputPage extends StatefulWidget {
  const ChartInputPage({super.key});

  @override
  State<ChartInputPage> createState() => _ChartInputPageState();
}

class _ChartInputPageState extends State<ChartInputPage> {
  late final ValueNotifier<
    List<MapEntry<EnumDatetimeType, DivinationDatetimeModel>>?
  > _selectableCardsNotifier;

  late final TiebanshenshuTimezoneProviderAdapter _timezoneAdapter;

  DateTime? _selectedDateTime;
  Location? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectableCardsNotifier =
        ValueNotifier<List<MapEntry<EnumDatetimeType, DivinationDatetimeModel>>?>(
          null,
        );

    final initialDt = DateTime.now();
    _timezoneAdapter = TiebanshenshuTimezoneProviderAdapter(
      initialDatetime: initialDt,
      onDatetimeChanged: (dt) {
        if (dt != null && mounted) {
          setState(() {
            _selectedDateTime = dt;
          });
        }
      },
      onLocationSelected: (location) {
        if (location != null && mounted) {
          setState(() {
            _selectedLocation = location;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _selectableCardsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // 统一时间输入组件
            QueryTimeInputCard(
              defaultDateTimeType: DateTimeType.solar,
              selectableCardsNotifier: _selectableCardsNotifier,
              timezoneProvider: _timezoneAdapter,
              initialDateTime: _selectedDateTime ?? DateTime.now(),
            ),

            const SizedBox(height: 24),

            // 显示选中结果
            if (_selectedDateTime != null || _selectedLocation != null)
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '选中结果',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedDateTime != null)
                        Text('时间: $_selectedDateTime'),
                      if (_selectedLocation != null)
                        Text('地点: ${_selectedLocation!.address?.formattedAddress ?? ""}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
