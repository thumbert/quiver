library models.polygraph.editors.ok_button;

import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfClickedOk = StateNotifierProvider<OkButtonNotifier, OkButton>(
        (ref) => OkButtonNotifier(ref));

class OkButton {
  OkButton(this.pushed);
  
  final bool pushed;

  OkButton copyWith({bool? pushed}) => OkButton(pushed ?? this.pushed);
}

class OkButtonNotifier extends StateNotifier<OkButton> {
  OkButtonNotifier(this.ref)
      : super(OkButton(false));

  final Ref ref;

  set pushed(bool value) {
    state = state.copyWith(pushed: value);
  }
}
