library providers.term_provider;

import 'package:date/date.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

final providerOfTerm =
    StateNotifierProvider<TermModel2, Term>((ref) => TermModel2(ref));

class TermModel2 extends StateNotifier<Term> {
  TermModel2(this.ref) : super(Term.parse('Jan22', UTC));

  final Ref ref;

  set term(Term value) {
    state = value;
  }
}
