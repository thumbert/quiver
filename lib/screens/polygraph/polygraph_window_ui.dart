library lib.screens.polygraph.polygraph_window_ui;

import 'package:date/date.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_display_config.dart';
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:timezone/timezone.dart';

class PolygraphWindowUi extends ConsumerStatefulWidget {
  const PolygraphWindowUi({Key? key}) : super(key: key);

  @override
  _PolygraphWindowState createState() => _PolygraphWindowState();
}

class _PolygraphWindowState extends ConsumerState<PolygraphWindowUi> {
  final controllerTerm = TextEditingController();
  final controllerTimezone = TextEditingController();
  
  final focusNodeTerm = FocusNode();
  final focusTimezone = FocusNode();

  String? _errorTerm;
  late Plotly plotly;

  @override
  void initState() {
    super.initState();

    controllerTerm.text = ref.read(providerOfPolygraphWindow).term.toString();
    controllerTimezone.text = ref.read(providerOfPolygraphWindow).timezone.toString();


    focusNodeTerm.addListener(() {
      if (!focusNodeTerm.hasFocus) {
        /// validate when you lose focus
        setState(() {
          try {
            ref.read(providerOfPolygraphWindow.notifier).term =
                Term.parse(controllerTerm.text, UTC);
            _errorTerm = null; // all good
          } catch (e) {
            debugPrint(e.toString());
            _errorTerm = 'Parsing error';
          }
        });
      }
    });

    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'polygraph-div-$aux',
      data: const [],
      layout: PolygraphState.layout, // TODO:  move it from here!
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(providerOfPolygraphWindow);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 700, height: 550, color: Colors.grey[200],),
        const SizedBox(
          height: 12,
        ),

