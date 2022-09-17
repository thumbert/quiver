library models.pool_load_stats;

import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfPoolLoadStats = StateNotifierProvider<PoolLoadStatsNotifier, PoolLoadStatsState>(
    (ref) => PoolLoadStatsNotifier(PoolLoadStatsState.getDefault()));

class PoolLoadStatsState {
  PoolLoadStatsState({required this.region, required this.zone});

  final String region;
  final String zone;

  static Map<String, List<String>> allRegions = {
    'ISONE': ['Maine', 'NH', 'VT', 'CT', 'RI', 'SEMA', 'WCMA', 'NEMA'],
    'PJM': ['AE', 'AEP', 'APS', 'ATSI', 'BC', 'COMED'],
    'NYISO': ['A', 'B', 'C', 'D', 'K']
  };

  static PoolLoadStatsState getDefault() =>
      PoolLoadStatsState(region: 'NYISO', zone: '(All)');

  PoolLoadStatsState copyWith({String? region, String? zone}) {
    return PoolLoadStatsState(
        region: region ?? this.region, zone: zone ?? this.zone);
  }
}

class PoolLoadStatsNotifier extends StateNotifier<PoolLoadStatsState> {
  PoolLoadStatsNotifier(PoolLoadStatsState state) : super(state);

  void region(String value) {
    state = state.copyWith(region: value);
  }
}
