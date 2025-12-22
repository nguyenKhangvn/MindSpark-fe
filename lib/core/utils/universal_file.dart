/// Conditional import for File class
/// Uses dart:io on mobile, stub on web
export 'file_stub.dart' if (dart.library.io) 'file_mobile.dart';
