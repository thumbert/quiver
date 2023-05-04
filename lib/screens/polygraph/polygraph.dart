library screens.polygraph.polygraph;

import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/screens/polygraph/other/tab_layout_ui.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_tab_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../models/polygraph/polygraph_tab.dart';

final providerOfPolygraph = StateNotifierProvider<PolygraphNotifier, PolygraphState>((ref) => PolygraphNotifier(ref));

// final providerOfPolygraph =
//     StateNotifierProvider<PolygraphNotifier, PolygraphState>(
//         (ref) {
//           var tab = ref.read(providerOfPolygraphTab);
//
// // ref.read(providerOfPolygraph.notifier).activeTab = tab;
//           return PolygraphNotifier(ref);
//         } ;

class Polygraph extends ConsumerStatefulWidget {
  const Polygraph({Key? key}) : super(key: key);

  static const route = '/polygraph';

  @override
  _PolygraphState createState() => _PolygraphState();
}

class _PolygraphState extends ConsumerState<Polygraph> {
  final controllerTab = TextEditingController();
  final focusNodeTab = FocusNode();
  late ScrollController _scrollControllerV;
  late ScrollController _scrollControllerH;
  late ScrollController _scrollControllerTabs;

  String? _errorTerm;

  /// If the tab becomes editable, this will be non-null and have the value
  /// of its tab index.  Used so you can edit the tab name by a long press.
  int? editableTabIndex;

  final variableSelection = VariableSelection();

