import 'package:flutter/material.dart';

/// A small helper to show a themed tooltip attached to any widget key.
Future<void> showThemedTooltip({
  required BuildContext context,
  required GlobalKey targetKey,
  required String message,
  Duration duration = const Duration(seconds: 2),
}) async {
  final renderObject = targetKey.currentContext?.findRenderObject();
  if (renderObject is! RenderBox) return;
  final target = renderObject.localToGlobal(renderObject.size.center(Offset.zero));

  final entry = OverlayEntry(
    builder: (_) => Positioned(
      top: target.dy - 40,
      left: target.dx - 80,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 160,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).tooltipTheme.decoration is BoxDecoration
                ? (Theme.of(context).tooltipTheme.decoration as BoxDecoration).color
                : const Color(0xFF2E2A24),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).tooltipTheme.textStyle ?? const TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(entry);
  await Future.delayed(duration);
  entry.remove();
}
