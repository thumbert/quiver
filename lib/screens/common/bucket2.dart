library screens.common.bucket2;

import 'package:elec/elec.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfBucket =
    StateNotifierProvider<BucketNotifier, Bucket>((ref) => BucketNotifier(ref));

class BucketNotifier extends StateNotifier<Bucket> {
  BucketNotifier(this.ref) : super(Bucket.atc);
  final Ref ref;

  static List<String> allowedValues = ['ATC', 'Peak', 'Offpeak'];

  set bucket(Bucket value) {
    state = value;
  }
}

class BucketUi extends ConsumerStatefulWidget {
  const BucketUi({Key? key}) : super(key: key);

  @override
  ConsumerState<BucketUi> createState() => _BucketState();
}

class _BucketState extends ConsumerState<BucketUi> {
  final focusNode = FocusNode();
  final editingController = TextEditingController();

  final _background = Colors.orange[100]!;
  final maxOptionsHeight = 350.0;

  @override
  void initState() {
    editingController.text = ref.read(providerOfBucket).toString();

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          if (!BucketNotifier.allowedValues.contains(editingController.text)) {
            ref.read(providerOfBucket.notifier).bucket =
                Bucket.parse(BucketNotifier.allowedValues.first);
            editingController.text = BucketNotifier.allowedValues.first;
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
    // final model = context.watch<BucketModel>();

    return Container(
      color: _background,
      width: 100,
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
                options: BucketNotifier.allowedValues,
              ),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue == TextEditingValue.empty) {
              return const Iterable<String>.empty();
            }
            return BucketNotifier.allowedValues.where((e) =>
                e.toUpperCase().contains(textEditingValue.text.toUpperCase()));
          },
          onSelected: (String selection) {
            setState(() {
              ref.read(providerOfBucket.notifier).bucket =
                  Bucket.parse(selection);
            });
          },
          optionsViewBuilder: (BuildContext context,
              void Function(String) onSelected, Iterable<String> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: maxOptionsHeight, maxWidth: 150),
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
                              AutocompleteHighlightedOption.of(context) ==
                                  index;
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
          }),

      // child: DropdownButtonFormField(
      //   value: model.bucket,
      //   icon: const Icon(Icons.expand_more),
      //   hint: const Text('Filter'),
      //   decoration: InputDecoration(
      //       enabledBorder: UnderlineInputBorder(
      //           borderSide: BorderSide(color: Theme.of(context).primaryColor))),
      //   elevation: 16,
      //   onChanged: (String? newValue) {
      //     setState(() {
      //       model.bucket = newValue!;
      //     });
      //   },
      //   items: BucketMixin.allowedBuckets
      //       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
      //       .toList(),
      // ),
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
