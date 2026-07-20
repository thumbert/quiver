import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_quiver/models/eod_settlement/endur_row.dart';
import 'package:flutter_quiver/models/eod_settlement/eod_settlement_model.dart';
import 'package:signals_flutter/signals_flutter.dart';

// ignore: unused_import
// import 'package:elec_server/client/ui/eod_settlements/views_asof_date.dart';

class EndurSection extends StatefulWidget {
  const EndurSection({super.key});

  @override
  State<EndurSection> createState() => _EndurSectionState();
}

class _EndurSectionState extends State<EndurSection> {
  List<EndurRow>? _rows;
  int? _editingRowIndex;
  String? _editingField;
  bool _isStartingEdit = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final void Function() _effect;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _effect = effect(() {
      final val = getRecords.value;
      if (val case AsyncData(:final value)) {
        final filtered = value.where((r) => r.endurCurveName != null).toList();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _editingRowIndex == null) {
            setState(() {
              _rows = filtered.map(EndurRow.fromRecord).toList();
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _effect();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && !_isStartingEdit) {
      _commitEdit();
    }
  }

  void _startEditing(int rowIndex, String field) {
    _isStartingEdit = true;
    _commitEdit();
    final row = _rows![rowIndex];
    final text = switch (field) {
      'curveName' => row.curveName.value ?? '',
      'asOf' => row.asOf.value?.toIso8601String() ?? '',
      'strip' => row.strip.value ?? '',
      'unitConversion' => row.unitConversion.value ?? '',
      'label' => row.label.value,
      _ => '',
    };
    setState(() {
      _editingRowIndex = rowIndex;
      _editingField = field;
      _controller.text = text;
      _controller.selection =
          TextSelection(baseOffset: 0, extentOffset: text.length);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _isStartingEdit = false;
    });
  }

  void _copyRow(int index) {
    _commitEdit();
    final src = _rows![index];
    final copy = EndurRow(
      curveName: src.curveName.value,
      asOf: src.asOf.value,
      strip: src.strip.value,
      unitConversion: src.unitConversion.value,
    );
    copy.label.value = src.label.value;
    setState(() {
      _rows!.insert(index + 1, copy);
    });
  }

  void _deleteRow(int index) {
    _commitEdit();
    setState(() {
      _rows!.removeAt(index);
    });
  }

  void _commitEdit() {
    if (_editingRowIndex == null || _editingField == null) return;
    final row = _rows![_editingRowIndex!];
    final value = _controller.text;
    switch (_editingField!) {
      case 'curveName':
        row.curveName.value = value.isEmpty ? null : value;
      case 'asOf':
        try {
          row.asOf.value =
              value.isEmpty ? null : Date.parse(value, location: UTC);
        } catch (_) {
          // keep existing value on parse error
        }
      case 'strip':
        row.strip.value = value.isEmpty ? null : value;
      case 'unitConversion':
        row.unitConversion.value = value.isEmpty ? null : value;
      case 'label':
        row.label.value = value;
    }
    setState(() {
      _editingRowIndex = null;
      _editingField = null;
    });
  }

  Widget _editableCell({
    required int rowIndex,
    required String field,
    required double width,
    required String displayText,
  }) {
    final isEditing = _editingRowIndex == rowIndex && _editingField == field;
    if (isEditing) {
      return SizedBox(
        width: width,
        height: 28,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _commitEdit(),
        ),
      );
    }
    return GestureDetector(
      onTap: () => _startEditing(rowIndex, field),
      child: SizedBox(
        width: width,
        child: Text(displayText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 24,
      child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            trailing: const Icon(Icons.keyboard_arrow_down),
            collapsedBackgroundColor: Colors.purple.shade50,
            initiallyExpanded: true,
            title: Text('Endur settlement prices',
                style: TextStyle(fontSize: 16, color: Colors.purple.shade800)),
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 16.0), child: header()),
              SignalBuilder(builder: (_) => switch (getRecords.value) {
                    AsyncLoading() => const CircularProgressIndicator(),
                    AsyncError() =>
                      const Text('Error loading records from database'),
                    AsyncData() => const SizedBox.shrink(),
                  }),
              if (_rows != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    children: [
                      for (int i = 0; i < _rows!.length; i++)
                        _row(_rows![i], i),
                    ],
                  ),
                ),
            ],
          )),
    );
  }

  Widget _row(EndurRow rowData, int index) {
    return Row(
      spacing: 4,
      children: [
        _editableCell(
            rowIndex: index,
            field: 'curveName',
            width: 320,
            displayText: rowData.curveName.value ?? ''),
        _editableCell(
            rowIndex: index,
            field: 'asOf',
            width: 100,
            displayText: rowData.asOf.value?.toIso8601String() ?? ''),
        _editableCell(
            rowIndex: index,
            field: 'strip',
            width: 80,
            displayText: rowData.strip.value ?? ''),
        _editableCell(
            rowIndex: index,
            field: 'unitConversion',
            width: 240,
            displayText: rowData.unitConversion.value ?? ''),
        _editableCell(
            rowIndex: index,
            field: 'label',
            width: 200,
            displayText: rowData.label.value),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          tooltip: '',
          onSelected: (action) {
            if (action == 'copy') {
              _copyRow(index);
            } else if (action == 'delete') {
              _deleteRow(index);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'copy', child: Text('Copy row')),
            PopupMenuItem(value: 'delete', child: Text('Delete row')),
          ],
        ),
      ],
    );
  }

  Widget header() {
    return Row(
      spacing: 4,
      children: [
        SizedBox(
            width: 320,
            child: const Text(
              'Curve name',
              style: TextStyle(fontSize: 14, color: Colors.purple),
            )),
        SizedBox(
            width: 100,
            child: const Text(
              'As of date',
              style: TextStyle(fontSize: 14, color: Colors.purple),
            )),
        SizedBox(
            width: 80,
            child: const Text(
              'Strip',
              style: TextStyle(fontSize: 14, color: Colors.purple),
            )),
        SizedBox(
            width: 240,
            child: const Text(
              'Unit conversion',
              style: TextStyle(fontSize: 14, color: Colors.purple),
            )),
        SizedBox(
            width: 200,
            child: const Text(
              'Label',
              style: TextStyle(fontSize: 14, color: Colors.purple),
            )),
      ],
    );
  }
}