        /// Term, Timezone
        Row(
          children: [
            const Text('Term'),
            const SizedBox(width: 8,),
            SizedBox(
                width: 140,
                child: TextField(
                  focusNode: focusNodeTerm,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    enabledBorder: InputBorder.none,
                    fillColor: MyApp.background,
                    filled: true,
                  ),
                  controller: controllerTerm,

                  /// validate when Enter is pressed
                  onEditingComplete: () {
                    setState(() {
                      try {
                        ref.read(providerOfPolygraphWindow.notifier).term =
                            Term.parse(controllerTerm.text, UTC);
                        _errorTerm = null; // all good
                      } catch (e) {
                        debugPrint(e.toString());
                        _errorTerm = 'Parsing error';
                      }
                    });
                  },
                )),
            const SizedBox(width: 32,),
            const Text('Timezone'),
            const SizedBox(width: 8,),
            Container(
              color: MyApp.background,
              width: 150,
              padding: const EdgeInsets.all(0),
              child: RawAutocomplete(
                  focusNode: focusTimezone,
                  textEditingController: controllerTimezone,
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) =>
                      AutocompleteField(
                        focusNode: focusNode,
                        textEditingController: textEditingController,
                        onFieldSubmitted: onFieldSubmitted,
                        options: TimeVariable.timezones,
                      ),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue == TextEditingValue.empty) {
                      return const Iterable<String>.empty();
                    }
                    var aux = TimeVariable.timezones.where((e) => e
                        .toUpperCase()
                        .contains(textEditingValue.text.toUpperCase())).toList();
                    return aux;
                  },
                  onSelected: (String selection) {
                    setState(() {
                      var location = selection == 'UTC' ? UTC : getLocation(selection);
                      ref.read(providerOfPolygraphWindow.notifier).timezone = location;
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
                          const BoxConstraints(maxHeight: 300, maxWidth: 200),
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
                                        padding: const EdgeInsets.all(8.0),
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
            const SizedBox(width: 32,),
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        children: [
                          SizedBox(
                            width: 500,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                    onPressed: () {},
                                    child: const Text('Load/Save')),
                              ],
                            ),
                          )
                        ],
                        contentPadding: const EdgeInsets.all(12),
                      );
                    });
              },
              icon: const Icon(Icons.table_rows),
              tooltip: 'View data',
            ),
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        children: [
                          SizedBox(
                            width: 500,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                    onPressed: () {},
                                    child: const Text('Load/Save')),
                              ],
                            ),
                          )
                        ],
                        contentPadding: const EdgeInsets.all(12),
                      );
                    });
              },
              icon: const Icon(Icons.summarize),
              tooltip: 'View data summary',
            ),


            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (String item) {
                setState(() {
                  // selectedMenu = item;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'refresh',
                  child: Row(
                    children: const [
                      Icon(Icons.refresh, color: Colors.blue,),
                      SizedBox(width: 16,),
                      Text('Refresh data'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'raw_data',
                  child: Text('Raw Data'),
                ),
              ],
            ),

          ],
        ),
        const SizedBox(
          height: 12,
        ),

        ///
        /// The variables
        ///
        Wrap(
          direction: Axis.horizontal,
          spacing: 36,
          children: [
            // X axis
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 0, bottom: 0),
                  child: Text(
                    'X axis',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    state.xVariable.name,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 0, top: 0, bottom: 0),
                    alignment: Alignment.centerLeft,
                    // backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
            // Y axis
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Y axis',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                ),
                //
                //
                // Add all the y variables
                //
                //
                ...[
                  for (var i = 0; i < state.yVariables.length; i++)
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          state.yVariables[i].isMouseOver = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          state.yVariables[i].isMouseOver = false;
                        });
                      },
                      child: Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              state.yVariables[i].label,
                              style: TextStyle(
                                  color: state.yVariables[i].isHidden
                                      ? Colors.grey
                                      : state.yVariables[i].color ??
                                          VariableDisplayConfig
                                              .defaultColors[i],
                                  decoration: state.yVariables[i].isHidden
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontSize: 16),
                            ),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.only(left: 0, right: 150),
                            ),
                          ),

                          /// show the icons only on hover ...
                          if (state.yVariables[i].isMouseOver)
                            Row(
                              children: [
                                /// Add
                                IconButton(
                                  tooltip: 'Add',
                                  onPressed: () async {
                                    setState(() {
                                      // variableModel.editedIndex = i + 1;
                                    });
                                    await showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              elevation: 24.0,
                                              title: const Text('Select'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Text('Boo'),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                    child: const Text('CANCEL'),
                                                    onPressed: () {
                                                      /// ignore changes the changes
                                                      Navigator.of(context)
                                                          .pop();
                                                    }),
                                                ElevatedButton(
                                                    child: const Text('OK'),
                                                    onPressed: () {
                                                      /// harvest the values
                                                      Navigator.of(context)
                                                          .pop();
                                                    }),
                                              ]);
                                        });
                                  },
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(),
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 0),
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.blueGrey[300],
                                    size: 20,
                                  ),
                                ),

                                /// Edit
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () async {
                                    setState(() {
                                      // variableModel.editedIndex = i + 1;
                                    });
                                    await showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              elevation: 24.0,
                                              title: const Text('Select'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Text('Boo'),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                    child: const Text('CANCEL'),
                                                    onPressed: () {
                                                      /// ignore changes the changes
                                                      Navigator.of(context)
                                                          .pop();
                                                    }),
                                                ElevatedButton(
                                                    child: const Text('OK'),
                                                    onPressed: () {
                                                      /// harvest the values
                                                      Navigator.of(context)
                                                          .pop();
                                                    }),
                                              ]);
                                        });
                                  },
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(),
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 0),
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blueGrey[300],
                                    size: 20,
                                  ),
                                ),

                                /// Remove
                                IconButton(
                                  tooltip: 'Remove',
                                  onPressed: () {
                                    setState(() {
                                      // variableModel.removeVariableAt(i);
                                    });
                                  }, // delete the sucker
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(),
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 0),
                                  icon: Icon(
                                    Icons.delete_forever,
                                    color: Colors.blueGrey[300],
                                    size: 20,
                                  ),
                                ),

                                /// Copy
                                IconButton(
                                  tooltip: 'Copy',
                                  onPressed: () {
                                    setState(() {
                                      // variableModel.copy(i);
                                    });
                                  }, // delete the sucker
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(),
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 0),
                                  icon: Icon(
                                    Icons.copy,
                                    color: Colors.blueGrey[300],
                                    size: 20,
                                  ),
                                ),

                                /// Hide/Show
                                IconButton(
                                  tooltip: 'Hide/Show',
                                  onPressed: () {
                                    setState(() {
                                      state.yVariables[i].isHidden =
                                          !state.yVariables[i].isHidden;
                                    });
                                  },
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(),
                                  padding:
                                      const EdgeInsets.only(left: 0, right: 0),
                                  icon: Icon(
                                    Icons.format_strikethrough,
                                    color: Colors.blueGrey[300],
                                    size: 20,
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
