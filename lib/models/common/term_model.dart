library models.term_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class TermModel extends ChangeNotifier {
  TermModel({required Term term}) {
    _term = term;
  }

  late Term _term;

  set term(Term term) {
    _term = term;
    notifyListeners();
  }

  Term get term => _term;
}
