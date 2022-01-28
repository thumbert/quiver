library screens.ftr_path.region_source_sink;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/ftr_path/region_source_sink_model.dart';
import 'package:provider/provider.dart';

class RegionSourceSink extends StatefulWidget {
  const RegionSourceSink({Key? key}) : super(key: key);

  @override
  _RegionSourceSinkState createState() => _RegionSourceSinkState();
}

class _RegionSourceSinkState extends State<RegionSourceSink> {
  final focusNode = FocusNode();
  final sourceEditingController = TextEditingController();
  final sinkEditingController = TextEditingController();

  final _background = Colors.orange[100]!;

  @override
  void dispose() {
    sourceEditingController.dispose();
    sinkEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RegionSourceSinkModel>();

    return FutureBuilder(
        future: model.getNameMap(),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var nameToPtid = snapshot.data! as Map<String, int>;
            children = [
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
                      items: model.allowedRegions
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
                    margin: const EdgeInsetsDirectional.only(end: 6),
                    width: 250,
                    child: Autocomplete(
                      fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) =>
                          _AutocompleteField(
                        focusNode: focusNode,
                        textEditingController: textEditingController,
                        onFieldSubmitted: onFieldSubmitted,
                      ),
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue == TextEditingValue.empty) {
                          return const Iterable<String>.empty();
                        }
                        return nameToPtid.keys.where((e) =>
                            e.contains(textEditingValue.text.toUpperCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          model.sourceName = selection;
                        });
                      },
                      optionsMaxHeight: 350,
                    ),
                  ),
                ],
              ),
              //
              // Sink
              const SizedBox(
                width: 24,
              ),
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
                    margin: const EdgeInsetsDirectional.only(end: 6),
                    width: 250,
                    child: Autocomplete(
                      fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) =>
                          _AutocompleteField(
                        focusNode: focusNode,
                        textEditingController: textEditingController,
                        onFieldSubmitted: onFieldSubmitted,
                      ),
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue == TextEditingValue.empty) {
                          return const Iterable<String>.empty();
                        }
                        return nameToPtid.keys.where((e) =>
                            e.contains(textEditingValue.text.toUpperCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          model.sinkName = selection;
                          print('Selected sink: $selection');
                        });
                      },
                      optionsMaxHeight: 350,
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
  }) : super(key: key);

  final FocusNode focusNode;

  final VoidCallback onFieldSubmitted;

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(6, 10, 6, 10),
      ),
      controller: textEditingController,
      focusNode: focusNode,
      onFieldSubmitted: (String value) {
        onFieldSubmitted();
      },
    );
  }
}
