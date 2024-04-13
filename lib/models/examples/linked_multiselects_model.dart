import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:signals/signals_flutter.dart';

// setup() {
final data = <Map<String, dynamic>>[
  {'iso': 'PJM', 'location': 'WH', 'strip': 'Cal24', 'price': 10},
  {'iso': 'PJM', 'location': 'WH', 'strip': 'Cal25', 'price': 12},
  {'iso': 'PJM', 'location': 'WH', 'strip': 'Cal26', 'price': 14},
  {'iso': 'PJM', 'location': 'BGE', 'strip': 'Cal24', 'price': 10},
  {'iso': 'PJM', 'location': 'BGE', 'strip': 'Cal26', 'price': 14.3},
  {'iso': 'ISONE', 'location': 'MH', 'strip': 'Cal24', 'price': 11},
  {'iso': 'NYISO', 'location': 'ZoneA', 'strip': 'Cal26', 'price': 7.3},
  {'iso': 'NYISO', 'location': 'ZoneG', 'strip': 'Cal24', 'price': 13},
].toSignal();

/// ISOs
final allIsos = computed(() => data.map<String>((e) => e['iso']).toSet());
final selectedIsos = {...allIsos.value}.toSignal();
final labelIsos = computed(() {
  if (selectedIsos.isEmpty) return SelectionState.none.toString();
  if (selectedIsos.length == 1) return selectedIsos.first;
  if (allIsos.value.length == selectedIsos.value.length) {
    return SelectionState.all.toString();
  } else {
    return SelectionState.some.toString();
  }
});
final tempSelectionIso = <String>{}.toSignal();

/// Locations
final allLocations = computed(() {
  return data
      .where((e) => selectedIsos.value.contains(e['iso']))
      .map<String>((e) => e['location'])
      .toSet();
});
final selectedLocations = {...allLocations.value}.toSignal();
final labelLocations = computed(() {
  if (selectedLocations.isEmpty) return SelectionState.none.toString();
  if (selectedLocations.length == 1) return selectedLocations.first;
  if (allLocations.value.length == selectedLocations.value.length) {
    return SelectionState.all.toString();
  } else {
    return SelectionState.some.toString();
  }
});
final tempSelectionLocation = <String>{}.toSignal();

// Strips
final allStrips = computed(() {
  return data
      .where((e) => selectedIsos.value.contains(e['iso']))
      .where((e) => selectedLocations.value.contains(e['location']))
      .map<String>((e) => e['strip'])
      .toSet();
});
final selectedStrips = {...allStrips.value}.toSignal();
final labelStrips = computed(() {
  if (selectedStrips.isEmpty) return SelectionState.none.toString();
  if (selectedStrips.length == 1) return selectedStrips.first;
  if (allStrips.value.length == selectedStrips.value.length) {
    return SelectionState.all.toString();
  } else {
    return SelectionState.some.toString();
  }
});
final tempSelectionStrip = <String>{}.toSignal();
