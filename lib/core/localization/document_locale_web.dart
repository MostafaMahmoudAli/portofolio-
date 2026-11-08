import 'package:web/web.dart' as web;

void setDocumentLocale(String language, String direction) {
  web.document.documentElement!
    ..setAttribute('lang', language)
    ..setAttribute('dir', direction);
}
