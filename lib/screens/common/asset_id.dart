library screens.common.asset_id;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/asset_id_model.dart';
import 'package:provider/provider.dart';

class AssetId extends StatefulWidget {
  const AssetId({Key? key}) : super(key: key);

  @override
  _AssetIdState createState() => _AssetIdState();
}

class _AssetIdState extends State<AssetId> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller.text = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AssetIdModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 80,
          child: Tooltip(
            message:
                'Enter one asset id or several asset ids separated by commas',
            child: Text(
              'Asset Id',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 100,
            maxWidth: 300,
          ),
          child: TextField(
            controller: _controller,
            maxLines: 1,
            decoration: InputDecoration(
              // hintText: '2481',
              errorText: _error,
              isDense: true,
              // enabledBorder: UnderlineInputBorder(
              //     borderSide:
              //         BorderSide(color: Theme.of(context).primaryColor))
            ),
            onChanged: (String? value) {
              setState(() {
                var _ids = value!
                    .split(',')
                    .map((e) => int.tryParse(e.trim()))
                    .toList();
                if (_ids.every((e) => e != null)) {
                  model.ids = _ids.cast<int>();
                } else {
                  _error =
                      'Enter either an asset id, e.g. 2481, or a comma separated list of ids';
                }
              });
            },
          ),
        ),
      ],
    );
  }
}
