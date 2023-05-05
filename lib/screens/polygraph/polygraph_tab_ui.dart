library lib.screens.polygraph.polygraph_tab_ui;

import 'package:date/date.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/editors/horizontal_line.dart';
import 'package:flutter_quiver/models/polygraph/editors/ok_button.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_time_aggregation.dart';
import 'package:flutter_quiver/screens/polygraph/editors/horizontal_line_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_transformed_variable.dart';
import 'package:flutter_quiver/screens/polygraph/other/plotly_layout_ui.dart';
import 'package:flutter_quiver/screens/polygraph/other/tab_layout_ui.dart';
import 'package:flutter_quiver/screens/polygraph/other/variable_selection_ui.dart';
import 'package:flutter_quiver/screens/polygraph/other/variable_summary_ui.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_window_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
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
          try {
            window =
                window.copyWith(term: Term.parse(controllerTerm.text, UTC));
            ref.read(providerOfPolygraph.notifier).activeWindow = window;
            _errorTerm = null; // all good
          } catch (e) {
            debugPrint(e.toString());
            _errorTerm = 'Parsing error';
          }
        });
      }
    });

    var aux = DateTime.now().hashCode;
      for (var j = 0; j < tab.windows.length; j++) {
        var window = tab.windows[j];
        plotly.add(Plotly(
          viewId: 'polygraph-div-${tab.name}-w$j-$aux',
          data: const [],
          layout: window.layout.toMap(),
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

  Widget _makePlotWindows() {
    var rows = <Row>[];
    var poly = ref.watch(providerOfPolygraph);
    var tab = poly.tabs[poly.activeTabIndex];
    var windowSize = tab.layout.windowSize();
    var height = windowSize.height;
    var width = windowSize.width;
    if (tab.tabAction.isNotEmpty) {
      if (tab.tabAction.keys.first == 'windowAdded') {
        var aux = DateTime.now().hashCode;
        var window = tab.windows.last;
        plotly.add(Plotly(
          viewId: 'polygraph-div-${tab.name}-w${tab.windows.length-1}-$aux',
          data: const [],
          layout: window.layout.toMap(),
        ));
      } else if (tab.tabAction.keys.first == 'windowRemoved') {
        /// TODO: implement removal!
      } else {
        print('tabAction ${tab.tabAction.keys.first} is not supported!');
      }
      /// reset tabAction to an empty Map
    }


    for (var i = 0; i < tab.layout.rows; i++) {
      var aux = <Widget>[];
      for (var j = 0; j < tab.layout.cols; j++) {
        var ij = i + j * tab.layout.rows;
        var window = tab.windows[ij];
        var asyncCache = ref.watch(providerOfPolygraphWindowCache(window));
        aux.add(SizedBox(
          width: width+2,
          height: height+30,
          child: Column(
            children: [
              /// Window border with the Close icon
              InkWell(
                onTap: () {
                  setState(() {
                    tab = tab.copyWith(activeWindowIndex: ij);
                    ref.read(providerOfPolygraph.notifier).activeTab = tab;
                  });
                },
                child: Container(
                  width: width+2,
                  height: 28,
                  decoration: BoxDecoration(
                    color: tab.activeWindowIndex == ij
                        ? Colors.orange[300]
                        : Colors.blueGrey[200],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                  ),
                  child: Visibility(
                    visible: tab.activeWindowIndex == ij,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              var tab = poly.tabs[poly.activeTabIndex];
                              if (tab.windows.length == 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Oops, you can\'t remove the last window.'),
                                  ),
                                );
                              }
                              tab = tab.removeWindow(ij);
                              ref.read(providerOfPolygraph.notifier).activeTab = tab;

                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          )),
                    ),
                  ),
                ),
              ),
              Container(
                width: width + 2,
                height: height + 2,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: tab.activeWindowIndex == ij
                        ? Border.all(color: Colors.orange[300]!)
                        : null),
                // child: Center(child: Text('Window ($i,$j)')),
                child: asyncCache.when(
                    loading: () => const CircularProgressIndicator(),
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
                      print('window.layout = ${window.layout.toMap()}');

                      plotly[ij]
                          .plot
                          .react(traces, window.layout.toMap(), displaylogo: false);
                      return plotly[ij];
                    }),

              ),
            ],
          ),
        ));
      }
      rows.add(Row(
        children: aux,
      ));
    }

    // for (var i = 0; i < tab.windows.length; i++) {
    //   var window = tab.windows[i];
    //   print('Plotly layout $i: ${window.layout.toMap()}');
    //   var asyncCache = ref.watch(providerOfPolygraphWindowCache(window));
    //   out.add(Container(
    //     width: window.layout.width.toDouble(),
    //     // height: window.layout.height.toDouble(),
    //     height: 100,
    //     padding: const EdgeInsets.all(8.0),
    //     decoration: BoxDecoration(
    //         color: i == 0 ? Colors.green[200] : Colors.pink[200],
    //         border: Border.all(color: Colors.orange)),
    //     child: Center(
    //       child: Text('Window $i')),
    //     // ),
    //   ));
    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    var poly = ref.watch(providerOfPolygraph);
    print('in polygraph_tab_ui build: ${poly.tabs.map((e) => e.name)}');
    print('active tab index: ${poly.activeTabIndex}');

    var tab = poly.tabs[poly.activeTabIndex];
    print('The active tab has ${tab.windows.length} windows');
    // print('poly.config.canvasSize = ${tab.layout.canvasSize}');
    var window = tab.windows[tab.activeWindowIndex];

    controllerTimezone.text = window.term.location.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      try {
                        var tzLocation = controllerTimezone.text == 'UTC'
                            ? UTC
                            : getLocation(controllerTimezone.text);
                        var newTerm =
                            Term.parse(controllerTerm.text, tzLocation);
                        var refreshDataFromDb = true;
                        if (window.term.interval
                            .containsInterval(newTerm.interval)) {
                          refreshDataFromDb = false;
                        }
                        window = window.copyWith(
                            term: newTerm,
                            refreshDataFromDb: refreshDataFromDb);
                        ref.read(providerOfPolygraph.notifier).activeWindow =
                            window;
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
                /// TODO:  does it need ref.watch here??
                var selection = ref.read(providerOfVariableSelection);
                final container = ProviderScope.containerOf(context);
                await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      var mapOfVariables = {
                        'Line,Horizontal': providerOfHorizontalLine,
                        'Expression': providerOfTransformedVariable,
                      };
                      // print('in builder of showDialog:');
                      // print('label: ${container.read(providerOfTransformedVariable).label}');

                      return PointerInterceptor(
                        child: AlertDialog(
                            elevation: 24.0,
                            scrollable: true,
                            title: const Text('Select a variable'),
                            content: ProviderScope(
                                parent: container,
                                child: const VariableSelectionUi()),
                            actions: [
                              TextButton(
                                  child: const Text('CANCEL'),
                                  onPressed: () {
                                    selection.categories.clear();
                                    Navigator.of(context).pop();
                                  }),
                              ElevatedButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    var poly = container.read(providerOfPolygraph);
                                    var window = poly.activeWindow;
                                    // print(window.yVariables.map((e) => e.label));
                                    /// harvest the values
                                    // print('Selected: ${selection.selection}');
                                    var provider =
                                        mapOfVariables[selection.selection]!;
                                    var res = container.read(provider);
                                    if (res is TransformedVariable) {
                                      debugPrint(res.expression);
                                      res.validate(window);
                                      print(res.error);
                                      // force a new repaint
                                      ref
                                          .read(providerOfTransformedVariable
                                              .notifier)
                                          .error = res.error;
                                      if (res.error == '') {
                                        // reset the UI
                                        ref
                                            .read(providerOfTransformedVariable
                                                .notifier)
                                            .reset();
                                      }
                                    } else if (res is HorizontalLine) {
                                      debugPrint(res.yIntercept.toString());
                                      var ta =
                                          ref.read(providerOfTimeAggregation);
                                      ref
                                          .read(
                                              providerOfHorizontalLine.notifier)
                                          .timeAggregation = ta;
                                      print(res.timeAggregation.toJson());
                                      res.validate();
                                      print(res.error);
                                    } else {
                                      print(
                                          'Need to implement this type of variable in polygraph_tab_ui, onPresed() OK');
                                    }

                                    if (res.error == '') {
                                      /// We are done here.  Ready to pop.
                                      var yVariables = [
                                        ...window.yVariables,
                                        res
                                      ];
                                      window = window.copyWith(
                                          yVariables: yVariables);
                                      ref
                                          .read(providerOfPolygraph.notifier)
                                          .activeWindow = window;
                                      selection.categories.clear();
                                      Navigator.of(context).pop();
                                    }
                                  }),
                            ]),
                      );
                    });
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
                                  child: const Text('CANCEL'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                              ElevatedButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    /// harvest the values, HOW???
                                    var layout = ref.read(providerOfPlotlyLayout);
                                    print('Title is: ${layout.title?.text}');
                                    window = window.copyWith(layout: layout);
                                    ref.read(providerOfPolygraph.notifier).activeWindow = window;
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
                SizedBox(
                  height: 28,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      window.xVariable.id,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.only(left: 0, top: 0, bottom: 0),
                      alignment: Alignment.centerLeft,
                      // backgroundColor: Colors.orange,
                    ),
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
                          SizedBox(
                            height: 28,
                            child: TextButton(
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
