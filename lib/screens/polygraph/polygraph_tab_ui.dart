library lib.screens.polygraph.polygraph_tab_ui;

import 'package:date/date.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/screens/polygraph/other/variable_selection_ui.dart';
import 'package:flutter_quiver/screens/polygraph/other/variable_summary_ui.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_window_ui.dart';
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:timezone/timezone.dart';

final providerOfPolygraphTab = StateNotifierProvider<PolygraphTabNotifier, PolygraphTab>(
        (ref) => PolygraphTabNotifier(ref));

class PolygraphTabUi extends ConsumerStatefulWidget {
  const PolygraphTabUi({Key? key}) : super(key: key);

  @override
  _PolygraphTabState createState() => _PolygraphTabState();
}

class _PolygraphTabState extends ConsumerState<PolygraphTabUi> {
  final controllerTerm = TextEditingController();
  final controllerTimezone = TextEditingController();

  final focusNodeTerm = FocusNode();
  final focusTimezone = FocusNode();

  String? _errorTerm;
  List<Plotly> plotly = <Plotly>[];

  @override
  void initState() {
    super.initState();

    // print('in polygraph_tab init()');
    var tab = ref.read(providerOfPolygraphTab);
    var window = tab.windows[tab.activeWindowIndex];
    controllerTerm.text = window.term.toString();
    controllerTimezone.text = window.term.location.toString();

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
    for (var i=0; i<tab.windows.length; i++) {
      plotly.add(Plotly(
        viewId: 'polygraph-div-w$i-$aux',
        data: const [],
        layout: window.layout,
      ));
    }

  }

