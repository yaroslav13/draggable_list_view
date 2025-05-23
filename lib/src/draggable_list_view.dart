import 'package:draggable_list_view/src/child_size_reporter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that displays a list of items that can be dragged
/// from top of the screen.
final class DraggableListView extends StatefulWidget {
  const DraggableListView({
    required this.itemCount,
    required this.itemBuilder,
    this.fullPeekCount = 2,
    this.previewFraction = 0.5,
    this.controller,
    this.padding,
    this.itemExtent,
    this.itemExtentBuilder,
    this.cacheExtent,
    this.findChildIndexCallback,
    this.semanticChildCount,
    this.dragStartBehavior,
    this.keyboardDismissBehavior,
    this.restorationId,
    this.clipBehavior,
    this.hitTestBehavior,
    super.key,
  });

  /// The number of items in the list.
  final int itemCount;

  /// The controller that allows expanding and collapsing the list.
  final DraggableListController? controller;

  /// The builder to create the items in the list.
  final IndexedWidgetBuilder itemBuilder;

  /// The number of items that should be fully visible
  /// when the list is collapsed.
  final int fullPeekCount;

  /// The fraction of the previous item that should be visible.
  final double previewFraction;

  /// The padding around the list.
  final EdgeInsetsGeometry? padding;

  /// The item extent in pixels.
  final double? itemExtent;

  /// The builder to create the item extent.
  final ItemExtentBuilder? itemExtentBuilder;

  /// The extent to which the cache is used.
  final double? cacheExtent;

  /// A callback to find the index of a child in the list.
  final ChildIndexGetter? findChildIndexCallback;

  /// The number of semantic children in the list.
  final int? semanticChildCount;

  /// The behavior of the drag start.
  final DragStartBehavior? dragStartBehavior;

  /// The behavior of the keyboard when the list is dismissed.
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  /// The restoration ID for the list.
  final String? restorationId;

  /// The clip behavior for the list.
  final Clip? clipBehavior;

  /// The hit test behavior for the list.
  final HitTestBehavior? hitTestBehavior;

  @override
  State<DraggableListView> createState() => _DraggableListViewState();
}

final class _DraggableListViewState extends State<DraggableListView> {
  late List<double> _itemHeights;
  double _dragOffset = 0;
  bool _hasReachedEnd = false;

  double get _totalHeight => _itemHeights.fold<double>(0, (sum, h) => sum + h);

  double get _peekHeight => _calculatePeekHeight();

  double get _maxDrag => (_totalHeight - _peekHeight).clamp(
        0.0,
        double.infinity,
      );

  void _collapse() {
    setState(() {
      _dragOffset = 0.0;
    });
  }

  void _expand() {
    setState(() {
      _dragOffset = _maxDrag;
      _notifyEndReached();
    });
  }

  void _notifyEndReached() {
    if (!_hasReachedEnd) {
      _hasReachedEnd = true;
      widget.controller?._onEndReached();
    }
  }

  @override
  void initState() {
    super.initState();
    _itemHeights = List<double>.filled(widget.itemCount, 0);

    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(covariant DraggableListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount ||
        oldWidget.fullPeekCount != widget.fullPeekCount ||
        oldWidget.previewFraction != widget.previewFraction) {
      final oldHeights = _itemHeights;

      _itemHeights = List<double>.filled(widget.itemCount, 0);

      for (var i = 0; i < oldHeights.length && i < _itemHeights.length; i++) {
        _itemHeights[i] = oldHeights[i];
      }
      final total = _itemHeights.fold<double>(0, (sum, h) => sum + h);
      final peek = _calculatePeekHeight();

      _dragOffset =
          _dragOffset.clamp(0.0, (total - peek).clamp(0.0, double.infinity));

      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) {
      widget.controller?._detach();
    }
    super.dispose();
  }

