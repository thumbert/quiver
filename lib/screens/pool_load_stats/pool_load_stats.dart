library screens.pool_load_stats.pool_load_stats;

import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/pool_load_stats/pool_load_stats_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PoolLoadStats extends ConsumerWidget {
  const PoolLoadStats({Key? key}) : super(key: key);

  static const route = '/pool_load_stats';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerOfPoolLoadStats);
    print(state.region);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pool load statistics'),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Region',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12,),
                  SizedBox(
                    width: 150,
                    child: DropdownButtonFormField(
                      value: state.region,
                      icon: const Icon(Icons.expand_more),
                      hint: const Text('Filter'),
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor))),
                      elevation: 16,
                      onChanged: (String? newValue) {
                        ref
                            .read(providerOfPoolLoadStats.notifier)
                            .region(newValue!);
                        print(state.region);
                      },
                      items: PoolLoadStatsState.allRegions.keys
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
