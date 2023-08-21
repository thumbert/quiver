library screens.polygraph.editors.load_project_editor;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final providerOfUsers =
    FutureProvider<List<String>>((ref) => PolygraphState.getUsers());

final providerOfProjectNames =
    FutureProvider.family<List<String>, String>((ref, userId) async {
  return PolygraphState.getProjectNames(userId);
});

class LoadProjectEditor extends ConsumerStatefulWidget {
  const LoadProjectEditor({Key? key}) : super(key: key);

  @override
  _LoadProjectEditorState createState() => _LoadProjectEditorState();
}

class _LoadProjectEditorState extends ConsumerState<LoadProjectEditor> {
  final controllerUserName = TextEditingController();
  final controllerProjectName = TextEditingController();
  final controllerLabel = TextEditingController();

  final focusUserName = FocusNode();
  final focusProjectName = FocusNode();

  String? _errorUserName, _errorProjectName;

  @override
  void initState() {
    super.initState();
    var state = ref.read(providerOfPolygraph);
    _setControllers(state);

    focusUserName.addListener(() {
      if (!focusUserName.hasFocus) {
        setState(() {
          validateUserName();
        });
      }
    });
    focusProjectName.addListener(() {
      if (!focusProjectName.hasFocus) {
        setState(() {
          validateProjectName();
        });
      }
    });
  }

  @override
  void dispose() {
    controllerUserName.dispose();
    controllerProjectName.dispose();

    focusUserName.dispose();
    focusProjectName.dispose();

    super.dispose();
  }

  void _setControllers(PolygraphState state) {
    controllerUserName.text = state.userId ?? '';
    controllerProjectName.text = state.projectName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var users = ref.watch(providerOfUsers);
    var projects = ref.watch(providerOfProjectNames(controllerUserName.text));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// User name
            ///
            Row(
              children: [
                Container(
                  width: 140,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: const Text(
                    'User name',
                  ),
                ),
                Container(
                    color: MyApp.background,
                    width: 160,
                    child: users.when(
                        data: (userIds) {
                          return RawAutocomplete(
                              focusNode: focusUserName,
                              textEditingController: controllerUserName,
                              fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          textEditingController,
                                      FocusNode focusNode,
                                      VoidCallback onFieldSubmitted) =>
                                  TextField(
                                    focusNode: focusNode,
                                    controller: textEditingController,
                                    onEditingComplete: onFieldSubmitted,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.all(10),
                                      enabledBorder: _errorUserName != null
                                          ? const OutlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: Colors.red))
                                          : InputBorder.none,
                                      fillColor: MyApp.background,
                                      filled: true,
                                    ),
                                  ),
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) async {
                                if (textEditingValue ==
                                    TextEditingValue.empty) {
                                  return const Iterable<String>.empty();
                                }
                                var aux = userIds
                                    .where((e) =>
                                        e.contains(textEditingValue.text))
                                    .toList();
                                return aux;
                              },
                              onSelected: (String selection) {
                                setState(() {
                                  controllerUserName.text = selection;
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
                                          maxHeight: 300, maxWidth: 240),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final option =
                                              options.elementAt(index);
                                          return InkWell(
                                            onTap: () {
                                              onSelected(option);
                                            },
                                            child: Builder(builder:
                                                (BuildContext context) {
                                              final bool highlight =
                                                  AutocompleteHighlightedOption
                                                          .of(context) ==
                                                      index;
                                              if (highlight) {
                                                SchedulerBinding.instance
                                                    .addPostFrameCallback(
                                                        (Duration timeStamp) {
                                                  Scrollable.ensureVisible(
                                                      context,
                                                      alignment: 0.5);
                                                });
                                              }
                                              return Container(
                                                color: highlight
                                                    ? Theme.of(context)
                                                        .focusColor
                                                    : null,
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  option,
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                        error: (err, stack) => Text('$err'),
                        loading: () => const Center(
                            child: SizedBox(
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                strokeAlign: -3.0,
                              ),
                            )))),
                Text(
                  _errorUserName ?? '',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),

            ///
            /// Project name
            ///
            Row(
              children: [
                Container(
                  width: 140,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: const Text(
                    'Project name',
                  ),
                ),
                Container(
                    color: MyApp.background,
                    width: 260,
                    child: projects.when(
                        data: (projectNames) {
                          return RawAutocomplete(
                              focusNode: focusProjectName,
                              textEditingController: controllerProjectName,
                              fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          textEditingController,
                                      FocusNode focusNode,
                                      VoidCallback onFieldSubmitted) =>
                                  TextField(
                                    focusNode: focusNode,
                                    controller: textEditingController,
                                    onEditingComplete: onFieldSubmitted,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.all(10),
                                      enabledBorder: _errorProjectName != null
                                          ? const OutlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: Colors.red))
                                          : InputBorder.none,
                                      fillColor: MyApp.background,
                                      filled: true,
                                    ),
                                  ),
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) async {
                                if (textEditingValue ==
                                    TextEditingValue.empty) {
                                  return const Iterable<String>.empty();
                                }
                                var aux = projectNames
                                    .where((e) =>
                                        e.contains(textEditingValue.text))
                                    .toList();
                                return aux;
                              },
                              onSelected: (String selection) {
                                setState(() {
                                  controllerProjectName.text = selection;
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
                                          maxHeight: 300, maxWidth: 240),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final option =
                                              options.elementAt(index);
                                          return InkWell(
                                            onTap: () {
                                              onSelected(option);
                                            },
                                            child: Builder(builder:
                                                (BuildContext context) {
                                              final bool highlight =
                                                  AutocompleteHighlightedOption
                                                          .of(context) ==
                                                      index;
                                              if (highlight) {
                                                SchedulerBinding.instance
                                                    .addPostFrameCallback(
                                                        (Duration timeStamp) {
                                                  Scrollable.ensureVisible(
                                                      context,
                                                      alignment: 0.5);
                                                });
                                              }
                                              return Container(
                                                color: highlight
                                                    ? Theme.of(context)
                                                        .focusColor
                                                    : null,
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  option,
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                        error: (err, stack) => Text('$err'),
                        loading: () => const CircularProgressIndicator())),
                Text(
                  _errorProjectName ?? '',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 36.0),
          child: SizedBox(
            width: 500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    context.pop();
                    setState(() {
                      // ref.read(providerOfMarksAsOf.notifier).reset();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    // var poly = PolygraphState.getProject(userId, projectName)

                    // if (state.getErrors().isEmpty) {
                    //   context.pop(state);
                    //   setState(() {
                    //     // ref.read(providerOfPolygraph.notifier).refreshActiveWindow = true;
                    //     // ref.read(providerOfMarksAsOf.notifier).reset();
                    //   });
                    // }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void validateUserName() {
    _errorUserName = null;
    var userIds = ref.read(providerOfUsers).value;
    if (userIds != null && !userIds.contains(controllerUserName.text)) {
      _errorUserName = '  User ${controllerUserName.text} does not exist!';
    }
  }

  void validateProjectName() {
    _errorProjectName = null;
    var projectNames =
        ref.read(providerOfProjectNames(controllerUserName.text)).value;
    if (projectNames != null &&
        !projectNames.contains(controllerProjectName.text)) {
      _errorProjectName =
          '  ${controllerProjectName.text} does not exist';
    }
  }
}
