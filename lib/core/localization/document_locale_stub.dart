/// VM counterpart of the browser document attributes, also observable in tests.
String documentLanguage = 'en';
String documentDirection = 'ltr';

void setDocumentLocale(String language, String direction) {
  documentLanguage = language;
  documentDirection = direction;
}
