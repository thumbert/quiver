import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:elec_server/client/ui/eod_settlements/views_asof_date.dart';

final userName = signal<String?>('adrian', debugLabel: 'userName');
final viewName = signal<String?>('mass hub', debugLabel: 'viewName');

class Model {
  Model() {
    _userIdEffect = effect(onUpdateUserName);
  }

  // ignore: unused_field
  late final void Function() _userIdEffect;
}

final model = Model();

final uniqueUsersViews = futureSignal(() async {
  if (cacheUsersViews.length == 1) {
    final uniqueViews = await getUniqueUserIdAndViewNamePairs(
        rootUrl: dotenv.env['RUST_SERVER']!);
    cacheUsersViews.addAll(uniqueViews);
  }
  return cacheUsersViews;
}, debugLabel: 'uniqueUsersViews');

final getRecords = futureSignal(() async {
  if (cacheRecords.isEmpty) {
    final records = await queryRecords(
        filter: QueryFilter(), rootUrl: dotenv.env['RUST_SERVER']!);
    cacheRecords.addAll(records);
  }
  return cacheRecords
      .where((e) => e.userId == userName.value && e.viewName == viewName.value)
      .toList();
}, debugLabel: 'getRecords', dependencies: [userName, viewName]);

final cacheUsersViews = <({String userId, String viewName})>[
  (userId: 'adrian', viewName: 'mass hub')
];
final cacheRecords = <Record>[];

void onUpdateUserName() {
  if (userName.value == null) {
    viewName.value = null; // Clear the view name when the user changes
  } else {
    final views = cacheUsersViews
        .where((e) => e.userId == userName.value)
        .map((e) => e.viewName)
        .toList();
    if (views.length == 1) {
      viewName.value = views.first; // Auto-select the view if there's only one
    } else {
      viewName.value =
          null; // Clear the view name if there are multiple or none
    }
  }
}
