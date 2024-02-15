library lib.screens.polygraph.polygraph_tab_ui;

import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/screens/polygraph/editors/marks_asof_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/transformed_variable_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/marks_historical_view_editor.dart';
import 'package:flutter_quiver/screens/polygraph/other/plotly_layout_ui.dart';
import 'package:flutter_quiver/screens/polygraph/other/variable_summary_ui.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_window_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:timezone/timezone.dart';

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

  /// Each tab window has a Plotly widget associated with it
  final plotly = <Plotly>[];

  @override
  void initState() {
    super.initState();

    var poly = ref.read(providerOfPolygraph);
    var tab = poly.tabs[poly.activeTabIndex];
    var window = tab.windows[tab.activeWindowIndex];
    controllerTerm.text = window.term.toString();
    controllerTimezone.text = window.term.location.toString();

    focusNodeTerm.addListener(() {
      if (!focusNodeTerm.hasFocus) {
        /// validate when you lose focus
        setState(() {
          var window = ref.read(providerOfPolygraph).activeWindow;
          validateTerm(window);
        });
      }
    });

    var aux = DateTime.now().hashCode;
    for (var j = 0; j < tab.windows.length; j++) {
      var window = tab.windows[j];
      plotly.add(Plotly(
        viewId: 'polygraph-div-${tab.name}-w$j-$aux',
        data: const [],
        layout: window.layout.toJson(),
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

  /// Return a widget that has all the plotly windows in this tab (activeTabIndex).
  /// Includes the border, the highlight logic for the border, and the
  /// split horizontally or vertically icons.
  ///
  Widget _makePlotWindows() {
    var poly = ref.watch(providerOfPolygraph);
    var tab = poly.tabs[poly.activeTabIndex];
    print('In polygraph_tab_ui, _makePlotWindows()');
    print('tab.tabAction:${tab.tabAction}');
    if (tab.tabAction.isNotEmpty) {
      if (tab.tabAction.keys.contains('windowAdded')) {
        var aux = DateTime.now().hashCode;
        var i = tab.tabAction['windowAdded']['index'] as int;
        var window = tab.windows[i];
        plotly.insert(
            i,
            Plotly(
              viewId:
                  'polygraph-div-${tab.name}-w${tab.windows.length - 1}-$aux',
              data: const [],
              layout: window.layout.toJson(),
            ));
      } else if (tab.tabAction.keys.contains('windowRemoved')) {
        /// TODO: implement removal!
      } else {
        print('tabAction ${tab.tabAction.keys.first} is not supported!');
      }
      /// TODO: reset tabAction to an empty Map
    }

    return switch (tab.rootNode) {
      SingleNode() => _addSingle(0, tab),
      ColumnNode() => _addColumn(tab.rootNode as ColumnNode, 0, tab),
      RowNode() => _addRow(tab.rootNode as RowNode, 0, tab),
    };
  }


  @override
  Widget build(BuildContext context) {
    var poly = ref.watch(providerOfPolygraph);
    // print('in polygraph_tab_ui build: ${poly.tabs.map((e) => e.name)}');
    // print('active tab index: ${poly.activeTabIndex}');

    var tab = poly.tabs[poly.activeTabIndex];
    // print('active window index: ${tab.activeWindowIndex}');
    // print('The active tab has ${tab.windows.length} windows');
    // print('poly.config.canvasSize = ${tab.layout.canvasSize}');
    var window = tab.windows[tab.activeWindowIndex];
    controllerTerm.text = window.term.toString();
    controllerTimezone.text = window.term.location.toString();
    // print('window cache variables: ${window.cache.keys}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const PlotlyLayoutUi(),

        Container(
          child: _makePlotWindows(),
        ),

        const SizedBox(
          height: 12,
        ),

        /// Term, Timezone, Add, View Data, Summary, Settings, More
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
                      validateTerm(window);
                    });
                  },
                )),
            const SizedBox(
              width: 32,
            ),

            /// Timezone
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
                      window =
                          window.copyWith(term: term, refreshDataFromDb: false);
                      ref.read(providerOfPolygraph.notifier).activeWindow =
                          window;
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
                                    child: Text(
                                      option,
                                      style: const TextStyle(fontSize: 14),
                                    ),
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
                var variable = await context.push('/polygraph/add');
                // variable can also be null if things are aborted or incorrect
                if (variable is PolygraphVariable) {
                  var yVariables = [...window.yVariables, variable];
                  var window2 = window.copyWith(yVariables: yVariables);
                  await window2.updateCache();
                  setState(() {
                    ref.read(providerOfPolygraph.notifier).activeWindow =
                        window2;
                  });
                }
              },
              icon: const Icon(
                Icons.add,
                color: Colors.blueAccent,
                weight: 4.0,
              ),
            ),

            /// View data
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        contentPadding: const EdgeInsets.all(12),
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
                              ElevatedButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    /// harvest the values
                                    Navigator.of(context).pop();
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

            /// Chart Settings
            IconButton(
              onPressed: () {
                final container = ProviderScope.containerOf(context);
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PointerInterceptor(
                        child: AlertDialog(
                            scrollable: true,
                            content: ProviderScope(
                                parent: container,
                                child: const PlotlyLayoutUi()),
                            contentPadding: const EdgeInsets.all(12),
                            actions: [
                              TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                              ElevatedButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    var layout =
                                        ref.read(providerOfPlotlyLayout);
                                    // print('Title is: ${layout.title?.text}');
                                    // print('Y axis label is ${layout.yAxis?.title?.text}');
                                    // print('Y axis position is ${layout.yAxis?.anchor.toString()}');
                                    window = window.copyWith(layout: layout);
                                    ref
                                        .read(providerOfPolygraph.notifier)
                                        .activeWindow = window;
                                  }),
                            ]),
                      );
                    });
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.blueGrey,
              ),
              tooltip: 'Chart settings',
            ),

            /// More button
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
                const PopupMenuItem<String>(
                  value: 'refresh',
                  child: Row(
                    children: [
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
                SizedBox(
                  height: 28,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.only(left: 0, top: 0, bottom: 0),
                      alignment: Alignment.centerLeft,
                      // backgroundColor: Colors.orange,
                    ),
                    child: Text(
                      window.xVariable.label,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            // Y axis
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  child: Text(
                    'Y axis',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                  ),
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
                      // child: Stack(
                      //   alignment: AlignmentDirectional.centerEnd,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            // width: 200,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24.0),
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
                                    fontWeight: window.yVariables[i].isMouseOver
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 14),
                              ),
                            ),
                          ),

                          ///
                          /// Show the icons only on hover ...
                          ///
                          if (window.yVariables[i].isMouseOver)
                            Row(
                              children: [
                                /// Edit
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () async {
                                    var x = window.yVariables[i].toJson();
                                    // print(x);
                                    switch (x['type']) {
                                      case 'TransformedVariable':
                                        ref
                                            .read(providerOfTransformedVariable
                                                .notifier)
                                            .fromJson(x);
                                      case 'VariableMarksAsOfDate':
                                        ref
                                            .read(providerOfMarksAsOf.notifier)
                                            .fromJson(x);
                                      case 'VariableMarksHistoricalView':
                                        ref
                                            .read(providerOfMarksHistoricalView
                                                .notifier)
                                            .fromJson(x);
                                      case _:
                                        print(
                                            'Implement edit for ${x['type']} in polygraph_tab_ui, Edit button');
                                    }

                                    var variable = await context.push(
                                            '/polygraph/edit',
                                            extra: window.yVariables[i])
                                        as PolygraphVariable;
                                    var yVariables = [...window.yVariables];
                                    yVariables[i] = variable;
                                    var window2 =
                                        window.copyWith(yVariables: yVariables);
                                    await window2.updateCache();
                                    setState(() {
                                      ref
                                          .read(providerOfPolygraph.notifier)
                                          .activeWindow = window2;
                                    });

                                    // final container =
                                    //     ProviderScope.containerOf(context);
                                    // var xs = window.yVariables[i].toMap();
                                    //
                                    // Widget widget;
                                    // late StateNotifierProvider provider;
                                    // if (xs['type'] == 'TransformedVariable') {
                                    //   setState(() {
                                    //     ref
                                    //         .read(providerOfTransformedVariable
                                    //             .notifier)
                                    //         .label = xs['label'];
                                    //     ref
                                    //         .read(providerOfTransformedVariable
                                    //             .notifier)
                                    //         .expression = xs['expression'];
                                    //     provider =
                                    //         providerOfTransformedVariable;
                                    //   });
                                    //   widget =
                                    //       const TransformedVariableEditor();
                                    // } else {
                                    //   widget = const Text(
                                    //       'Oops, this branch is dangling');
                                    // }

                                    // await showDialog(
                                    //     barrierDismissible: false,
                                    //     context: context,
                                    //     builder: (context) {
                                    //       return AlertDialog(
                                    //           scrollable: true,
                                    //           elevation: 24.0,
                                    //           content: ProviderScope(
                                    //               parent: container,
                                    //               child: widget),
                                    //           actions: [
                                    //             TextButton(
                                    //                 child: const Text('CANCEL'),
                                    //                 onPressed: () {
                                    //                   Navigator.of(context)
                                    //                       .pop();
                                    //                 }),
                                    //             ElevatedButton(
                                    //                 child: const Text('OK'),
                                    //                 onPressed: () {
                                    //                   Navigator.of(context)
                                    //                       .pop();
                                    //
                                    //                   /// harvest the values
                                    //                   var newVariable =
                                    //                       container
                                    //                           .read(provider);
                                    //                   var variables = [
                                    //                     ...window.yVariables
                                    //                   ];
                                    //                   variables[i] =
                                    //                       newVariable;
                                    //                   window = window.copyWith(
                                    //                       yVariables:
                                    //                           variables);
                                    //                   setState(() {
                                    //                     ref
                                    //                         .read(
                                    //                             providerOfPolygraph
                                    //                                 .notifier)
                                    //                         .activeWindow = window;
                                    //                   });
                                    //                 }),
                                    //           ]);
                                    //     });
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
                                      window.yVariables.removeAt(i);
                                      ref
                                          .read(providerOfPolygraph.notifier)
                                          .activeWindow = window;
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
                                      ref
                                          .read(providerOfPolygraph.notifier)
                                          .activeWindow = window;
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

                                // Tooltip(
                                //   message: 'Style',
                                //   child: TextButton(onPressed: (){},
                                //       style: ButtonStyle(
                                //           minimumSize: MaterialStateProperty.all(Size.zero),
                                //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                //           padding: MaterialStateProperty.all(EdgeInsets.zero)),
                                //       child: RichText(text: const TextSpan(text: ' 🎨 '))),
                                // ),
                              ],
                            ),
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

  void validateTerm(PolygraphWindow window) {
    try {
      var tzLocation = controllerTimezone.text == 'UTC'
          ? UTC
          : getLocation(controllerTimezone.text);
      var newTerm = Term.parse(controllerTerm.text, tzLocation);
      var refreshDataFromDb = true;
      if (window.term.interval.containsInterval(newTerm.interval)) {
        refreshDataFromDb = false;
      }
      window =
          window.copyWith(term: newTerm, refreshDataFromDb: refreshDataFromDb);
      ref.read(providerOfPolygraph.notifier).activeWindow = window;
      _errorTerm = null; // all good
    } catch (e) {
      debugPrint(e.toString());
      _errorTerm = 'Parsing error';
    }
  }

  /// Index [i] is the index of Singles (flattened) windows.
  Widget _addSingle(int i, PolygraphTab tab) {
    // print('Adding single window $i');
    var nodes = tab.rootNode.flatten();
    var window = tab.windows[i];
    var asyncCache = ref.watch(providerOfPolygraphWindowCache(window));
    return SizedBox(
      width: nodes[i].width() + 2,
      height: nodes[i].height().toDouble(),
      child: Column(
        children: [
          /// Window border with the Close icon
          InkWell(
            onTap: () {
              setState(() {
                tab = tab.copyWith(activeWindowIndex: i);
                ref.read(providerOfPolygraph.notifier).activeTab = tab;
              });
            },
            child: Container(
              width: nodes[i].width() + 2,
              height: 28,
              decoration: BoxDecoration(
                color: tab.activeWindowIndex == i
                    ? Colors.orange[100]
                    : Colors.blueGrey[200],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8)),
              ),
              child: Visibility(
                visible: tab.activeWindowIndex == i,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              // var tab = poly.tabs[poly.activeTabIndex];
                              tab = tab.splitWindowHorizontally(i);
                              ref
                                  .read(providerOfPolygraph.notifier)
                                  .activeTab = tab;
                            });
                          },
                          icon: Tooltip(
                            message: 'Split window horizontally',
                            child: Icon(
                              Icons.horizontal_split,
                              color: Colors.blueGrey[800],
                              size: 18,
                            ),
                          )),
                      IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              // var tab = poly.tabs[poly.activeTabIndex];
                              tab = tab.splitWindowVertically(i);
                              // for (var e in tab.rootNode.flatten()) {
                              //   print('(${e.width()}, ${e.height()})');
                              // }
                              // for (var w in tab.windows) {
                              //   print('(${w.layout.width}, ${w.layout.height})');
                              // }
                              ref
                                  .read(providerOfPolygraph.notifier)
                                  .activeTab = tab;
                            });
                          },
                          icon: Tooltip(
                            message: 'Split window vertically',
                            child: Icon(
                              Icons.vertical_split,
                              color: Colors.blueGrey[800],
                              size: 18,
                            ),
                          )),
                      IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              // var tab = poly.tabs[poly.activeTabIndex];
                              if (tab.windows.length == 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Oops, you can\'t remove the last window.'),
                                  ),
                                );
                              }
                              tab = tab.removeWindow(i);
                              ref
                                  .read(providerOfPolygraph.notifier)
                                  .activeTab = tab;
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.blueGrey[800],
                            size: 18,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: nodes[i].width() + 2,
            height: nodes[i].height() + 2 - 30,
            decoration: BoxDecoration(
                color: Colors.white,
                border: tab.activeWindowIndex == i
                    ? Border.all(color: Colors.orange[300]!)
                    : null),
            child: asyncCache.when(
                loading: () => const Center(
                    child: SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator())),
                error: (err, stack) => Text('Error: $err'),
                data: (cache) {
                  // print('in asyncCache/data:');
                  // print('window.term = ${window.term}');
                  // print('asyncCache keys: ${cache.keys}');
                  var traces = window.makeTraces();
                  // print('traces.length = ${traces.length}');
                  // print(traces.first['x'].take(10));
                  // if (traces.length == 3) {
                  //   print(traces[2]);
                  // }
                  // print('window.layout = ${window.layout.toMap()}');

                  var layout = {
                    'width': nodes[i].width(),
                    'height': nodes[i].height() - 30,
                    ...window.layout.toJson(),
                  };
                  plotly[i].plot.react(traces, layout, displaylogo: false);
                  return plotly[i];
                }),
          ),
        ],
      ),
    );
  }

  Widget _addRow(RowNode node, int iOffset, PolygraphTab tab) {
    var sizes = [0, ...node.children.map((e) => e.flatten().length).cumSum().cast<int>()];
    // print('in _addRow...');
    // print('sizes: $sizes');
    var children = <Widget>[];
    for (var i=0; i<node.children.length; i++) {
      /// j is the single window index for the rootNode
      var j = sizes[i+1] - 1;
      // print('iOffset: $iOffset, i: $i, j: $j');
      children.add(switch (node.children[i]) {
        SingleNode() => _addSingle(iOffset + j, tab),
        ColumnNode() => _addColumn(node.children[i] as ColumnNode, iOffset + sizes[i], tab),
        RowNode() => _addRow(node.children[i] as RowNode, iOffset + sizes[i], tab),
      });
    }
    return Row(children: children);
  }

  /// The [iOffset] is the count of singles before this node.
  Widget _addColumn(ColumnNode node, int iOffset, PolygraphTab tab) {
    var sizes = [0, ...node.children.map((e) => e.flatten().length).cumSum().cast<int>()];
    // print('in _addColumn...');
    // print('sizes: $sizes');
    var children = <Widget>[];
    for (var i=0; i<node.children.length; i++) {
      /// j is the single window index relative to this node
      var j = sizes[i+1] - 1;
      // print('iOffset: $iOffset, i: $i, j: $j');
      children.add(switch (node.children[i]) {
        SingleNode() => _addSingle(iOffset + j, tab),
        ColumnNode() => _addColumn(node.children[i] as ColumnNode, iOffset + sizes[i], tab),
        RowNode() => _addRow(node.children[i] as RowNode, iOffset + sizes[i], tab),
      });
    }
    return Column(children: children);
  }

}
