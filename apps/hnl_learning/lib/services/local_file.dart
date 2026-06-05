// Default (web) implementation: there's no local file system on the web, so
// nothing exists here. Web recordings are blob URLs and never take this path.
// The dart:io version (local_file_io.dart) is swapped in via conditional import
// on mobile/desktop.
bool localFileExists(String path) => false;
