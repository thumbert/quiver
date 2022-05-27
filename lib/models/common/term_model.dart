library models.term_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class TermModel extends ChangeNotifier {
  TermModel({required Term term, Location? tzLocation}) {
    tzLocation ??= UTC;
    _term = term;
  }

  late Term _term;

  /// The term from the UI can be in a different tz than the existing term.
  set term(Term term) {
    _term = term;
    notifyListeners();
  }

  Term get term => _term;
}

class ForwardTermModel extends TermModel {
  ForwardTermModel({required Term term}) : super(term: term);
}

class HistoricalTermModel extends TermModel {
  HistoricalTermModel({required Term term}) : super(term: term);
}
