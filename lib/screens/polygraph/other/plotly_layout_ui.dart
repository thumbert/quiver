library screens.polygraph.other.plotly_layout_ui;

import 'package:flutter/material.dart' hide Interval, Transform;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_margin.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_title.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfPlotlyLayout =
    StateProvider((ref) => PlotlyLayout()..legend = PlotlyLegend.getDefault());

class PlotlyLayoutUi extends ConsumerStatefulWidget {
  const PlotlyLayoutUi({Key? key}) : super(key: key);

  @override
  ConsumerState<PlotlyLayoutUi> createState() => _PlotlyLayoutUiState();
}

class _PlotlyLayoutUiState extends ConsumerState<PlotlyLayoutUi> {
  final controllerTitleText = TextEditingController();
  final controllerXAxisText = TextEditingController();
  final controllerYAxisText = TextEditingController();
  final controllerMarginLeft = TextEditingController();
  final controllerMarginBottom = TextEditingController();
  final controllerMarginTop = TextEditingController();
  final controllerMarginRight = TextEditingController();

  final focusTitle = FocusNode();
  final focusXAxisText = FocusNode();
  final focusYAxisText = FocusNode();
  final focusMarginLeft = FocusNode();
  final focusMarginBottom = FocusNode();
  final focusMarginTop = FocusNode();
  final focusMarginRight = FocusNode();

  String? _errorMarginLeft,
      _errorMarginBottom,
      _errorMarginTop,
      _errorMarginRight;

  /// Have this here too for convenience
  // String _errorMessage = '';
  bool pressedOk = false;
  int activeTab = 0;

  late PlotlyLayout layout;

  @override
  void initState() {
    super.initState();
    var plotly = ref.read(providerOfPolygraph);
    layout = plotly.activeWindow.layout;

    controllerTitleText.text = layout.title?.text ?? '';
    controllerXAxisText.text = layout.xAxis?.title?.text ?? '';
    controllerYAxisText.text = layout.yAxis?.title?.text ?? '';
    controllerMarginBottom.text =
        (layout.margin?.bottom ?? PlotlyMargin.defaultBottomPx).toString();
    controllerMarginLeft.text =
        (layout.margin?.left ?? PlotlyMargin.defaultLeftPx).toString();
    controllerMarginRight.text =
        (layout.margin?.right ?? PlotlyMargin.defaultRightPx).toString();
    controllerMarginTop.text =
        (layout.margin?.top ?? PlotlyMargin.defaultTopPx).toString();

    focusTitle.addListener(() {
      if (!focusTitle.hasFocus) {
        setState(() {
          var title = layout.title ?? PlotlyTitle()
            ..text = controllerTitleText.text;
          ref.read(providerOfPlotlyLayout.notifier).state =
              layout.copyWith(title: title);
        });
      }
    });
  }

  @override
  void dispose() {
    controllerTitleText.dispose();
    controllerXAxisText.dispose();
    controllerYAxisText.dispose();
    controllerMarginBottom.dispose();
    controllerMarginLeft.dispose();
    controllerMarginRight.dispose();
    controllerMarginTop.dispose();

    focusTitle.dispose();
    focusXAxisText.dispose();
    focusYAxisText.dispose();
    focusMarginBottom.dispose();
    focusMarginLeft.dispose();
    focusMarginRight.dispose();
    focusMarginTop.dispose();

    super.dispose();
  }

