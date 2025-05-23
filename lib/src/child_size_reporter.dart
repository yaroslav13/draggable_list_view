import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that reports the size of its child.
final class ChildSizeReporter extends SingleChildRenderObjectWidget {
  const ChildSizeReporter({
    required this.onChange,
    required Widget super.child,
    super.key,
  });

  /// Callback that is called when the size of the child changes.
  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ChildSizeReporterRenderProxyBox().._onChange = onChange;

  @override
  void updateRenderObject(
    BuildContext context,
    RenderObject renderObject,
  ) {
    if (renderObject is _ChildSizeReporterRenderProxyBox) {
      renderObject._onChange = onChange;
    }
  }
}

final class _ChildSizeReporterRenderProxyBox extends RenderProxyBox {
  ValueChanged<Size>? _onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size ?? Size.zero;

    if (_oldSize == null || _oldSize != newSize) {
      _oldSize = newSize;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onChange?.call(newSize);
      });
    }
  }
}
