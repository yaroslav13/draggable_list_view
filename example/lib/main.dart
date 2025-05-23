import 'dart:async';

import 'package:draggable_list_view/draggable_list_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const _MyApp());
}

final class _MyApp extends StatelessWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Demo',
      home: _MyHomePage(title: 'Demo'),
    );
  }
}

final class _MyHomePage extends StatefulWidget {
  const _MyHomePage({
    required this.title,
  });

  final String title;

  @override
  State<_MyHomePage> createState() => _MyHomePageState();
}

final class _MyHomePageState extends State<_MyHomePage> {
  final List<String> _items = List.generate(100, (index) => 'Item $index');
  final _controller = DraggableListController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        setState(() {
          _items.add('Item ${_items.length}');
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: DraggableListView(
        controller: _controller,
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(title: Text(_items[index]));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.collapse,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
