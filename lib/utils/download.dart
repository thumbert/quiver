import 'dart:convert';
import 'package:web/web.dart';

/// See https://stackoverflow.com/questions/59783344/flutter-web-download-option
void download(
  List<int> bytes, {
  required String downloadName,
}) {
  // Encode our file in base64
  final content = base64Encode(bytes);
  // Create the link with the file
  final anchor = HTMLAnchorElement()
    ..href = 'data:application/octet-stream;base64,$content'
    ..target = 'blank'
    ..download = downloadName;

  // trigger download
  document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  return;
}
