// Default (web) implementation: there's no local file system on the web, so
// nothing exists here. Web recordings are blob URLs and never take this path.
// The dart:io version (local_file_io.dart) is swapped in via conditional import
// on mobile/desktop.
bool localFileExists(String path) => false;

// Web has no file system to copy into — uploads are stored as data URLs in the
// service instead, so this is never called. Present only to satisfy the
// conditional-import contract.
Future<void> copyLocalFile(String src, String dest) async {}
