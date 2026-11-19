import 'package:flutter/services.dart';

/// Puts text on the system clipboard. Features depend on this, not on
/// `Clipboard`, so tests can record what was copied.
abstract interface class ClipboardWriter {
  Future<void> copy(String text);
}

class SystemClipboardWriter implements ClipboardWriter {
  const SystemClipboardWriter();

  @override
  Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}
