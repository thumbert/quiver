import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

/// See https://stackoverflow.com/questions/59783344/flutter-web-download-option
void download(
  List<int> bytes, {
  required String downloadName,
}) {
  // Encode our file in base64
  final _base64 = base64Encode(bytes);
  // Create the link with the file
  final anchor =
      AnchorElement(href: 'data:application/octet-stream;base64,$_base64')
        ..target = 'blank'
        ..download = downloadName;

  // trigger download
  document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  return;
}
