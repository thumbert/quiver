// library models.polygraph.editors.marks_asof;
//
// import 'dart:convert';
//
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:date/date.dart';
// import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
// import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
// import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart';
// import 'package:timeseries/timeseries.dart';
// import 'package:timezone/timezone.dart';
//
// final providerOfCurveNames =
//     FutureProvider.family<List<String>, Date>((ref, asOfDate) async {
//   final rootUrl = dotenv.env['ROOT_URL'] as String;
//   var url =
//       '$rootUrl/forward_marks/v1/price/curvenames/asofdate/${asOfDate.toString()}';
//   var res = await get(Uri.parse(url));
//   return (json.decode(res.body) as List).cast<String>();
// });
//
// class MarksAsof extends PolygraphVariable {
//   MarksAsof({
//     required this.asOfDate,
//     String? label,
//     required this.curveName,
//   }) {
//     this.label = label ?? curveName;
//   }
//
//   final Date asOfDate;
//   final String curveName;
//
//   static getDefault() => MarksAsof(
//         asOfDate: Date.utc(2023, 7, 7),
//         label: 'Henry',
//         curveName: 'NG_HENRY_HUB_CME',
//       );
//
//   bool hasInvalidLabel() => label == '';
//
//   bool hasInvalidCurveName() => false;
//
//   List<String> getErrors() {
//     return <String>[
//       if (hasInvalidLabel()) 'Label can\'t be empty',
//       if (hasInvalidCurveName()) 'Wrong curve name',
//     ];
//   }
//
//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'type': 'MarskAsof',
//       'asOfDate': asOfDate.toString(),
//       'label': label,
//       'curveName': curveName,
//       'displayConfig':
//           displayConfig == null ? <String, dynamic>{} : displayConfig!.toJson(),
//     };
//   }
//
//   static MarksAsof fromMongo(Map<String, dynamic> x) {
//     if (x['type'] != 'MarksAsof') {
//       throw ArgumentError('Input doesn\'t have type MarksAsof');
//     }
//     if (x
//         case {
//           'asOfDate': String asOfDate,
//           'curveName': String curveName,
//           'label': String label,
//           'displayConfig': Map<String, dynamic> displayConfig,
//         }) {
//       var config = VariableDisplayConfig.fromMap(displayConfig);
//       return MarksAsof(
//           asOfDate: Date.fromIsoString(asOfDate, location: UTC),
//           curveName: curveName,
//           label: label)
//         ..displayConfig = config;
//     } else {
//       throw ArgumentError(
//           'Input in not a correctly formatted TransformedVariable');
//     }
//   }
//
//   MarksAsof copyWith({
//     Date? asOfDate,
//     String? curveName,
//     String? label,
//   }) =>
//       MarksAsof(
//         asOfDate: asOfDate ?? this.asOfDate,
//         label: label ?? this.label,
//         curveName: curveName ?? this.curveName,
//       );
//
//   @override
//   Future<TimeSeries<num>> get(DataService service, Term term) {
//     // TODO: implement get
//     throw UnimplementedError();
//   }
// }
//
// class MarksAsofNotifier extends StateNotifier<MarksAsof> {
//   MarksAsofNotifier(this.ref) : super(MarksAsof.getDefault());
//
//   final Ref ref;
//
//   set asOfDate(Date value) {
//     state = state.copyWith(asOfDate: value);
//   }
//
//   set curveName(String value) {
//     state = state.copyWith(curveName: value);
//   }
//
//   set label(String value) {
//     state = state.copyWith(label: value);
//   }
//
//   void fromMongo(Map<String, dynamic> x) {
//     state = MarksAsof.fromMongo(x);
//   }
//
//   void reset() {
//     state = MarksAsof.getDefault();
//   }
// }
