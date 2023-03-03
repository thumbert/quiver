library screens.polygraph.polygraph;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:timezone/timezone.dart';

class Polygraph extends ConsumerStatefulWidget {
  const Polygraph({Key? key}) : super(key: key);

  static const route = '/polygraph';

  @override
  _PolygraphState createState() => _PolygraphState();
}

class _PolygraphState extends ConsumerState<Polygraph> {
  final controllerTerm = TextEditingController();
  final focusNodeTerm = FocusNode();
  late ScrollController _scrollControllerV;
  late ScrollController _scrollControllerH;
  late Plotly plotly;


  String? _errorTerm;

  final variableSelection = VariableSelection();

  @override
  void initState() {
    super.initState();
    _scrollControllerH = ScrollController();
    _scrollControllerV = ScrollController();

    controllerTerm.text = ref.read(providerOfPolygraph).term.toString();
    focusNodeTerm.addListener(() {
      if (!focusNodeTerm.hasFocus) {
        /// validate when you lose focus
        setState(() {
          try {
            ref.read(providerOfPolygraph.notifier).term =
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
      layout: PolygraphState.layout,
    );
  }

  @override
  void dispose() {
    controllerTerm.dispose();
    focusNodeTerm.dispose();
    _scrollControllerH.dispose();
    _scrollControllerV.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(providerOfPolygraph);
    var categories = variableSelection
        .getCategoriesForLevel(variableSelection.categories.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polygraph'),
        actions: [
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
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Load/Save page',
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
                  height: 8,
                ),

                /// Term
                SizedBox(
                    width: 140,
                    child: TextFormField(
                      focusNode: focusNodeTerm,
                      decoration: InputDecoration(
                        labelText: 'Term',
                        labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                        helperText: '',
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        errorText: _errorTerm,
                      ),
                      controller: controllerTerm,

                      /// validate when Enter is pressed
                      onEditingComplete: () {
                        setState(() {
                          try {
                            ref.read(providerOfPolygraph.notifier).term =
                                Term.parse(controllerTerm.text, UTC);
                            _errorTerm = null; // all good
                          } catch (e) {
                            debugPrint(e.toString());
                            _errorTerm = 'Parsing error';
                          }
                        });
                      },
                    )),
                const SizedBox(
                  height: 8,
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
                                    .addCategory(categories[index]);
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
                            style:
                                TextStyle(color: Colors.blueGrey, fontSize: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            state.xVariable.name,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(
                                left: 0, top: 0, bottom: 0),
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
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 16),
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
                                      state.yVariables[i].label(),
                                      style: TextStyle(
                                          color: state.yVariables[i].color ?? VariableDisplayConfig.defaultColors[i],
                                          decoration: state.yVariables[i].isHidden ? TextDecoration.lineThrough : TextDecoration.none,
                                          fontSize: 16),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.only(
                                          left: 0, right: 120),
                                      // minimumSize: Size(200, 24),
                                    ),
                                  ),

                                  /// show the icons only on hover ...
                                  if (state.yVariables[i].isMouseOver)
                                    Row(
                                      children: [
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
                                                      title:
                                                          const Text('Select'),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: const [
                                                          Text('Boo'),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            child: const Text(
                                                                'CANCEL'),
                                                            onPressed: () {
                                                              /// ignore changes the changes
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }),
                                                        ElevatedButton(
                                                            child: const Text(
                                                                'OK'),
                                                            onPressed: () {
                                                              /// harvest the values
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }),
                                                      ]);
                                                });
                                          },
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 0),
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            color: Colors.blueGrey[300],
                                            size: 20,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Remove',
                                          onPressed: () {
                                            setState(() {
                                              // variableModel.removeVariableAt(i);
                                            });
                                          }, // delete the sucker
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.only(
                                              left: 0, right: 0),
                                          icon: Icon(
                                            Icons.delete_forever,
                                            color: Colors.blueGrey[300],
                                            size: 20,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Copy',
                                          onPressed: () {
                                            setState(() {
                                              // variableModel.copy(i);
                                            });
                                          }, // delete the sucker
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.only(
                                              left: 0, right: 8),
                                          icon: Icon(
                                            Icons.copy,
                                            color: Colors.blueGrey[300],
                                            size: 20,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Hide/Show',
                                          onPressed: () {
                                            setState(() {
                                              state.yVariables[i].isHidden = !state.yVariables[i].isHidden;
                                            });
                                          },
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.only(
                                              left: 0, right: 8),
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
                /// The chart



              ],
            ),
          ),
          // ),
        ),
      ),
    );
  }
}