  Widget _makeTab0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///
        /// Title row
        ///
        Row(
          children: [
            Container(
              width: 130,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Text(
                'Title',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Container(
              color: MyApp.background,
              width: 240,
              child: TextField(
                style: const TextStyle(fontSize: 14),
                controller: controllerTitleText,
                focusNode: focusTitle,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    var title = layout.title ?? PlotlyTitle()
                      ..text = controllerTitleText.text;
                    ref.read(providerOfPlotlyLayout.notifier).state =
                        layout.copyWith(title: title);
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    var title = layout.title ?? PlotlyTitle()
                      ..text = controllerTitleText.text;
                    ref.read(providerOfPlotlyLayout.notifier).state =
                        layout.copyWith(title: title);
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),

        ///
        /// Legend position
        ///
        Row(
          children: [
            Container(
              width: 130,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 12),
              child: const Text(
                'Legend position',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Container(
              color: MyApp.background,
              padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
              width: 120,
              child: DropdownButtonFormField(
                value: layout.legend?.orientation.toString() == 'h'
                    ? 'horizontal'
                    : 'vertical',
                icon: const Icon(Icons.expand_more),
                hint: const Text('Filter'),
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  isDense: true,
                  enabledBorder: InputBorder.none,
                ),
                // elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    var legend = layout.legend ?? PlotlyLegend.getDefault();
                    legend.orientation = newValue == 'horizontal'
                        ? LegendOrientation.horizontal
                        : LegendOrientation.vertical;
                    ref.read(providerOfPlotlyLayout.notifier).state =
                        layout.copyWith(legend: legend);
                  });
                },
                items: ['horizontal', 'vertical']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            ),
            const SizedBox(
              width: 36,
            ),
            Container(
              width: 160,
              padding: const EdgeInsets.only(left: 28),
              child: CheckboxListTile(
                  title: const Text(
                    'Show legend',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: layout.showLegend,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (bool? value) {
                    ref.read(providerOfPlotlyLayout.notifier).state =
                        layout.copyWith(showLegend: value);
                  }),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),


        ///
        /// Plot margins
        ///
        Row(
          children: [
            Container(
              width: 130,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Text(
                'Plot margins',
                style: TextStyle(fontSize: 14),
              ),
            ),

            // const SizedBox(width: 6,),
            // Container(
            //   width: 50,
            //   alignment: Alignment.centerRight,
            //   padding: const EdgeInsets.only(right: 4),
            //   child: const Text(
            //     'Left',
            //     style: TextStyle(fontSize: 14),
            //   ),
            // ),
            // const SizedBox(width: 4,),

            Container(
              color: MyApp.background,
              width: 48,
              child: TextFormField(
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
                controller: controllerMarginLeft,
                focusNode: focusMarginLeft,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(4),
                  enabledBorder: InputBorder.none,
                  labelText: 'Left',
                ),
                onEditingComplete: () => setLeftMargin(),
              ),
            ),
            const SizedBox(width: 24,),


            Column(
              children: [
                const Text(
                  'Left',
                  style: TextStyle(fontSize: 14),
                ),
                Container(
                  color: MyApp.background,
                  width: 48,
                  child: TextField(
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14),
                    controller: controllerMarginLeft,
                    focusNode: focusMarginLeft,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                      enabledBorder: InputBorder.none,
                    ),
                    onEditingComplete: () => setLeftMargin(),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12,),
            const Text(
              'Bottom',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4,),
            Container(
              color: MyApp.background,
              width: 48,
              child: TextField(
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
                controller: controllerMarginBottom,
                focusNode: focusMarginBottom,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () => setBottomMargin(),
              ),
            ),
            const SizedBox(width: 12,),
            const Text(
              'Top',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4,),
            Container(
              color: MyApp.background,
              width: 48,
              child: TextField(
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
                controller: controllerMarginTop,
                focusNode: focusMarginTop,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () => setTopMargin(),
              ),
            ),
            const SizedBox(width: 12,),
            const Text(
              'Right',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4,),
            Container(
              color: MyApp.background,
              width: 48,
              child: TextField(
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
                controller: controllerMarginRight,
                focusNode: focusMarginRight,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () => setRightMargin(),
              ),
            ),

          ],
        ),
      ],
    );
  }

  Widget _makeTab1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///
        /// Title row
        ///
        Row(
          children: [
            Container(
              width: 130,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Text(
                'Label',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Container(
              color: MyApp.background,
              width: 240,
              child: TextField(
                style: const TextStyle(fontSize: 14),
                controller: controllerXAxisText,
                focusNode: focusXAxisText,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    var xAxis = layout.xAxis ?? PlotlyXAxis();
                    var title = xAxis.title ?? PlotlyAxisTitle()
                      ..text = controllerXAxisText.text;
                    xAxis.title = title;
                    ref.read(providerOfPlotlyLayout.notifier).state =
                        layout.copyWith(xAxis: xAxis);
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    var xAxis = layout.xAxis ?? PlotlyXAxis();
                    var title = xAxis.title ?? PlotlyAxisTitle()
                      ..text = controllerXAxisText.text;
                    xAxis.title = title;
                    ref.read(providerOfPlotlyLayout.notifier).state =
                        layout.copyWith(xAxis: xAxis);
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),

        ///
        /// Axis type
        ///
        Row(
          children: [
            Container(
              width: 130,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 12),
              child: const Text(
                'Axis type',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Container(
              color: MyApp.background,
              padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
              width: 130,
              child: DropdownButtonFormField(
                value: layout.xAxis?.type?.toString() ?? '-',
                icon: const Icon(Icons.expand_more),
                hint: const Text('Filter'),
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  isDense: true,
                  enabledBorder: InputBorder.none,
                ),
                // elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    var xAxis = layout.xAxis ?? PlotlyXAxis();
                    xAxis.type = AxisType.parse(newValue!);
                    ref.read(providerOfPlotlyLayout.notifier).state =
                        layout.copyWith(xAxis: xAxis);
                  });
                },
                items: AxisType.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            )
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        ///
        /// Show grid lines
        ///
        Container(
          width: 154,
          padding: const EdgeInsets.only(left: 44),
          child: CheckboxListTile(
              title: const Text(
                'Show grid',
                style: TextStyle(fontSize: 14),
              ),
              value: layout.xAxis?.showGrid ?? true,
              dense: true,
              controlAffinity: ListTileControlAffinity.trailing,
              contentPadding: EdgeInsets.zero,
              onChanged: (bool? value) {
                var xAxis = layout.xAxis ?? PlotlyXAxis();
                xAxis.showGrid = value!;
                // print('xAxis.showGrid = ${xAxis.showGrid}');
                ref.read(providerOfPlotlyLayout.notifier).state =
                    layout.copyWith(xAxis: xAxis);
              }),
        ),
      ],
    );
  }

  void setLeftMargin() {
    setState(() {
      var value = num.tryParse(controllerMarginLeft.text);
      if (value != null) {
        var margin = layout.margin ?? PlotlyMargin();
        if (value > 0) {
          margin.left = value;
        }
        ref.read(providerOfPlotlyLayout.notifier).state =
            layout.copyWith(margin: margin);
      } else {
        _errorMarginLeft = 'Incorrect number of px for left margin';
      }
    });
  }

  void setBottomMargin() {
    setState(() {
      var value = num.tryParse(controllerMarginBottom.text);
      if (value != null) {
        var margin = layout.margin ?? PlotlyMargin();
        if (value > 0) {
          margin.bottom = value;
        }
        ref.read(providerOfPlotlyLayout.notifier).state =
            layout.copyWith(margin: margin);
      } else {
        _errorMarginBottom = 'Incorrect number of px for bottom margin';
      }
    });
  }

  void setTopMargin() {
    setState(() {
      var value = num.tryParse(controllerMarginTop.text);
      if (value != null) {
        var margin = layout.margin ?? PlotlyMargin();
        if (value > 0) {
          margin.top = value;
        }
        ref.read(providerOfPlotlyLayout.notifier).state =
            layout.copyWith(margin: margin);
      } else {
        _errorMarginTop = 'Incorrect number of px for top margin';
      }
    });
  }

  void setRightMargin() {
    setState(() {
      var value = num.tryParse(controllerMarginRight.text);
      if (value != null) {
        var margin = layout.margin ?? PlotlyMargin();
        if (value > 0) {
          margin.right = value;
        }
        ref.read(providerOfPlotlyLayout.notifier).state =
            layout.copyWith(margin: margin);
      } else {
        _errorMarginRight = 'Incorrect number of px for right margin';
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    layout = ref.watch(providerOfPlotlyLayout);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// Tabs
            ///
            Wrap(
              children: [
                /// Main
                ///
                TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() {
                        activeTab = 0;
                      });
                    },
                    child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 2,
                                color: activeTab == 0
                                    ? Colors.deepOrange
                                    : Colors.grey[300]!),
                          ),
                        ),
                        child: const Center(child: Text('Main')))),
                const SizedBox(
                  width: 4,
                ),

                /// X axis
                ///
                TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() {
                        activeTab = 1;
                      });
                    },
                    child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 2,
                                color: activeTab == 1
                                    ? Colors.deepOrange
                                    : Colors.grey[300]!),
                          ),
                        ),
                        child: const Center(child: Text('X axis')))),
                const SizedBox(
                  width: 4,
                ),

                /// Y axis
                ///
                TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() {
                        activeTab = 2;
                      });
                    },
                    child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 2,
                                color: activeTab == 2
                                    ? Colors.deepOrange
                                    : Colors.grey[300]!),
                          ),
                        ),
                        child: const Center(child: Text('Y axis')))),
              ],
            ),

            const SizedBox(
              height: 16,
            ),
            if (activeTab == 0) _makeTab0(),
            if (activeTab == 1) _makeTab1(),
            // if (activeTab == 2) _makeTab2(),
          ],
        ),
      ],
    );
  }
}
