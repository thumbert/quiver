library screens.polygraph.other.tab_layout_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabLayoutUi extends ConsumerStatefulWidget {
  const TabLayoutUi({Key? key}) : super(key: key);

  @override
  ConsumerState<TabLayoutUi> createState() => _TabLayoutUiState();
}

class _TabLayoutUiState extends ConsumerState<TabLayoutUi> {
  final controllerWidth = TextEditingController();
  final controllerHeight = TextEditingController();

  final focusWidth = FocusNode();
  final focusHeight = FocusNode();

  String _errorWidth = '';
  String _errorHeight = '';

  @override
  void initState() {
    super.initState();
    var poly = ref.read(providerOfPolygraph);
    var tab = poly.tabs[poly.activeTabIndex];

    controllerWidth.text = tab.layout.canvasSize.width.toString();
    controllerHeight.text = tab.layout.canvasSize.height.toString();

    focusWidth.addListener(() {
      if (!focusWidth.hasFocus) {
        setState(() {
          validateWidth();
        });
      }
    });
    focusHeight.addListener(() {
      if (!focusHeight.hasFocus) {
        setState(() {
          validateHeight();
        });
      }
    });
  }

  @override
  void dispose() {
    controllerWidth.dispose();
    controllerHeight.dispose();
    focusWidth.dispose();
    focusHeight.dispose();
    super.dispose();
  }

  void validateWidth() {
    _errorWidth = num.tryParse(controllerWidth.text) == null ? 'Please enter a number' : '';
  }

  void validateHeight() {
    _errorHeight = num.tryParse(controllerHeight.text) == null ? 'Please enter a number' : '';
  }

  @override
  Widget build(BuildContext context) {
    var poly = ref.watch(providerOfPolygraph);
    var tab = poly.tabs[poly.activeTabIndex];

    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tab display configuration',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Container(
                    width: 120,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(right: 8),
                    child: const Text('Canvas width')),
                Container(
                  color: MyApp.background,
                  width: 80,
                  child: TextField(
                    controller: controllerWidth,
                    focusNode: focusWidth,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      enabledBorder: InputBorder.none,
                    ),
                    onEditingComplete: () {
                      setState(() {
                        validateWidth();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                if (controllerWidth.text == '' || _errorWidth != '')
                  Text(
                    _errorWidth,
                    style: const TextStyle(color: Colors.red, fontSize: 10),
                  ),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              children: [
                Container(
                    width: 120,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(right: 8),
                    child: const Text('Canvas height')),
                Container(
                  color: MyApp.background,
                  width: 80,
                  child: TextField(
                    controller: controllerHeight,
                    focusNode: focusHeight,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      enabledBorder: InputBorder.none,
                    ),
                    onEditingComplete: () {
                      setState(() {
                        validateHeight();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                if (controllerHeight.text == '' || _errorHeight != '')
                  Text(
                    _errorHeight,
                    style: const TextStyle(color: Colors.red, fontSize: 10),
                  ),
              ],
            ),
            const SizedBox(
              height: 36,
            ),
          ],
        ),
        ElevatedButton(
            onPressed: () {
              validateHeight();
              validateWidth();
              if (_errorWidth == '' && _errorHeight == '') {
                Navigator.of(context).pop();
                setState(() {
                  var width = num.parse(controllerWidth.text).toDouble();
                  var height = num.parse(controllerHeight.text).toDouble();
                  var tabLayout = tab.layout.copyWith(canvasSize: Size(width, height));
                  var windowSize = tabLayout.windowSize();
                  var windows = tab.windows
                      .map((window) => window.copyWith(
                          layout: window.layout.copyWith(width: windowSize.width, height: windowSize.height)))
                      .toList();
                  tab = tab.copyWith(layout: tabLayout, windows: windows);
                  ref.read(providerOfPolygraph.notifier).activeTab = tab;
                });
              }
            },
            child: const Text('OK')),
      ],
    );
  }
}
