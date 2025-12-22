/// Stub for dart:io File class on web platform
/// This file is used when kIsWeb = true
class File {
  final String path;
  final List<int>? _bytes;

  File(this.path) : _bytes = null;

  File.fromRawPath(this.path, this._bytes);

  Future<List<int>> readAsBytes() async {
    if (_bytes != null) {
      return _bytes!;
    }
    throw UnsupportedError('Cannot read file on web without bytes');
  }

  static File fromBytes(String path, List<int> bytes) {
    return File.fromRawPath(path, bytes);
  }
}
