library screens.common.ptid;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/ptid_model.dart';
import 'package:provider/provider.dart';

class Ptid extends StatefulWidget {
  const Ptid({Key? key}) : super(key: key);

  @override
  _PtidState createState() => _PtidState();
}

class _PtidState extends State<Ptid> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PtidModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 80,
          child: Text(
            'Ptid',
            style: TextStyle(fontSize: 16),
          ),
        ),
        TextField(
          controller: _controller,
          onSubmitted: (String value) {},
        ),
      ],
    );
  }
}
