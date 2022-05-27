library screens.ftr_path.region_source_sink;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/models/ftr_path/region_source_sink_model.dart';
import 'package:provider/provider.dart';

class RegionSourceSink extends StatefulWidget {
  const RegionSourceSink({Key? key}) : super(key: key);

  @override
  _RegionSourceSinkState createState() => _RegionSourceSinkState();
}

class _RegionSourceSinkState extends State<RegionSourceSink> {
  final sourceFocusNode = FocusNode();
  final sinkFocusNode = FocusNode();
  final sourceEditingController = TextEditingController();
  final sinkEditingController = TextEditingController();

  final _background = Colors.orange[100]!;
  final maxOptionsHeight = 350.0;

  @override
  void initState() {
    final model = context.read<RegionSourceSinkModel>();
    sourceFocusNode.addListener(() {
      if (!sourceFocusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          if (!model.nameMap.keys.contains(sourceEditingController.text)) {
            model.sourceName =
                model.initialValues[model.region]!['sourceName'] as String;
          }
        });
      }
    });
    sinkFocusNode.addListener(() {
      if (!sinkFocusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          if (!model.nameMap.keys.contains(sinkEditingController.text)) {
            model.sinkName = model.initialValues[model.region]!['sinkName']
                as String; // wrong input, reset the field to empty
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    sourceEditingController.dispose();
    sinkEditingController.dispose();
    sourceFocusNode.dispose();
    sinkFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RegionSourceSinkModel>();
    sourceEditingController.text = model.sourceName;
    sinkEditingController.text = model.sinkName;

    return FutureBuilder(
        future: model.getNameMap(),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var nameToPtid = snapshot.data! as Map<String, int>;
            children = [
              //
              // Region
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: const Text(
                      'Region',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    color: _background,
                    padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
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
                      // alignment: AlignmentDirectional.bottomCenter,
                      onChanged: (String? newValue) {
                        setState(() {
                          model.region = newValue!;
                        });
                      },
                      items: model.allowedRegions.keys
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 24,
              ),
              //
              // Source
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: const Text(
                        'Source/From',
                        style: TextStyle(fontSize: 16),
                      )),
                  Container(
                    color: _background,
                    margin: const EdgeInsetsDirectional.only(end: 24),
                    width: 280,
                    child: RawAutocomplete(
                        focusNode: sourceFocusNode,
                        textEditingController: sourceEditingController,
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
                            model.sourceName = selection;
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
                                constraints:
                                    BoxConstraints(maxHeight: maxOptionsHeight),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: Builder(
                                          builder: (BuildContext context) {
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
                ],
              ),
              //
              // Sink
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: const Text(
                      'Sink/To',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    color: _background,
                    margin: const EdgeInsetsDirectional.only(end: 24),
                    width: 280,
                    child: RawAutocomplete(
                        focusNode: sinkFocusNode,
                        textEditingController: sinkEditingController,
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
                            model.sinkName = selection;
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
                                constraints:
                                    BoxConstraints(maxHeight: maxOptionsHeight),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: Builder(
                                          builder: (BuildContext context) {
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

                    // child: Autocomplete(
                    //   initialValue: TextEditingValue(
                    //       text: model.initialValues[model.region]!['sinkName']
                    //           as String),
                    //   fieldViewBuilder: (BuildContext context,
                    //           TextEditingController textEditingController,
                    //           FocusNode focusNode,
                    //           VoidCallback onFieldSubmitted) =>
                    //       _AutocompleteField(
                    //     focusNode: focusNode,
                    //     textEditingController: textEditingController,
                    //     onFieldSubmitted: onFieldSubmitted,
                    //     options: nameToPtid.keys,
                    //   ),
                    //   optionsBuilder: (TextEditingValue textEditingValue) {
                    //     if (textEditingValue == TextEditingValue.empty) {
                    //       return const Iterable<String>.empty();
                    //     }
                    //     return nameToPtid.keys.where((e) => e
                    //         .toUpperCase()
                    //         .contains(textEditingValue.text.toUpperCase()));
                    //   },
                    //   onSelected: (String selection) {
                    //     setState(() {
                    //       model.sinkName = selection;
                    //     });
                    //   },
                    //   optionsViewBuilder: (BuildContext context,
                    //       void Function(String) onSelected,
                    //       Iterable<String> options) {
                    //     return Align(
                    //       alignment: Alignment.topLeft,
                    //       child: Material(
                    //         elevation: 4.0,
                    //         child: ConstrainedBox(
                    //           constraints:
                    //               BoxConstraints(maxHeight: maxOptionsHeight),
                    //           child: ListView.builder(
                    //             padding: EdgeInsets.zero,
                    //             shrinkWrap: true,
                    //             itemCount: options.length,
                    //             itemBuilder: (BuildContext context, int index) {
                    //               final option = options.elementAt(index);
                    //               return InkWell(
                    //                 onTap: () {
                    //                   onSelected(option);
                    //                 },
                    //                 child: Builder(
                    //                     builder: (BuildContext context) {
                    //                   final bool highlight =
                    //                       AutocompleteHighlightedOption.of(
                    //                               context) ==
                    //                           index;
                    //                   if (highlight) {
                    //                     SchedulerBinding.instance!
                    //                         .addPostFrameCallback(
                    //                             (Duration timeStamp) {
                    //                       Scrollable.ensureVisible(context,
                    //                           alignment: 0.5);
                    //                     });
                    //                   }
                    //                   return Container(
                    //                     color: highlight
                    //                         ? Theme.of(context).focusColor
                    //                         : null,
                    //                     padding: const EdgeInsets.all(16.0),
                    //                     child: Text(option),
                    //                   );
                    //                 }),
                    //               );
                    //             },
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ),
                ],
              ),
              //
              // Bucket
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: const Text(
                      'Bucket',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    color: _background,
                    padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
                    width: 100,
                    child: DropdownButtonFormField(
                      value: model.bucket,
                      icon: const Icon(Icons.expand_more),
                      hint: const Text('Filter'),
                      decoration: const InputDecoration(
                        isDense: true,
                        enabledBorder: InputBorder.none,
                      ),
                      elevation: 16,
                      // alignment: AlignmentDirectional.bottomCenter,
                      onChanged: (String? newValue) {
                        setState(() {
                          model.bucket = newValue!;
                        });
                      },
                      items: model
                          .allowedBuckets()
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                ],
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: children);
          }
          return Row(
            children: children,
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
        contentPadding: EdgeInsets.fromLTRB(6, 10, 6, 10),
        // errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red),),
        // focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red),),
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
