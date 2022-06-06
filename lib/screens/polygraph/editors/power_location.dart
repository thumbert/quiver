library polygraph.editors.power_location;

import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/polygraph/editors/lmp_component.dart'
    as ui;
import 'package:flutter_quiver/screens/polygraph/editors/power_deliverypoint.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_market.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elec_server/client/other/ptids.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tuple/tuple.dart';

final providerOfPowerLocation =
    StateNotifierProvider<PowerLocationNotifier, PowerLocation>(
        (ref) => PowerLocationNotifier(ref));

class PowerLocation {
  PowerLocation({
    required this.region,
    required this.deliveryPoint,
    required this.market,
    required this.component,
  });

  late final String region;
  late final String deliveryPoint;
  late final Market market;
  late final LmpComponent component;

  PowerLocation copyWith(
      {String? region,
      String? deliveryPoint,
      Market? market,
      LmpComponent? component}) {
    if (region != null) {
      /// when you change the region set the delivery point to the default
      deliveryPoint = PowerLocation.allRegions[region]!.item2;
    }
    return PowerLocation(
        region: region ?? this.region,
        deliveryPoint: deliveryPoint ?? this.deliveryPoint,
        market: market ?? this.market,
        component: component ?? this.component);
  }

  /// All supported regions and the default location
  static final allRegions = <String, Tuple2<Iso, String>>{
    'ISONE': Tuple2(Iso.newEngland, '.H.INTERNAL_HUB, ptid: 4000'),
    'NYISO': Tuple2(Iso.newYork, 'Zone G, ptid: 61758'),
  };

  final PtidsApi ptidClient =
      PtidsApi(http.Client(), rootUrl: dotenv.env['ROOT_URL']!);

  /// A cache of region -> nodeName -> ptid
  /// Exposing this so you can restrict or maybe add nodes on top of what
  /// already exist in the database.
  final cacheNameMap = <String, Map<String, int>>{};

  /// Map the String that shows up in the TextField to the ptid
  ///
  Future<Map<String, int>> getNameMap() async {
    if (!cacheNameMap.containsKey(region)) {
      cacheNameMap[region] = <String, int>{};
      var aux = await ptidClient.getPtidTable(region: region.toLowerCase());
      if (region == 'NYISO') {
        /// add the zones first, in a spoken form (the alphabet soup)
        var zones = aux.where((e) => e['type'] == 'zone');
        for (var zone in zones) {
          if (zone.containsKey('spokenName')) {
            var label = '${zone['spokenName']}, ptid: ${zone['ptid']}';
            cacheNameMap[region]![label] = zone['ptid'];
          }
        }
      }
      if (aux.isNotEmpty) {
        cacheNameMap[region]!.addAll(
            {for (var e in aux) '${e['name']}, ptid: ${e['ptid']}': e['ptid']});
      }
    }
    return cacheNameMap[region]!;
  }
}

class PowerLocationNotifier extends StateNotifier<PowerLocation> {
  PowerLocationNotifier(this.ref)
      : super(PowerLocation(
            region: 'ISONE',
            deliveryPoint: '.H.INTERNAL_HUB, ptid: 4000',
            market: Market.da,
            component: LmpComponent.lmp));

  final Ref ref;

  set region(String value) {
    state = state.copyWith(region: value);
  }

  set deliveryPoint(String value) {
    state = state.copyWith(deliveryPoint: value);
  }

  set market(String value) {
    state = state.copyWith(market: Market.parse(value));
  }

  set component(LmpComponent value) {
    state = state.copyWith(component: value);
  }
}

class PowerLocationUi extends ConsumerStatefulWidget {
  const PowerLocationUi({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PowerLocationUiState();
}

class _PowerLocationUiState extends ConsumerState<PowerLocationUi> {
  final _background = Colors.orange[100]!;
  final maxOptionsHeight = 350.0;

  final focusNode = FocusNode();
  final editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(providerOfPowerLocation);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Region
            //
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Region',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      color: _background,
                      padding:
                          const EdgeInsetsDirectional.only(start: 6, end: 6),
                      width: 100,
                      child: DropdownButtonFormField(
                        value: model.region,
                        icon: const Icon(Icons.expand_more),
                        hint: const Text('Filter'),
                        decoration: const InputDecoration(
                          isDense: true,
                          enabledBorder: InputBorder.none,
                        ),
                        elevation: 16,
                        onChanged: (String? newValue) {
                          setState(() {
                            ref.read(providerOfPowerLocation.notifier).region =
                                newValue!;
                          });
                        },
                        items: PowerLocation.allRegions.keys
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                      ),
                    ),
                  ]),
            ),
            // Location
            //
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Location',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    PowerDeliveryPoint(),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Market',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                        color: _background,
                        width: 100,
                        child: const PowerMarket()),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Component',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                        color: _background,
                        width: 140,
                        child: const ui.LmpComponent()),
                  ]),
            ),
          ],
        ),
      ],
    );
  }
}
