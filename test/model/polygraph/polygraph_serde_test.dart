library test.models.polygraph_serde_test;

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_margin.dart';
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
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_asofdate.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_historical_view.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  group('Serde tests for Variables: ', () {
    test('TimeVariable', () {
      var v = TimeVariable();
      var out = <String, dynamic>{
        'type': 'TimeVariable',
        'config': {
          'skipWeekends': false,
        }
      };
      expect(v.toJson(), out);
      var vExp = TimeVariable.fromJson(out);
      expect(vExp.skipWeekends, false);
    });

    test('TransformedVariable simple', () {
      var term = Term.parse('Jan21-Dec21', IsoNewEngland.location);
      var v = TransformedVariable(
          expression: "hourly_schedule(50, bucket='Peak')", label: 'peak');
      var env = <String, dynamic>{'_domain': term.interval};
      v.eval(env);
      var ts = env['peak'] as TimeSeries<num>;
      expect(ts.length, 4096);
      var out = <String, dynamic>{
        'type': 'TransformedVariable',
        'expression': "hourly_schedule(50, bucket='Peak')",
        'label': 'peak',
      };
      expect(v.toJson(), out);
      var v1 = TransformedVariable.fromJson(out);
      expect(v1.label, 'peak');
      expect(v1.expression, "hourly_schedule(50, bucket='Peak')");
    });

    test('TransformedVariable multi-line', () {
      var term = Term.parse('Jan21-Dec21', IsoNewEngland.location);
      var v = TransformedVariable(
          expression:
          "hourly_schedule(50, bucket='Peak') .+\n hourly_schedule(10, bucket='Offpeak')",
          label: 'flat');
      var env = <String, dynamic>{'_domain': term.interval};
      v.eval(env);
      var ts = env['flat'] as TimeSeries<num>;
      expect(ts.length, 8760);
    });

    test('VariableMarksAsOfDate', () {
      var out = <String, dynamic>{
        'type': 'VariableMarksAsOfDate',
        'asOfDate': '2023-07-07',
        'curveName': 'NG_HENRY_HUB_CME',
      };
      var v = VariableMarksAsOfDate.fromJson(out);
      expect(v.curveName, 'NG_HENRY_HUB_CME');
      expect(v.displayConfig, null);
      expect(v.toJson(), out);
    });

    test('VariableMarksHistoricalView', () {
      var out = <String, dynamic>{
        'type': 'VariableMarksHistoricalView',
        'label': 'HH',
        'curveName': 'NG_HENRY_HUB_CME',
        'forwardStrip': 'Cal 24',
      };
      var v = VariableMarksHistoricalView.fromJson(out);
      expect(v.curveName, 'NG_HENRY_HUB_CME');
      expect(v.displayConfig, null);
      expect(v.toJson(), out);
    });
  });

  group('Serde tests for Plotly Layout', () {
    test('default', () {
      var margin = PlotlyMargin()..left = 100;
      var out = {
        't': 80,
        'l': 100,
      };
      expect(margin.toJson(), out);
      var margin2 = PlotlyMargin.fromJson(out);
      expect(margin2.top, 80);
      expect(margin2.left, 100);
    });
  });

  group('Serde tests for Polygraph Window', () {
    test('Empty window', () {
      var window = PolygraphWindow.empty(size: const Size(900, 600));
      var today = Date.today(location: UTC);
      var term =
      Term(Month.containing(today.start).subtract(14).startDate, today);
      var out = {
        'term': term.toString(),
        'tzLocation': 'UTC',
        'xVariable': {
          'type': 'TimeVariable',
          'config': {
            'skipWeekends': false,
          }
        },
        'yVariables': [],
        'layout': {},
      };
      expect(window.toJson(), out);
      var window2 = PolygraphWindow.fromJson(out);
      expect(window2.yVariables.isEmpty, true);
    });

    test('Window with several variables', () {
      var term = Term.parse('Cal22', UTC);
      var xVariable = TimeVariable();
      var yVariables = <PolygraphVariable>[
        VariableMarksHistoricalView(
          curveName: 'NG_HENRY_HUB_CME',
          forwardStrip: Term.parse('Cal24', UTC),
          label: 'Henry',
        ),
        TransformedVariable(
            expression: "toMonthly(Henry, mean)", label: 'meanHenry')
      ];
      var layout = PlotlyLayout();
      var window = PolygraphWindow(
          term: term,
          xVariable: xVariable,
          yVariables: yVariables,
          layout: layout);
      var out = {
        'term': 'Cal 22',
        'tzLocation': 'UTC',
        'xVariable': {
          'type': 'TimeVariable',
          'config': {
            'skipWeekends': false,
          }
        },
        'yVariables': [
          {
            'type': 'VariableMarksHistoricalView',
            'curveName': 'NG_HENRY_HUB_CME',
            'forwardStrip': 'Cal 24',
            'label': 'Henry',
          },
          {
            'type': 'TransformedVariable',
            'expression': 'toMonthly(Henry, mean)',
            'label': 'meanHenry',
          },
        ],
        'layout': {},
      };
      expect(window.toJson(), out);
      var window2 = PolygraphWindow.fromJson(out);
      expect(window2.yVariables.length, 2);
    });
  });

  group('Serde tests for Polygraph Tab', () {
    test('General tab', () {
      var tab = PolygraphTab.getDefault();
      var out = <String, dynamic>{
        'name': 'Tab 1',
        'tabLayout': {
          'node': 'Single',
          'size': {'width': 900.0, 'height': 600.0}
        },
        'windows': [
          {
            'term': 'Cal 21',
            'tzLocation': 'America/New_York',
            'xVariable': {
              'type': 'TimeVariable',
              'config': {'skipWeekends': false}
            },
            'yVariables': [
              {
                'type': 'VariableLmp',
                'iso': 'ISONE',
                'market': 'DA',
                'ptid': 4000,
                'lmpComponent': 'lmp'
              },
              {
                'type': 'TransformedVariable',
                'label': 'monthly_mean',
                'expression': 'toMonthly(hub_da_lmp, mean)'
              }
            ],
            'layout': {
              'legend': {'orientation': 'h'}
            }
          }
        ]
      };
      expect(tab.toJson(), out);
      var tab2 = PolygraphTab.fromJson(out);
      expect(tab2.windows.first.yVariables.length, 2);
    });
  });

  group('Serde tests for Polygraph project', () {
    test('Simple project', () {
      var out = <String, dynamic>{
        'tabs': [
          {
            'name': 'Tab 1',
            'tabLayout': {
              'node': 'Single',
              'size': {'width': 900.0, 'height': 600.0}
            },
            'windows': [
              {
                'term': 'Cal 21',
                'tzLocation': 'America/New_York',
                'xVariable': {
                  'type': 'TimeVariable',
                  'config': {'skipWeekends': false}
                },
                'yVariables': [
                  {
                    'type': 'VariableLmp',
                    'iso': 'ISONE',
                    'market': 'DA',
                    'ptid': 4000,
                    'lmpComponent': 'lmp'
                  },
                  {
                    'type': 'TransformedVariable',
                    'label': 'monthly_mean',
                    'expression': 'toMonthly(hub_da_lmp, mean)'
                  }
                ],
                'layout': {
                  'legend': {'orientation': 'h'}
                }
              }
            ]
          },
          {
            'name': 'Tab 2',
            'tabLayout': {
              'node': 'Single',
              'size': {'width': 900.0, 'height': 600.0}
            },
            'windows': [
              {
                'term': 'Jan22-Feb22',
                'tzLocation': 'America/New_York',
                'xVariable': {
                  'type': 'TimeVariable',
                  'config': {'skipWeekends': false}
                },
                'yVariables': [
                  {
                    'type': 'TransformedVariable',
                    'label': 'shape',
                    'expression': 'hourly_schedule(50, bucket=\'Peak\')'
                  }
                ],
                'layout': {
                  'legend': {'orientation': 'h'}
                }
              }
            ]
          },
          {
            'name': 'Tab 3',
            'tabLayout': {
              'node': 'Single',
              'size': {'width': 900.0, 'height': 600.0}
            },
            'windows': [
              {
                'term': '1Jun22-8Aug23',
                'tzLocation': 'UTC',
                'xVariable': {
                  'type': 'TimeVariable',
                  'config': {'skipWeekends': false}
                },
                'yVariables': [],
                'layout': {}
              }
            ]
          }
        ]
      };
      var poly = PolygraphState.fromJson(out);
      expect(poly.toJson(), out);
    });
  });
}

///
void exportExampleProjects() {
  var dir = Directory('${Platform.environment['HOME']}/Downloads/Archive/Polygraph/Projects/Raw');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  exportProject1() {
    var poly = PolygraphState(tabs: [
      PolygraphTab(
          name: 'Tab 1',
          rootNode: SingleNode(900, 600),
          windows: [
            PolygraphWindow(
                term: Term.parse('Cal23', UTC),
                xVariable: TimeVariable(),
                yVariables: [
                  TransformedVariable(
                      expression: 'hourlySchedule(50)', label: 'shape')
                ],
                layout: PlotlyLayout())
          ],
          activeWindowIndex: 0)
    ], activeTabIndex: 0)
      ..userId = 'e47187'
      ..projectName = 'project 1';
    var out = const JsonEncoder.withIndent('  ').convert(poly.toJson());
    File('${dir.path}/project1.json').writeAsStringSync(out);
  }

  exportProject1();
}

Future<void> importExampleProjects(String rootUrl) async {
  test('e47187/project 1', () async {
    var poly = await PolygraphState.getProject('e47187', 'project 1');
  });

}


Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);

  await importExampleProjects(rootUrl);

  exportExampleProjects();
}

