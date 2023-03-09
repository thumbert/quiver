library screens.polygraph.editors.editor_line_horizontal;

import 'package:flutter/material.dart' hide Interval, Transform;
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/editors/horizontal_line.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfHorizontalLine =
  StateNotifierProvider<HorizontalLineNotifier, HorizontalLine>(
        (ref) => HorizontalLineNotifier(ref));

class HorizontalLineEditor extends ConsumerStatefulWidget {
  const HorizontalLineEditor({Key? key}) : super(key: key);

  @override
  ConsumerState<HorizontalLineEditor> createState() => _EditorLineHorizontalState();
}


class _EditorLineHorizontalState extends ConsumerState<HorizontalLineEditor> {
  final controllerYValue = TextEditingController();
  final controllerLabel = TextEditingController();

  final focusYValue = FocusNode();
  final focusLabel = FocusNode();

  String? _errorYValue;

  @override
  void initState() {
    super.initState();
    controllerYValue.text = '0.0';
    controllerLabel.text = '';

    // focusFrequency.addListener(() {
    //   if (!focusFrequency.hasFocus) {
    //     setState(() {
    //       if (needsFrequency || needsFunction) {
    //         // don't get yourself in a weird state
    //         ref.read(providerOfTimeAggregation.notifier).frequency = '';
    //         ref.read(providerOfTimeAggregation.notifier).function = '';
    //       } else {
    //         ref.read(providerOfTimeAggregation.notifier).frequency = controllerFrequency.text;
    //         ref.read(providerOfTimeAggregation.notifier).function = controllerFunction.text;
    //       }
    //     });
    //   }
    // });
    // focusFunction.addListener(() {
    //   if (!focusFunction.hasFocus) {
    //     setState(() {
    //       if (needsFrequency || needsFunction) {
    //         // don't get yourself in a weird state
    //         ref.read(providerOfTimeAggregation.notifier).frequency = '';
    //         ref.read(providerOfTimeAggregation.notifier).function = '';
    //       } else {
    //         ref.read(providerOfTimeAggregation.notifier).frequency = controllerFrequency.text;
    //         ref.read(providerOfTimeAggregation.notifier).function = controllerFunction.text;
    //       }
    //     });
    //   }
    // });

  }

  @override
  void dispose() {
    controllerYValue.dispose();
    controllerLabel.dispose();

    focusYValue.dispose();
    focusLabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(providerOfHorizontalLine);
    controllerYValue.text = state.yIntercept.toString();
    controllerLabel.text = state.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///
        /// Tabs
        ///
        Row(
          children: [
            Container(
              width: 120,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Text(
                'Frequency',
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),

        ///
        /// Tab contents
        ///
      ],
    );
  }
  
}


