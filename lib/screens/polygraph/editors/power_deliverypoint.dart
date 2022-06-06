library screens.polygraph.editors.power_deliverypoint;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PowerDeliveryPoint extends ConsumerStatefulWidget {
  const PowerDeliveryPoint({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PowerDeliveryPointState();
}

class _PowerDeliveryPointState extends ConsumerState<PowerDeliveryPoint> {
  final focusNode = FocusNode();
  final editingController = TextEditingController();

  final _background = Colors.orange[100]!;
  final maxOptionsHeight = 350.0;

  @override
  void initState() {
    final model = ref.read(providerOfPowerLocation);
    editingController.text = model.deliveryPoint;

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        var map = model.cacheNameMap[model.region]!;

        /// validate when you lose focus (Tab out of the field)
        setState(() {
          if (!map.keys.contains(editingController.text)) {
            ref.read(providerOfPowerLocation.notifier).deliveryPoint =
                PowerLocation.allRegions[model.region]!.item2;
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    editingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(providerOfPowerLocation);

    return FutureBuilder(
      future: model.getNameMap(),
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          var nameToPtid = snapshot.data! as Map<String, int>;
          editingController.text = model.deliveryPoint;
          children = [
            Container(
              color: _background,
              width: 280,
              child: RawAutocomplete(
                  focusNode: focusNode,
                  textEditingController: editingController,
                  fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) =>
                      _AutocompleteField(
                        focusNode: focusNode,
                        textEditingController: textEditingController,
                        onFieldSubmitted: onFieldSubmitted,
                        options: nameToPtid.keys,
                      ),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue == TextEditingValue.empty) {
                      return const Iterable<String>.empty();
                    }
                    return nameToPtid.keys.where((e) => e
                        .toUpperCase()
                        .contains(textEditingValue.text.toUpperCase()));
                  },
                  onSelected: (String selection) {
                    setState(() {
                      ref.read(providerOfPowerLocation.notifier).deliveryPoint =
                          selection;
                    });
                  },
                  optionsViewBuilder: (BuildContext context,
                      void Function(String) onSelected,
                      Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: maxOptionsHeight, maxWidth: 280),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final option = options.elementAt(index);
                              return InkWell(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: Builder(builder: (BuildContext context) {
                                  final bool highlight =
                                      AutocompleteHighlightedOption.of(
                                              context) ==
                                          index;
                                  if (highlight) {
                                    SchedulerBinding.instance
                                        .addPostFrameCallback(
                                            (Duration timeStamp) {
                                      Scrollable.ensureVisible(context,
                                          alignment: 0.5);
                                    });
                                  }
                                  return Container(
                                    color: highlight
                                        ? Theme.of(context).focusColor
                                        : null,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ];
        } else if (snapshot.hasError) {
          children = [
            const Icon(Icons.error_outline, color: Colors.red),
            Text(
              snapshot.error.toString(),
              style: const TextStyle(fontSize: 16),
            )
          ];
        } else {
          children = [
            const SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                )),
          ];
          // the only way I found to keep the progress indicator centered
          return Row(
              mainAxisAlignment: MainAxisAlignment.center, children: children);
        }
        return Row(
          children: children,
        );
      },
    );
  }
}

class _AutocompleteField extends StatelessWidget {
  const _AutocompleteField({
    Key? key,
    required this.focusNode,
    required this.textEditingController,
    required this.onFieldSubmitted,
    required this.options,
  }) : super(key: key);

  final FocusNode focusNode;

  final VoidCallback onFieldSubmitted;

  final TextEditingController textEditingController;

  final Iterable<String> options;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(6, 11, 6, 11),
        border: InputBorder.none,
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      controller: textEditingController,
      focusNode: focusNode,
      onFieldSubmitted: (String value) {
        onFieldSubmitted();
      },
      // I don't seem to hit the validator!
      // validator: (String? value) {
      //   print('in validator!');
      //   if (!options.contains(value)) {
      //     print('Oops, wrong value!');
      //     return 'Nothing selected.';
      //   }
      //   return null;
      // },
    );
  }
}
