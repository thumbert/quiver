library screens.polygraph.editors.forward_asof;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/common/region.dart';

class ForwardAsof extends StatefulWidget {
  const ForwardAsof({Key? key}) : super(key: key);

  @override
  _ForwardAsofState createState() => _ForwardAsofState();
}

class _ForwardAsofState extends State<ForwardAsof> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Forward Term',
              style: TextStyle(fontSize: 16),
            ),
            Region(),
          ],
        ),
      ],
    );
  }
}
