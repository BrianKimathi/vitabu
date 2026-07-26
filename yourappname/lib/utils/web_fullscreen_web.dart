// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> setWebFullscreen(bool fullscreen) async {
  try {
    if (fullscreen) {
      // Keep this synchronous to preserve browser "user gesture" context.
      html.document.documentElement?.requestFullscreen();
    } else {
      html.document.exitFullscreen();
    }
  } catch (_) {
    // Some browsers block fullscreen unless triggered by a user gesture.
  }
}

