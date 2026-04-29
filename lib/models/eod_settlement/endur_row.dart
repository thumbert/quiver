import 'package:date/date.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:elec_server/client/ui/eod_settlements/views_asof_date.dart';


class EndurRow {
  EndurRow({
    required String? curveName,
    required Date? asOf,
    required String? strip,
    required String? unitConversion,
  })  : curveName = signal(curveName),
        asOf = signal(asOf),
        strip = signal(strip),
        unitConversion = signal(unitConversion) {
    label = signal(suggestedLabel());
  }

  FlutterSignal<String?> curveName;
  FlutterSignal<Date?> asOf;
  FlutterSignal<String?> strip;
  FlutterSignal<String?> unitConversion;
  late final FlutterSignal<String> label;

  static EndurRow fromRecord(Record record) {
    return EndurRow(
      curveName: record.endurCurveName,
      asOf: record.asOfDate,
      strip: record.strip,
      unitConversion: record.unitConversion,
    );
  }

  String suggestedLabel() {
    if (asOf.value == null) return '';
    return 'Endur: ${asOf.value!.toIso8601String()}';
  }
}