  double _calculatePeekHeight() {
    final n = _itemHeights.length;
    if (n == 0) {
      return 0;
    }
    // sum fully peeked items
    var peek = 0.0;
    final full = widget.fullPeekCount;
    for (var i = n - full; i < n; i++) {
      if (i >= 0 && i < n) peek += _itemHeights[i];
    }
    // optionally preview fraction of the previous item
    final prevIndex = n - full - 1;
    if (widget.previewFraction > 0 && prevIndex >= 0 && prevIndex < n) {
      peek += _itemHeights[prevIndex] * widget.previewFraction;
    }
    return peek;
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.itemCount;
    final totalHeight = _itemHeights.fold<double>(0, (sum, h) => sum + h);
    final peekHeight = _calculatePeekHeight();
    final maxDrag = (totalHeight - peekHeight).clamp(0.0, double.infinity);
    final offset = _dragOffset.clamp(0.0, maxDrag);
    final top = peekHeight - totalHeight + offset;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            setState(() {
              _dragOffset += details.delta.dy;
              _notifyEndReached();
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: top,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height:
                      totalHeight == 0.0 ? constraints.maxHeight : totalHeight,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: n,
                    padding: widget.padding,
                    itemExtent: widget.itemExtent,
                    itemExtentBuilder: widget.itemExtentBuilder,
                    cacheExtent: widget.cacheExtent,
                    findChildIndexCallback: widget.findChildIndexCallback,
                    semanticChildCount: widget.semanticChildCount,
                    dragStartBehavior:
                        widget.dragStartBehavior ?? DragStartBehavior.start,
                    keyboardDismissBehavior: widget.keyboardDismissBehavior ??
                        ScrollViewKeyboardDismissBehavior.manual,
                    restorationId: widget.restorationId,
                    clipBehavior: widget.clipBehavior ?? Clip.hardEdge,
                    hitTestBehavior:
                        widget.hitTestBehavior ?? HitTestBehavior.opaque,
                    itemBuilder: (context, index) {
                      return ChildSizeReporter(
                        onChange: (size) {
                          if (_itemHeights[index] != size.height) {
                            setState(() => _itemHeights[index] = size.height);
                          }
                        },
                        child: widget.itemBuilder(context, index),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class DraggableListController {
  static final List<VoidCallback?> _emptyListeners =
      List<VoidCallback?>.filled(0, null);
  List<VoidCallback?> _listeners = _emptyListeners;
  int _count = 0;

  _DraggableListViewState? _state;

  // Toggle the expansion state of the list.
  bool get isExpanded => _state?._dragOffset == _state?._maxDrag;

  void _detach() {
    _state = null;

    _listeners = _emptyListeners;
    _count = 0;
  }

  // Collapse the list to show only the peeked items.
  void collapse() {
    _state?._collapse();
  }

  // Expand the list to show all items.
  void expand() {
    _state?._expand();
  }

  // Add a listener that will be called when the end of the list is reached.
  void addListener(VoidCallback listener) {
    if (_count == _listeners.length) {
      if (_count == 0) {
        _listeners = List<VoidCallback?>.filled(1, null);
      } else {
        final newListeners =
            List<VoidCallback?>.filled(_listeners.length * 2, null);
        for (var i = 0; i < _count; i++) {
          newListeners[i] = _listeners[i];
        }
        _listeners = newListeners;
      }
    }
    _listeners[_count++] = listener;
  }

  // Remove a listener that was previously added.
  void removeListener(VoidCallback listener) {
    for (var i = 0; i < _count; i++) {
      final listenerAtIndex = _listeners[i];
      if (listenerAtIndex == listener) {
        _removeAt(i);
        break;
      }
    }
  }

  // Notify all listeners that the end of the list has been reached.
  void _onEndReached() {
    for (var i = 0; i < _count; i++) {
      final listener = _listeners[i];
      if (listener != null) {
        listener();
      }
    }
  }

  void _removeAt(int index) {
    _count -= 1;
    if (_count * 2 <= _listeners.length) {
      final newListeners = List<VoidCallback?>.filled(_count, null);

      for (var i = 0; i < index; i++) {
        newListeners[i] = _listeners[i];
      }

      for (var i = index; i < _count; i++) {
        newListeners[i] = _listeners[i + 1];
      }

      _listeners = newListeners;
    } else {
      for (var i = index; i < _count; i++) {
        _listeners[i] = _listeners[i + 1];
      }
      _listeners[_count] = null;
    }
  }
}
