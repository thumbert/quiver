library screens.common.maybe_bucket;

import 'package:elec/elec.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Bucket autocomplete field that allows for no bucket input (Null value.)
///

final providerOfMaybeBucket =
    StateNotifierProvider<MaybeBucketNotifier, Bucket?>(
        (ref) => MaybeBucketNotifier(ref));

class MaybeBucketNotifier extends StateNotifier<Bucket?> {
  MaybeBucketNotifier(this.ref) : super(null);
  final Ref ref;

  static List<String> allowedValues = ['', 'ATC', 'Peak', 'Offpeak'];

  set bucket(Bucket? value) {
    state = value;
  }
}

class MaybeBucketUi extends ConsumerStatefulWidget {
  const MaybeBucketUi({Key? key}) : super(key: key);

  @override
  ConsumerState<MaybeBucketUi> createState() => _BucketState();
}

class _BucketState extends ConsumerState<MaybeBucketUi> {
  final focusNode = FocusNode();
  final editingController = TextEditingController();
  final maxOptionsHeight = 350.0;

  @override
  void initState() {
    editingController.text = '';

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          if (!MaybeBucketNotifier.allowedValues
              .contains(editingController.text)) {
            ref.read(providerOfMaybeBucket.notifier).bucket = null;
            editingController.text = '';
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
    return RawAutocomplete(
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
              options: MaybeBucketNotifier.allowedValues,
            ),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue == TextEditingValue.empty) {
            return const Iterable<String>.empty();
          }
          return MaybeBucketNotifier.allowedValues.where((e) =>
              e.toUpperCase().contains(textEditingValue.text.toUpperCase()));
        },
        onSelected: (String selection) {
          setState(() {
            if (selection == '') {
              ref.read(providerOfMaybeBucket.notifier).bucket = null;
            } else {
              ref.read(providerOfMaybeBucket.notifier).bucket =
                  Bucket.parse(selection);
            }
          });
        },
        optionsViewBuilder: (BuildContext context,
            void Function(String) onSelected, Iterable<String> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxHeight: maxOptionsHeight, maxWidth: 150),
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
                            AutocompleteHighlightedOption.of(context) == index;
                        if (highlight) {
                          SchedulerBinding.instance
                              .addPostFrameCallback((Duration timeStamp) {
                            Scrollable.ensureVisible(context, alignment: 0.5);
                          });
                        }
                        return Container(
                          color:
                              highlight ? Theme.of(context).focusColor : null,
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
        });
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
