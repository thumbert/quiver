library screens.monthly_asset_ncpc.asset_autocomplete;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/monthly_asset_ncpc/asset_autocomplete_model.dart';
import 'package:provider/provider.dart';

class AssetAutocomplete extends StatefulWidget {
  const AssetAutocomplete({Key? key}) : super(key: key);

  @override
  _AssetAutocompleteState createState() => _AssetAutocompleteState();
}

class _AssetAutocompleteState extends State<AssetAutocomplete> {
  final focusNode = FocusNode();
  final textEditingController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AssetAutocompleteModel>();
    return Autocomplete<String>(
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            setState(() {
              if (AssetAutocompleteModel.assetNames
                  .contains(textEditingController.text)) {
                model.assetName = textEditingController.text;
              } else {
                if (textEditingController.text == '') {
                  // an empty string is OK, means all assets
                  model.assetName = null;
                } else {
                  // other gibberish is an error
                  _error = 'Invalid name';
                }
              }
            });
          }
        });
        return TextFormField(
          focusNode: focusNode,
          controller: textEditingController,
          decoration: InputDecoration(
            errorText: _error,
          ),
          onEditingComplete: () {
            setState(() {
              if (AssetAutocompleteModel.assetNames
                  .contains(textEditingController.text)) {
                model.assetName = textEditingController.text;
                _error = null;
              } else {
                // if it's empty or some string that is not right
                model.assetName = null;
                _error = 'Error';
              }
            });
          },
          onFieldSubmitted: (value) {
            // when you press Enter on the dropdown
            // print('submitted $value');
          },
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return AssetAutocompleteModel.assetNames
            .where((e) => e.startsWith(textEditingValue.text.toUpperCase()));
      },
      onSelected: (String selection) {
        // print('Selected: _${selection}_');
        setState(() {
          model.assetName = selection;
        });
      },
      optionsMaxHeight: 350,
    );
  }
}
