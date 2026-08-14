import 'package:equatable/equatable.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';
import 'package:xuan_time_location/xuan_time_location.dart';

class TiebanChartParams extends Equatable implements ModuleParams {
  final double latitude;
  final double longitude;
  final double altitude;
  final String timezone;
  final bool isMale;

  /// 记录唯一标识，空串时由 Calculator 落空 uuid。
  final String uuid;

  const TiebanChartParams({
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.altitude = 0.0,
    this.timezone = chinaTimeZoneId,
    this.isMale = false,
    this.uuid = '',
  });

  /// JSON 解码器（与 [toJson] 互逆）。
  ///
  /// - 缺字段套默认（坐标 0.0、时区 [chinaTimeZoneId]、`isMale` false、`uuid` 空串），不抛错。
  /// - 字段存在但类型不合法（如 `latitude: '39.9'`、`timezone: 42`、`isMale: 'yes'`）时抛
  ///   [FormatException]，不静默兜底。
  factory TiebanChartParams.fromJson(Map<String, dynamic> json) {
    final latitudeRaw = json['latitude'];
    if (latitudeRaw != null && latitudeRaw is! num) {
      throw FormatException('latitude 类型不合法: $latitudeRaw');
    }
    final longitudeRaw = json['longitude'];
    if (longitudeRaw != null && longitudeRaw is! num) {
      throw FormatException('longitude 类型不合法: $longitudeRaw');
    }
    final altitudeRaw = json['altitude'];
    if (altitudeRaw != null && altitudeRaw is! num) {
      throw FormatException('altitude 类型不合法: $altitudeRaw');
    }
    final timezoneRaw = json['timezone'];
    if (timezoneRaw != null && timezoneRaw is! String) {
      throw FormatException('timezone 类型不合法: $timezoneRaw');
    }
    final isMaleRaw = json['isMale'];
    if (isMaleRaw != null && isMaleRaw is! bool) {
      throw FormatException('isMale 类型不合法: $isMaleRaw');
    }
    final uuidRaw = json['uuid'];
    if (uuidRaw != null && uuidRaw is! String) {
      throw FormatException('uuid 类型不合法: $uuidRaw');
    }

    return TiebanChartParams(
      latitude: (latitudeRaw as num?)?.toDouble() ?? 0.0,
      longitude: (longitudeRaw as num?)?.toDouble() ?? 0.0,
      altitude: (altitudeRaw as num?)?.toDouble() ?? 0.0,
      timezone: (timezoneRaw as String?) ?? chinaTimeZoneId,
      isMale: (isMaleRaw as bool?) ?? false,
      uuid: (uuidRaw as String?) ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'timezone': timezone,
    'isMale': isMale,
    'uuid': uuid,
  };

  @override
  List<Object?> get props => [latitude, longitude, altitude, timezone, isMale, uuid];
}