  @override
  void dispose() {
    controllerTerm.dispose();
    controllerTimezone.dispose();
    focusNodeTerm.dispose();
    focusTimezone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tab = ref.watch(providerOfPolygraphTab);
    var window = tab.windows[tab.activeWindowIndex];
    var asyncCache = ref.watch(providerOfPolygraphWindowCache(window));
    controllerTimezone.text = window.term.location.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 908,
          height: 608,
          color: Colors.grey[200],
          child: Center(
            child: asyncCache.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error: $err'),
                data: (cache) {
                  // print('in asyncCache/data:');
                  // print('window.term = ${window.term}');
                  // print('asyncCache keys: ${cache.keys}');
                  var traces = window.makeTraces();
                  // print(traces.first['x'].take(10));
                  plotly[tab.activeWindowIndex].plot.react(traces, window.layout, displaylogo: false);
                  return plotly[tab.activeWindowIndex];
                }),
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        /// Term, Timezone
        Row(
          children: [
            const Text('Term'),
            const SizedBox(
              width: 8,
            ),
            SizedBox(
                width: 140,
                child: TextField(
                  focusNode: focusNodeTerm,
                  style: const TextStyle(fontSize: 14),
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
                        var tzLocation = controllerTimezone.text == 'UTC' ? UTC :
                          getLocation(controllerTimezone.text);
                        var newTerm = Term.parse(controllerTerm.text, tzLocation);
                        var refreshDataFromDb = true;
                        if (window.term.interval.containsInterval(newTerm.interval)) {
                          refreshDataFromDb = false;
                        }
                        window = window.copyWith(term: newTerm,
                            refreshDataFromDb: refreshDataFromDb);
                        // print('in onEditingComplete: ${window.refreshDataFromDb}');
                        var windows = [...tab.windows];
                        windows[tab.activeWindowIndex] = window;
                        ref.read(providerOfPolygraphTab.notifier).windows = windows;
                        _errorTerm = null; // all good
                      } catch (e) {
                        debugPrint(e.toString());
                        _errorTerm = 'Parsing error';
                      }
                    });
                  },
                )),
            const SizedBox(
              width: 32,
            ),
            const Text('Timezone'),
            const SizedBox(
              width: 8,
            ),
            Container(
              color: MyApp.background,
              width: 180,
              padding: const EdgeInsets.all(0),
              child: RawAutocomplete(
                  focusNode: focusTimezone,
                  textEditingController: controllerTimezone,
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      onFieldSubmitted) =>
                      TextField(
                        focusNode: focusNode,
                        controller: textEditingController,
                        onEditingComplete: onFieldSubmitted,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          enabledBorder: InputBorder.none,
                          fillColor: MyApp.background,
                          filled: true,
                        ),
                      ),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue == TextEditingValue.empty) {
                      return const Iterable<String>.empty();
                    }
                    var aux = TimeVariable.timezones
                        .where((e) => e
                        .toUpperCase()
                        .contains(textEditingValue.text.toUpperCase()))
                        .toList();
                    return aux;
                  },
                  onSelected: (String selection) {
                    setState(() {
                      var tzLocation =
                      selection == 'UTC' ? UTC : getLocation(selection);
                      var term = Term.parse(controllerTerm.text, tzLocation);
                      window = window.copyWith(term: term,
                          refreshDataFromDb: false);
                      var windows = [...tab.windows];
                      windows[tab.activeWindowIndex] = window;
                      ref.read(providerOfPolygraphTab.notifier).windows = windows;
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
                          constraints: const BoxConstraints(
                              maxHeight: 300, maxWidth: 200),
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(option, style: const TextStyle(fontSize: 14),),
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
            const SizedBox(
              width: 32,
            ),
            /// Add
            IconButton(
              tooltip: 'Add variable',
              onPressed: () async {
                setState(() {
                  // variableModel.editedIndex = i + 1;
                });
                await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      print('in showDialog');
                      print(window.yVariables.first.label);
                      return PointerInterceptor(
                        child: AlertDialog(
                            elevation: 24.0,
                            title: const Text('Select a variable'),
                            content: const ProviderScope(child: VariableSelectionUi()),
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
                            ]),
                      );
                      // return AlertDialog(
                      //     elevation: 24.0,
                      //     title: const Text('Select'),
                      //     content: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: const [
                      //         Text('Boo'),
                      //       ],
                      //     ),
                      //     actions: [
                      //       TextButton(
                      //           child: const Text('CANCEL'),
                      //           onPressed: () {
                      //             /// ignore changes the changes
                      //             Navigator.of(context)
                      //                 .pop();
                      //           }),
                      //       ElevatedButton(
                      //           child: const Text('OK'),
                      //           onPressed: () {
                      //             /// harvest the values
                      //             Navigator.of(context)
                      //                 .pop();
                      //           }),
                      //     ]);
                    });
              },
              // visualDensity: VisualDensity.compact,
              // constraints: const BoxConstraints(),
              // padding:
              // const EdgeInsets.only(left: 8, right: 0),
              icon: const Icon(
                Icons.add,
                color: Colors.blueGrey,
              ),
            ),


            /// View data
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        children: [
                          SizedBox(
                            width: 500,
                            height: 500,
                            child: ListView.builder(
                                itemCount: 3000,
                                itemBuilder: (_, int index) {
                                  return Text('Row $index');
                                }),
                          )
                        ],
                        contentPadding: const EdgeInsets.all(12),
                      );
                    });
              },
              icon: const Icon(Icons.table_rows, color: Colors.blueGrey),
              tooltip: 'View data',
            ),

            /// View summary
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Need to use PointerInterceptor to not leak mouse events
                      // from the plotly window underneath.  Unfortunately,
                      // that makes the dialog not barrierDismissable.
                      return PointerInterceptor(
                        child: AlertDialog(
                          scrollable: true,
                            content: VariableSummaryUi(window),
                            contentPadding: const EdgeInsets.all(12),
                            actions: [
                              // TextButton(
                              //     child: const Text('CANCEL'),
                              //     onPressed: () {
                              //       /// ignore changes the changes
                              //       Navigator.of(context)
                              //           .pop();
                              //     }),
                              ElevatedButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    /// harvest the values
                                    Navigator.of(context)
                                        .pop();
                                  }),
                            ]),
                      );
                    });
              },
              icon: const Icon(
                Icons.summarize,
                color: Colors.blueGrey,
              ),
              tooltip: 'View data summary',
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              child: const Icon(
                Icons.more_vert,
                color: Colors.blueGrey,
              ),
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
                      Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text('Refresh data'),
                    ],
                  ),
                ),
                // const PopupMenuItem<String>(
                //   value: 'raw_data',
                //   child: Text('Raw Data'),
                // ),
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
                    style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    window.xVariable.id,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
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
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                ),
                //
                //
                // Add all the y variables
                //
                //
                ...[
                  for (var i = 0; i < window.yVariables.length; i++)
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          window.yVariables[i].isMouseOver = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          window.yVariables[i].isMouseOver = false;
                        });
                      },
                      child: Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              window.yVariables[i].label,
                              style: TextStyle(
                                  color: window.yVariables[i].isHidden
                                      ? Colors.grey
                                      : window.yVariables[i].color ??
                                      VariableDisplayConfig
                                          .defaultColors[i],
                                  decoration: window.yVariables[i].isHidden
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontSize: 14),
                            ),
                            style: TextButton.styleFrom(
                              padding:
                              const EdgeInsets.only(left: 0, right: 150),
                            ),
                          ),

                          /// show the icons only on hover ...
                          if (window.yVariables[i].isMouseOver)
                            Row(
                              children: [
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
                                      window.yVariables[i].isHidden =
                                      !window.yVariables[i].isHidden;
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
          height: 36,
        ),

      ],
    );
  }

  // Future<Widget?> _variableSelection(BuildContext context) async {
  //   final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ))
  // }

}
