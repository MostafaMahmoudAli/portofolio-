import 'package:web/web.dart' as web;

void downloadFile(String path, String fileName) {
  final anchor = web.HTMLAnchorElement()
    ..href = Uri.base.resolve(path).toString()
    ..download = fileName;
  web.document.body!.appendChild(anchor);
  try {
    anchor.click();
  } finally {
    anchor.remove();
  }
}
