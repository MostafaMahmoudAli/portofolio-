import 'download_file_stub.dart'
    if (dart.library.js_interop) 'download_file_web.dart'
    as platform;

const resumeFileName = 'Mostafa-Mahmoud-Resume.pdf';

void downloadFile(String path, String fileName) =>
    platform.downloadFile(path, fileName);
