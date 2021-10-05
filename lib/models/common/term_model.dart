library models.term_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class TermModel extends ChangeNotifier {
  TermModel();

  late Term _term;

  /// Set the _term without triggering a notification.
  /// Useful to set the term to the calculator term.
  void init(Term term) => _term = term;

  // static Term _defaultTerm() {
  //   return Term.parse('Jul21', UTC);
  // }

  set term(Term term) {
    _term = term;
    // propagate the changes from the UI
    notifyListeners();
  }

  Term get term => _term;
}
