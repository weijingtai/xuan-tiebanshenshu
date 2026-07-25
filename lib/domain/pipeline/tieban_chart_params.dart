import 'package:equatable/equatable.dart';
import 'package:repository_interface_divination_pipeline/repository_interface_divination_pipeline.dart';

class TiebanChartParams extends Equatable implements ModuleParams {
  final double latitude;
  final double longitude;
  final double altitude;
  final String timezone;
  final bool isMale;

  const TiebanChartParams({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.timezone,
    this.isMale = false,
  });

  @override
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'timezone': timezone,
    'isMale': isMale,
  };

  @override
  List<Object?> get props => [latitude, longitude, altitude, timezone, isMale];
}
