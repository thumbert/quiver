library screens.homepage.calculator_list;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quiver/models/homepage/homepage_model.dart';
import 'package:flutter_quiver/screens/ftr_path/ftr_path.dart';

class AppGroup extends StatefulWidget {
  const AppGroup(this.groupName, {Key? key}) : super(key: key);

  final String groupName;

  static final Map<String, List<MenuItem>> groups = {
    'Load': [
      MenuItem(url: '/demand_bids', title: 'Demand Bids, RT Load & Forecast'),
      MenuItem(url: '/load_settlements', title: 'Load Settlements'),
      MenuItem(url: '/historical_plc', title: 'Historical PLC'),
      MenuItem(url: '/vlr_stage_2', title: 'Realized Stage 2 VLR'),
    ],
    //
    'Reports': [
      MenuItem(
          url: '/realized_ancillaries_load',
          title: 'Realized ancillaries load'),
      MenuItem(url: '/gen_revenues', title: 'Generation revenues'),
      MenuItem(url: '/monthly_asset_ncpc', title: 'Monthly asset NCPC (all)'),
    ],
    //
    'Other': [
      MenuItem(url: FtrPath.route, title: 'FTR path analysis'),
      MenuItem(
          url: '/mcc_surfer',
          title: 'MCC surfer ',
          icon: const Icon(Icons.surfing)),
      MenuItem(url: '/monthly_lmp', title: 'Monthly LMP'),
      MenuItem(url: '/unmasked_energy_offers', title: 'Energy Offers (all)'),
      MenuItem(url: '/weather', title: 'Weather'),
    ],
  };

  @override
  _AppGroupState createState() => _AppGroupState();
}

class _AppGroupState extends State<AppGroup> {
  _AppGroupState();

  @override
  Widget build(BuildContext context) {
    var groupItems = AppGroup.groups[widget.groupName]!;

    return Container(
      width: 400,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
      // decoration: const BoxDecoration(color: Colors.blueGrey),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMenuGroupHeader(title: widget.groupName),
            for (final item in groupItems) ...[
              _buildMenuItem(item),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroupHeader({
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.blueGrey.shade700,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white, //Color(0xFF303030),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            item.isHighlighted = true;
          });
        },
        onExit: (_) {
          setState(() {
            item.isHighlighted = false;
          });
        },
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          dense: true,
          leading: Icon(
            Icons.label_important_outline,
            color:
                item.isHighlighted ? Colors.orange : Colors.blueGrey.shade400,
          ),
          // trailing: item.icon,
          title: Transform.translate(
            offset: const Offset(-20, 0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                if (item.icon != null) item.icon!,
              ],
            ),
          ),
          onTap: () {
            context.go(item.url);
          },
        ),
      ),
    );
  }
}
