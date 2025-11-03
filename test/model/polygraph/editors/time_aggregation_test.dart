import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests() async {
  group('TimeAggregation test', () {
    test('check error', () {
      expect(
          (TimeAggregation(frequency: 'month', function: 'count')..validate())
              .error,
          '');
      expect(
          (TimeAggregation(frequency: 'month', function: '')..validate()).error,
          'Function can\'t be empty');
      expect(
          (TimeAggregation(frequency: '', function: 'mean')..validate()).error,
          'Frequency can\'t be empty');
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  await tests();
}