  @override
  void initState() {
    super.initState();
    _scrollControllerH = ScrollController();
    _scrollControllerV = ScrollController();
    _scrollControllerTabs = ScrollController();

    focusNodeTab.addListener(() {
      if (!focusNodeTab.hasFocus) {
        /// validate when you lose focus
        setState(() {
          var poly = ref.read(providerOfPolygraph);
          var tabs = [...poly.tabs];
          var value = controllerTab.text;
          value = poly.getValidTabName(tabIndex: poly.activeTabIndex, suggestedName: value);
          // print('tab name is: $value');
          tabs[poly.activeTabIndex] = tabs[poly.activeTabIndex].copyWith(name: value);
          ref.read(providerOfPolygraph.notifier).tabs = tabs;
          controllerTab.text = value;
          editableTabIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    controllerTab.dispose();
    focusNodeTab.dispose();
    _scrollControllerH.dispose();
    _scrollControllerV.dispose();
    _scrollControllerTabs.dispose();
    super.dispose();
  }

  TextButton _makeTabTextButton(int i, PolygraphState poly) {
    return TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () {
          setState(() {
            ref.read(providerOfPolygraph.notifier).activeTabIndex = i;
            // print('in Tab TextButton onPressed(), activeTabIndex = $i');
          });
        },
        onLongPress: () {
          setState(() {
            editableTabIndex = i;
          });
        },
        child: Container(
            width: 200,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2, color: poly.activeTabIndex == i ? Colors.deepOrange : Colors.grey[300]!),
              ),
            ),
            child: Center(
                child: editableTabIndex == i
                    ? TextField(
                        autofocus: true,
                        decoration: const InputDecoration(isDense: true),
                        textAlign: TextAlign.center,
                        controller: controllerTab,
                        focusNode: focusNodeTab,
                        enabled: true,
                        onSubmitted: (String value) {
                          setState(() {
                            var tabs = [...poly.tabs];
                            editableTabIndex = null;
                            value = poly.getValidTabName(tabIndex: i, suggestedName: value);
                            tabs[i] = tabs[i].copyWith(name: value);
                            ref.read(providerOfPolygraph.notifier).tabs = tabs;
                          });
                        },
                      )
                    : Text(
                        poly.tabs[i].name,
                        // tab.name,
                        style: const TextStyle(fontSize: 18),
                      ))));
  }

  void _updateTabPosition(int oldIndex, int newIndex, List<PolygraphTab> tabs) {
    setState(() {
      var element = tabs[oldIndex];
      if (oldIndex < newIndex) {
        newIndex--;
      }
      tabs.removeAt(oldIndex);
      tabs.insert(newIndex, element);
      // activeTabIndex = newIndex;
      ref.read(providerOfPolygraph.notifier).activeTabIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    var poly = ref.watch(providerOfPolygraph);
    // print('in polygraph build: ${poly.tabs.map((e) => e.name)}');
    // print('active tab index: ${poly.activeTabIndex}');
    // var tabs = poly.tabs;
    var tab = poly.tabs[poly.activeTabIndex];
    print('in polygraph build(), tab height = ${tab.layout.canvasSize.height}');
    final container = ProviderScope.containerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polygraph'),
        actions: [
          PopupMenuButton(
            tooltip: 'More',
            icon: const Icon(Icons.menu),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'raw_data',
                child: Row(children: const [
                  Icon(Icons.folder_open),
                  Text('  Open')]),
                onTap: () {},
              ),
              PopupMenuItem<String>(
                value: 'raw_data',
                child: const Text('Save project'),
                onTap: () {},
              ),
            ],
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
                            children: const [
                              Text('Experimental UI for curve visualization.'
                                  '\n'),
                            ],
                          ),
                        )
                      ],
                      contentPadding: const EdgeInsets.all(12),
                    );
                  });
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
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
                            children: const [
                              Text('Experimental UI for curve visualization.'
                                  '\n'),
                            ],
                          ),
                        )
                      ],
                      contentPadding: const EdgeInsets.all(12),
                    );
                  });
            },
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollControllerV,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///
              /// Tabs
              ///
              Scrollbar(
                controller: _scrollControllerTabs,
                child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 50,
                    ),
                    child: ReorderableListView(
                      buildDefaultDragHandles: false,
                      scrollDirection: Axis.horizontal,
                      scrollController: _scrollControllerTabs,
                      onReorder: (oldIndex, newIndex) => _updateTabPosition(oldIndex, newIndex, poly.tabs),
                      children: [
                        for (int index = 0; index < poly.tabs.length; index++)
                          ReorderableDragStartListener(
                            key: ValueKey(poly.tabs[index].name),
                            index: index,
                            child: Container(
                              height: 40,
                              width: 200,
                              margin: const EdgeInsets.only(right: 4, bottom: 16),
                              child: Center(
                                child: poly.activeTabIndex == index
                                    ? ContextMenuArea(
                                        verticalPadding: 8.0,
                                        width: 200,
                                        builder: (context) {
                                          return [
                                            /// Add tab
                                            ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0.0,
                                              leading: Icon(
                                                Icons.add,
                                                color: Colors.blueGrey[300],
                                              ),
                                              title: const Text('Add tab'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  poly.addTab();
                                                });
                                              },
                                            ),

                                            /// Delete tab
                                            ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0.0,
                                              leading: Icon(
                                                Icons.delete_forever,
                                                color: Colors.blueGrey[300],
                                              ),
                                              title: const Text('Delete tab'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  poly.deleteTab(poly.activeTabIndex);

                                                  /// TODO: which tab is now active?
                                                });
                                              },
                                            ),

                                            /// Rename
                                            ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0.0,
                                              leading: Icon(
                                                Icons.edit,
                                                color: Colors.blueGrey[300],
                                              ),
                                              title: const Text('Rename'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  editableTabIndex = index;
                                                });
                                              },
                                            ),

                                            /// Tab display config
                                            ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0.0,
                                              leading: Icon(
                                                Icons.tune,
                                                color: Colors.blueGrey[300],
                                              ),
                                              title: const Text('Display configuration'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return SimpleDialog(children: [
                                                        PointerInterceptor(
                                                            child: Padding(
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: ProviderScope(
                                                              parent: container, child: const TabLayoutUi()),
                                                        )),
                                                      ]);
                                                    });
                                              },
                                            ),

                                            /// Add window
                                            ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0.0,
                                              leading: Icon(
                                                Icons.square_outlined,
                                                color: Colors.blueGrey[300],
                                              ),
                                              title: const Text('Add window'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  var tab = poly.tabs[poly.activeTabIndex].addWindow();
                                                  ref.read(providerOfPolygraph.notifier).activeTab = tab;
                                                });
                                                // ScaffoldMessenger.of(context).showSnackBar(
                                                //   const SnackBar(
                                                //     content: Text('Whatever'),
                                                //   ),
                                                // );
                                              },
                                            ),
                                          ];
                                        },
                                        child: _makeTabTextButton(index, poly),
                                      )
                                    : _makeTabTextButton(index, poly),
                              ),
                            ),
                          ),
                      ],
                    )),
              ),

              // const SizedBox(
              //   height: 16,
              // ),
              //
              // IconButton(
              //     onPressed: () async {
              //       final container = ProviderScope.containerOf(context);
              //       await showDialog(
              //           context: context,
              //           builder: (BuildContext context) {
              //             return SimpleDialog(
              //               children: [
              //                 ProviderScope(
              //                     parent: container,
              //                     child: PointerInterceptor(
              //                         child: const Padding(
              //                       padding: EdgeInsets.all(16.0),
              //                       child: TabLayoutUi(),
              //                     ))),
              //               ],
              //             );
              //           });
              //     },
              //     icon: const Icon(Icons.tune)),

              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollControllerH,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(
                        width: 1500,
                      ),

                      PolygraphTabUi(),

                      SizedBox(
                        height: 48,
                      ),
                      // const HorizontalLineEditor(),
                      // const TransformedVariableEditor(),
                      SizedBox(
                        height: 48,
                      ),

                      // const VariableSelectionUi(),
                      SizedBox(
                        height: 48,
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
