import 'dart:io' as io;

/// Lightweight wrapper to unify File API across mobile/web
/// Supports optional in-memory bytes for symmetry with web stub.
class File {
	final String path;
	final List<int>? _bytes;

	File(this.path) : _bytes = null;

	File.fromBytes(this.path, List<int> bytes) : _bytes = bytes;

	Future<List<int>> readAsBytes() async {
		if (_bytes != null) return _bytes!;
		return io.File(path).readAsBytes();
	}
}
