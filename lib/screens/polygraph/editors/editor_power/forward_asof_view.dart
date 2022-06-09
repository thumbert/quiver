library screens.polygraph.editors.editor_power.forward_asof_view;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/screens/polygraph/editors/view_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

final providerOfForwardAsOfView =
    StateNotifierProvider<ForwardAsOfViewNotifier, ForwardAsOfView>(
        (ref) => ForwardAsOfViewNotifier(ref));

class ForwardAsOfView extends Object with ViewEditor {
  ForwardAsOfView(
      {required this.asOfDate,
      required this.bucket,
      required this.forwardTerm}) {
    name = 'Forward, as of';
  }

  late final Date asOfDate;
  late final Bucket bucket;
  late final Term forwardTerm;

  ForwardAsOfView copyWith(
      {Date? asOfDate, Bucket? bucket, Term? forwardTerm}) {
    return ForwardAsOfView(
        asOfDate: asOfDate ?? this.asOfDate,
        bucket: bucket ?? this.bucket,
        forwardTerm: forwardTerm ?? this.forwardTerm);
  }

  @override
  ViewEditor fromJson(Map<String, dynamic> json) {
    return ForwardAsOfView(
        asOfDate: Date.parse(json['asOfDate']),
        bucket: Bucket.parse(json['bucket']),
        forwardTerm: Term.parse(json['forwardTerm'], UTC));
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': 'Forward, as of',
      'asOfDate': asOfDate.toString(),
      'bucket': bucket.toString(),
      'forwardTerm': forwardTerm.toString(),
    };
  }
}

class ForwardAsOfViewNotifier extends StateNotifier<ForwardAsOfView> {
  ForwardAsOfViewNotifier(this.ref)
      : super(ForwardAsOfView(
            asOfDate: Date.utc(2022, 5, 13),
            bucket: Bucket.b5x16,
            forwardTerm: Term.parse('Cal25', UTC)));
  final Ref ref;
  set asOfDate(Date value) {
    state = state.copyWith(asOfDate: value);
  }

  set bucket(Bucket value) {
    state = state.copyWith(bucket: value);
  }

  set forwardTerm(Term value) {
    state = state.copyWith(forwardTerm: value);
  }
}

// class ForwardAsOfUi extends StatefulWidget {
//   const ForwardAsOfUi({Key? key}) : super(key: key);
//   @override
//   State<ForwardAsOfUi> createState() => _ForwardAsOfUiState();
// }
//
// class _ForwardAsOfUiState extends State<ForwardAsOfUi> {
//   @override
//   Widget build(BuildContext context) {
//     // final regionModel = context.watch<RegionModel>();
//     // final deliveryPointModel = context.watch<PowerDeliveryPointModel>();
//
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: const [
//             Text(
//               'Forward Term',
//               style: TextStyle(fontSize: 16),
//             ),
//             ForwardTermUi(),
//           ],
//         ),
//       ],
//     );
//   }
// }
