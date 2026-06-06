import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/region_load_zone_model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

class RegionLoadZone extends StatefulWidget {
  const RegionLoadZone({super.key});

  @override
  _RegionLoadZoneState createState() => _RegionLoadZoneState();
}

class _RegionLoadZoneState extends State<RegionLoadZone> {
  final _background = Colors.orange[100]!;
  final _regionMenuController = MenuController();
  final _zoneMenuController = MenuController();

  Widget _buildMenuAnchor({
    required MenuController controller,
    required String? value,
    required List<String> items,
    required void Function(String) onSelected,
  }) {
    return MenuAnchor(
      controller: controller,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.grey[300]!),
        minimumSize: const WidgetStatePropertyAll(Size(100, 0)),
        maximumSize: const WidgetStatePropertyAll(Size(100, double.infinity)),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      menuChildren: [
        PointerInterceptor(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items
                .map(
                  (e) => InkWell(
                    onTap: () {
                      onSelected(e);
                      controller.close();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: SizedBox(width: 100, child: Text(e)),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
      builder: (context, controller, _) => PointerInterceptor(
        child: GestureDetector(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: Container(
            color: _background,
            padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Filter',
                    overflow: TextOverflow.ellipsis,
                    style: value == null
                        ? const TextStyle(color: Colors.grey)
                        : null,
                  ),
                ),
                const Icon(Icons.expand_more),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RegionLoadZoneModel>();

    return Row(
      children: [
        //
        // Region
        Container(
          padding: const EdgeInsets.only(right: 12),
          child: const Text(
            'Region',
            style: TextStyle(fontSize: 16),
          ),
        ),
        _buildMenuAnchor(
          controller: _regionMenuController,
          value: model.region,
          items: RegionLoadZoneModel.allowedRegions.keys.toList(),
          onSelected: (v) => setState(() => model.region = v),
        ),

        //
        // Load Zone
        Container(
          padding: const EdgeInsets.only(left: 24, right: 12),
          child: const Text(
            'Load Zone',
            style: TextStyle(fontSize: 16),
          ),
        ),
        _buildMenuAnchor(
          controller: _zoneMenuController,
          value: model.zoneName,
          items: ['(All)', ...model.getZoneNames()],
          onSelected: (v) => setState(() => model.zoneName = v),
        ),
      ],
    );
  }
}
