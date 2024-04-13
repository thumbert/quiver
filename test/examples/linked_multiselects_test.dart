import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quiver/models/examples/linked_multiselects_model.dart';
import 'package:signals/signals_flutter.dart';

void main() {
  /// this effect needs to be registered here!
  final updateLocations = effect(() {
    selectedLocations.value = allLocations.value;
  });

  test('linked multiselects', () {
    expect(selectedIsos.value, {'PJM', 'ISONE', 'NYISO'});
    expect(labelIsos.value, '(All)');
    expect(labelLocations.value, '(All)');

    // select iso PJM
    selectedIsos.value = {'PJM'};
    expect(labelIsos.value, 'PJM');
    expect(allLocations.value, {'WH', 'BGE'});
    expect(selectedLocations.value, {'WH', 'BGE'});
    expect(labelLocations.value, '(All)');

    // select iso ISONE, NYISO
    selectedIsos.value = {'NYISO', 'ISONE'};
    expect(labelIsos.value, '(Some)');
    expect(allLocations.value, {'MH', 'ZoneA', 'ZoneG'});
    expect(selectedLocations.value, {'MH', 'ZoneA', 'ZoneG'});
    expect(labelLocations.value, '(All)');

    // drop one location
    selectedLocations.value = {'MH', 'ZoneA'};
    expect(labelLocations.value, '(Some)');
    expect(allLocations.value, {'MH', 'ZoneA', 'ZoneG'});

    updateLocations();
  });
}
