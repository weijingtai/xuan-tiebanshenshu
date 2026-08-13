import 'package:flutter/material.dart';
import 'package:metaphysics_core/models/divination_datetime.dart';
import 'package:provider/provider.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:repository_interface_tiebanshenshu/repository_interface_tiebanshenshu.dart';
import 'package:xuan_four_zhu_card/four_zhu_card.dart';
import 'package:xuan_four_zhu_card/widgets/query_time_input_card.dart';
import 'package:tiebanshenshu/domain/pipeline/tieban_chart_params.dart';
import 'package:tiebanshenshu/domain/pipeline/tieban_pipeline_executor.dart';
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

  /// Pipeline 统一入参排盘结果（含落库 Record 与错误信息，供测试断言）。
  TiebanDivinationRecordContract? lastPipelineRecord;
  String? lastPipelineError;
  bool _isCalculating = false;

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

  /// 走 Pipeline 统一入参排盘并落库走 Record。
  ///
  /// 失败只记 [lastPipelineError] 并 debugPrint，不打断 UI 展示输入结果。
  Future<void> _runPipeline() {
    return runPipelineWith(dateTime: _selectedDateTime, location: _selectedLocation);
  }

  /// Pipeline 统一入参排盘（公开可测入口）。
  ///
  /// [dateTime]/[location] 可显式传入（测试用）；缺省回退到页面当前选择。
  Future<void> runPipelineWith({
    DateTime? dateTime,
    Location? location,
  }) async {
    final dt = dateTime ?? _selectedDateTime;
    if (dt == null) {
      lastPipelineError = '未选择时间';
      setState(() {});
      return;
    }

    final executor = context.read<TiebanPipelineExecutor>();
    final recordRepo = context.read<TiebanRecordRepository>();
    final selectedLocation = location ?? _selectedLocation;
    final coordinates = selectedLocation?.coordinates;
    final timezone = selectedLocation?.address?.timezone ?? 'Asia/Shanghai';
    final latitude = coordinates?.latitude ?? 0.0;
    final longitude = coordinates?.longitude ?? 0.0;

    final params = TiebanChartParams(
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      uuid: 'tieban-${dt.millisecondsSinceEpoch}',
    );
    final request = ChartRequest<TiebanChartParams>(
      moment: DivinationMoment(
        instantUtc: dt.toUtc(),
        place: GeoPoint(
          latitude: latitude,
          longitude: longitude,
          timeZoneId: timezone,
        ),
        reckoning: EnumDatetimeType.standard,
      ),
      params: params,
    );

    _isCalculating = true;
    lastPipelineError = null;
    setState(() {});
    try {
      final record = await executor.execute(request);
      lastPipelineRecord = record;
      await recordRepo.saveRecord(record);
    } catch (error, stack) {
      debugPrint('铁板 Pipeline 排盘失败: $error\n$stack');
      lastPipelineError = error.toString();
    } finally {
      _isCalculating = false;
      if (mounted) setState(() {});
    }
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

            const SizedBox(height: 24),

            // Pipeline 统一入参排盘按钮
            ElevatedButton(
              onPressed: _isCalculating ? null : _runPipeline,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
              ),
              child: _isCalculating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('排盘并保存'),
            ),
            if (lastPipelineError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '排盘失败: $lastPipelineError',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
