library screens.polygraph.polygraph;

import 'dart:convert';

import 'package:contextmenu/contextmenu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/screens/polygraph/editors/load_project_editor.dart';
import 'package:flutter_quiver/screens/polygraph/other/tab_layout_ui.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_tab_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../models/polygraph/polygraph_tab.dart';

final providerOfPolygraph =
    StateNotifierProvider<PolygraphNotifier, PolygraphState>(
        (ref) => PolygraphNotifier(ref));

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

  final focusNodeSelection = FocusNode();

  /// If the tab becomes editable, this will be non-null and have the value
  /// of its tab index.  Used so you can edit the tab name by a long press.
  int? editableTabIndex;

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
          value = poly.getValidTabName(
              tabIndex: poly.activeTabIndex, suggestedName: value);
          // print('tab name is: $value');
          tabs[poly.activeTabIndex] =
              tabs[poly.activeTabIndex].copyWith(name: value);
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
    focusNodeSelection.dispose();
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
                bottom: BorderSide(
                    width: 2,
                    color: poly.activeTabIndex == i
                        ? Colors.deepOrange
                        : Colors.grey[300]!),
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
                            value = poly.getValidTabName(
                                tabIndex: i, suggestedName: value);
                            tabs[i] = tabs[i].copyWith(name: value);
                            ref.read(providerOfPolygraph.notifier).tabs = tabs;

                            /// FIXME: when I change
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
    // var tab = poly.tabs[poly.activeTabIndex];
    // if (kDebugMode) {
    //   print('in polygraph build(), tab height = ${tab.layout.canvasSize.height}');
    // }
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
                child: const Row(children: [
                  Icon(
                    Icons.cloud_download,
                    color: Colors.orange,
                  ),
                  Text('  Open project')
                ]),
                onTap: () {
                  final container = ProviderScope.containerOf(context);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PointerInterceptor(
                          child: AlertDialog(
                            scrollable: true,
                            title: const Text('Load project'),
                            content: ProviderScope(
                                parent: container,
                                child: const LoadProjectEditor()),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        );
                      });
                  // print('After popping ... ');
                  // print(ref.read(providerOfPolygraphLoadProject).userId);
                },
              ),
              PopupMenuItem<String>(
                value: 'save',
                child: const Row(children: [
                  Icon(
                    Icons.cloud_upload,
                    color: Colors.orange,
                  ),
                  Text('  Save project')
                ]),
                onTap: () {},
              ),
              PopupMenuItem<String>(
                value: 'loadFile',
                child: const Row(children: [
                  Icon(
                    Icons.file_upload,
                    color: Colors.orange,
                  ),
                  Text('  Load file')
                ]),
                onTap: () async {
                  var result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                    withData: true,
                  );
                  if (result != null) {
                    if (!result.isSinglePick) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const SimpleDialog(
                              contentPadding:
                                  EdgeInsets.fromLTRB(24, 12, 24, 24),
                              title: Text(
                                'Error',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              children: [Text('Only one file at a time!')],
                            );
                          });
                    }
                    // print('${result.names}');
                    // print('${utf8.decode(result.files.first.bytes as List<int>)}');
                    try {
                      var stringContent =
                          utf8.decode(result.files.first.bytes as List<int>);
                      var jsonContent =
                          json.decode(stringContent) as Map<String, dynamic>;
                      var poly = PolygraphState.fromJson(jsonContent);
                      ref.read(providerOfPolygraph.notifier).tabs = poly.tabs;
                      ref.read(providerOfPolygraph.notifier).activeTabIndex = 0;
                    } catch (e) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(24, 12, 24, 24),
                              title: const Text(
                                'Error',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              children: [
                                Text('File ${result.names.first} is not '
                                    'a correctly formatted Polygraph project.')
                              ],
                            );
                          });
                    }
                  }
                },
              ),
              PopupMenuItem<String>(
                value: 'raw_data',
                child: const Row(children: [
                  Icon(
                    Icons.file_download,
                    color: Colors.orange,
                  ),
                  Text('  Save to file')
                ]),
                onTap: () {},
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const SimpleDialog(
                      children: [
                        SizedBox(
                          width: 500,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Experimental UI for curve visualization.'
                                  '\n'),
                            ],
                          ),
                        )
                      ],
                      contentPadding: EdgeInsets.all(12),
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
              // const LoadProjectEditor(),

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
                      onReorder: (oldIndex, newIndex) =>
                          _updateTabPosition(oldIndex, newIndex, poly.tabs),
                      children: [
                        for (int index = 0; index < poly.tabs.length; index++)
                          ReorderableDragStartListener(
                            key: ValueKey(poly.tabs[index].name),
                            index: index,
                            child: Container(
                              height: 40,
                              width: 200,
                              margin:
                                  const EdgeInsets.only(right: 4, bottom: 16),
                              child: Center(
                                child: poly.activeTabIndex == index
                                    ? ContextMenuArea(
                                      verticalPadding: 8.0,
                                      width: 260,
                                      builder: (context) {
                                        return [
                                          /// Add tab
                                          PointerInterceptor(
                                            child: ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0.0,
                                              leading: Icon(
                                                Icons.add,
                                                color: Colors.blueGrey[300],
                                              ),
                                              title: const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 12.0),
                                                child: Text('Add tab'),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  poly.addTab();
                                                });
                                              },
                                            ),
                                          ),

                                          /// Delete tab
                                          PointerInterceptor(
                                            child: ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0.0,
                                              leading: Icon(
                                                Icons.delete_forever,
                                                color: Colors.blueGrey[300],
                                              ),
                                              title: const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 12.0),
                                                child: Text('Delete tab'),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  poly.deleteTab(
                                                      poly.activeTabIndex);

                                                  /// TODO: which tab is now active?
                                                });
                                              },
                                            ),
                                          ),

                                          /// Rename
                                          PointerInterceptor(
                                            child: ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0.0,
                                              leading: Icon(
                                                Icons.edit,
                                                color: Colors.blueGrey[300],
                                              ),
                                              title: const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 12.0),
                                                child: Text('Rename'),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  editableTabIndex = index;
                                                });
                                              },
                                            ),
                                          ),

                                          /// Tab display config
                                          PointerInterceptor(
                                            child: ListTile(
                                              dense: true,
                                              horizontalTitleGap: 0.0,
                                              leading: Icon(
                                                Icons.tune,
                                                color: Colors.blueGrey[300],
                                              ),
                                              title: const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 12.0),
                                                child: Text(
                                                    'Display configuration'),
                                              ),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                        context) {
                                                      return SimpleDialog(
                                                          children: [
                                                            PointerInterceptor(
                                                                child:
                                                                    Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              child: ProviderScope(
                                                                  parent:
                                                                      container,
                                                                  child:
                                                                      const TabLayoutUi()),
                                                            )),
                                                          ]);
                                                    });
                                              },
                                            ),
                                          ),
                                        ];
                                      },
                                      child:
                                          _makeTabTextButton(index, poly),
                                    )
                                    : _makeTabTextButton(index, poly),
                              ),
                            ),
                          ),
                      ],
                    )),
              ),

              ///
              /// Tab content
              ///
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollControllerH,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
