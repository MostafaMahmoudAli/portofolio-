/// VM counterpart of browser downloads, observable in widget tests.
final downloadCalls = <({String path, String fileName})>[];

void downloadFile(String path, String fileName) {
  downloadCalls.add((path: path, fileName: fileName));
}
