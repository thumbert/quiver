library test.models.polygraph.other.serde_test;

import 'dart:io';
import 'dart:ui';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/editors/horizontal_line.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests() async {
  group('Serialization/Deserialization tests', () {
    test('TransformedVariable simple', () {
      var term = Term.parse('Jan21-Dec21', IsoNewEngland.location);
      var v = TransformedVariable(
          expression: "hourly_schedule(50, bucket='Peak')", label: 'peak');
      var env = <String, dynamic>{'_domain': term.interval};
      v.eval(env);
      var ts = env['peak'] as TimeSeries<num>;
      expect(ts.length, 4096);
      var out = <String,dynamic>{
        'type': 'TransformedVariable',
        'expression': "hourly_schedule(50, bucket='Peak')",
        'label': 'peak',
        'displayConfig': <String,dynamic>{},
      };
      expect(v.toMap(), out);
      var v1 = TransformedVariable.fromMongo(out);
      expect(v1.label, 'peak');
      expect(v1.expression, "hourly_schedule(50, bucket='Peak')");
    });

    test('TransformedVariable multi-line', () {
      var term = Term.parse('Jan21-Dec21', IsoNewEngland.location);
      var v = TransformedVariable(
          expression: "hourly_schedule(50, bucket='Peak') .+\n hourly_schedule(10, bucket='Offpeak')",
          label: 'flat');
      var env = <String, dynamic>{'_domain': term.interval};
      v.eval(env);
      var ts = env['flat'] as TimeSeries<num>;
      expect(ts.length, 8760);
    });

  });
}

Future<void> main() async {
  initializeTimeZones();
  await tests();
}
