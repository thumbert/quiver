library screens.polygraph.polygraph;

import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/screens/polygraph/editors/horizontal_line_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/transformed_variable_editor.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_window_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';

class Polygraph extends ConsumerStatefulWidget {
  const Polygraph({Key? key}) : super(key: key);

  static const route = '/polygraph';

  @override
  _PolygraphState createState() => _PolygraphState();
}

class _PolygraphState extends ConsumerState<Polygraph> {
  final controllerTab = TextEditingController();
  final focusNodeTerm = FocusNode();
  late ScrollController _scrollControllerV;
  late ScrollController _scrollControllerH;
  late Plotly plotly;

  String? _errorTerm;

  /// Which tab is active and needs to be underlined in orange.  The variables
  /// for this tab get displayed and so is the chart
  int activeTabIndex = 0;

  /// If the mouse is over the tab button, this will be non null and have the
  /// value of its tab index
  int? hoveringTabIndex;

  /// If the tab becomes editable, this will be non null and have the value
  /// of its tab index
  int? editableTabIndex;

  final variableSelection = VariableSelection();

  @override
  void initState() {
    super.initState();
    _scrollControllerH = ScrollController();
    _scrollControllerV = ScrollController();
  }

  @override
  void dispose() {
    controllerTab.dispose();
    focusNodeTerm.dispose();
    _scrollControllerH.dispose();
    _scrollControllerV.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var poly = ref.watch(providerOfPolygraph);
    // print('in polygraph build: ${poly.tabs.map((e) => e.name)}');
    // var tab = ref.watch(providerOfPolygraphTab);

    var categories = variableSelection.getCategoriesForNextLevel();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polygraph'),
        actions: [
          PopupMenuButton(
            tooltip: 'More',
            icon: const Icon(Icons.menu),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'raw_data',
                child: Text('Open file'),
              ),
              const PopupMenuItem<String>(
                value: 'raw_data',
                child: Text('Save'),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollControllerH,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 1500,
                  // height: 1,
                ),
                ///
                /// Tabs
                ///
                Wrap(
                  spacing: 8.0,
                  children: [
                    for (var i = 0; i < poly.tabs.length; i++)
                      activeTabIndex == i
                          ? ContextMenuArea(
                              verticalPadding: 4.0,
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
                                        poly.deleteTab(activeTabIndex);
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
                                        editableTabIndex = i;
                                      });
                                    },
                                  ),

                                  /// Move left
                                  ListTile(
                                    dense: true,
                                    horizontalTitleGap: 0.0,
                                    leading: Icon(
                                      Icons.arrow_back,
                                      color: Colors.blueGrey[300],
                                    ),
                                    title: const Text('Move Left'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Whatever'),
                                        ),
                                      );
                                    },
                                  ),

                                  /// Move right
                                  ListTile(
                                    dense: true,
                                    horizontalTitleGap: 0.0,
                                    leading: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.blueGrey[300],
                                    ),
                                    title: const Text('Move Right'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Whatever'),
                                        ),
                                      );
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Whatever'),
                                        ),
                                      );
                                    },
                                  ),
                                ];
                              },
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  onPressed: () {
                                    setState(() {
                                      activeTabIndex = i;
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      editableTabIndex = i;
                                      print('editableTabIndex = $i');
                                    });
                                  },
                                  child: Container(
                                      width: 200,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              width: 2,
                                              color: activeTabIndex == i
                                                  ? Colors.deepOrange
                                                  : Colors.grey[300]!),
                                        ),
                                      ),
                                      child: Center(
                                          child: editableTabIndex == i
                                              ? TextField(
                                                  autofocus: true,
                                                  decoration:
                                                      const InputDecoration(
                                                          isDense: true),
                                                  textAlign: TextAlign.center,
                                                  controller: controllerTab,
                                                  enabled: true,
                                                  onSubmitted: (String value) {
                                                    setState(() {
                                                      var tabs = [...poly.tabs];
                                                      tabs[i] = tabs[i]
                                                          .copyWith(
                                                              name: value);
                                                      ref
                                                          .read(
                                                              providerOfPolygraph
                                                                  .notifier)
                                                          .tabs = tabs;
                                                      editableTabIndex = null;
                                                    });
                                                  },
                                                )
                                              : Text(
                                                  poly.tabs[i].name,
                                                  // tab.name,
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                )))),
                            )
                          : TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              onPressed: () {
                                setState(() {
                                  activeTabIndex = i;
                                });
                              },
                              child: Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 2,
                                          color: activeTabIndex == i
                                              ? Colors.deepOrange
                                              : Colors.grey[300]!),
                                    ),
                                  ),
                                  child: Center(
                                      child: editableTabIndex == i
                                          ? TextField(
                                              controller: controllerTab,
                                              enabled: true,
                                              onSubmitted: (String value) {
                                                setState(() {
                                                  ref
                                                      .read(
                                                          providerOfPolygraphTab
                                                              .notifier)
                                                      .name = value;
                                                  editableTabIndex = null;
                                                });
                                              },
                                            )
                                          : Text(
                                              poly.tabs[i].name,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            )))),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),
                const PolygraphWindowUi(),

                const SizedBox(
                  height: 48,
                ),
                // const HorizontalLineEditor(),
                const TransformedVariableEditor(),
                const SizedBox(
                  height: 48,
                ),



                if (variableSelection.categories.isNotEmpty)
                  Wrap(
                    spacing: 5.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Selection '),
                      ...List.generate(variableSelection.categories.length,
                          (index) {
                        return InputChip(
                          label: Text(
                            variableSelection.categories[index],
                          ),
                          onDeleted: () {
                            setState(() {
                              variableSelection.removeFromLevel(index);
                            });
                          },
                          deleteIcon: const Icon(Icons.close),
                          backgroundColor: MyApp.background,
                        );
                      })
                    ],
                  ),
                const SizedBox(
                  height: 16,
                ),
                if (!variableSelection.isSelectionDone())
                  const Text('Choose a category'),
                const SizedBox(
                  height: 8,
                ),
                if (!variableSelection.isSelectionDone())
                  Wrap(
                    spacing: 5.0,
                    children: List<Widget>.generate(
                      categories.length,
                      (int index) {
                        return ChoiceChip(
                          selectedColor: MyApp.background,
                          label: Text(categories[index]),
                          selected: false,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                variableSelection
                                    .selectCategory(categories[index]);
                              }
                            });
                          },
                        );
                      },
                    ).toList(),
                  ),
                const SizedBox(
                  height: 48,
                ),
                if (variableSelection.isSelectionDone())
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        variableSelection.removeFromLevel(0);
                      });
                    },
                    child: const Text('OK'),
                    // style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue[700],
                    //     foregroundColor: Colors.white),
                  ),

                const SizedBox(
                  height: 16,
                ),


                const SizedBox(
                  height: 32,
                ),

                /// The chart
                // Row(children: const [
                //   TimeFilterEditor(),
                //   // SizedBox(width: 24,),
                //   // TimeFilterEditor(),
                // ],)
              ],
            ),
          ),
          // ),
        ),
      ),
    );
  }
}
