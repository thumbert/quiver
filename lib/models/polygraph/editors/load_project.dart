// library models.polygraph.editors.load_project;
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// class LoadProject {
//   LoadProject({required this.userId, required this.projectName});
//
//   final String userId;
//   final String projectName;
//
//   static getDefault() => LoadProject(userId: '', projectName: '');
//
//   LoadProject copyWith({
//     String? userId,
//     String? projectName,
//   }) =>
//       LoadProject(
//           userId: userId ?? this.userId,
//           projectName: projectName ?? this.projectName);
// }
//
// class LoadProjectNotifier extends StateNotifier<LoadProject> {
//   LoadProjectNotifier(this.ref) : super(LoadProject.getDefault());
//
//   final Ref ref;
//
//   set userId(String value) {
//     state = state.copyWith(userId: value);
//   }
//
//   set projectName(String value) {
//     state = state.copyWith(projectName: value);
//   }
// }
