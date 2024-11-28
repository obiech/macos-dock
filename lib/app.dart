import 'package:flutter/material.dart';
import 'package:macos_dock/draggable.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: Dock(
              items: const [
                {'icon': Icons.person, 'label': 'Person'},
                {'icon': Icons.message, 'label': 'Message'},
                {'icon': Icons.call, 'label': 'Call'},
                {'icon': Icons.camera, 'label': 'Camera'},
                {'icon': Icons.photo, 'label': 'Photo'},
              ],
              builder: (icon, label) {
                return Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors
                        .primaries[icon.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(icon, color: Colors.white)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<Map<String, dynamic>> items;
  final Widget Function(IconData, String) builder;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<Map<String, dynamic>> _items;
  int? _activeIndex; // Tracks hovered or tapped index.

  final GlobalKey _dockKey = GlobalKey();
  bool showLabel = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _dockKey,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomReorderableListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) newIndex -= 1;
            final item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        },
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          final isActive = _activeIndex == index;
          final showLabel = _activeIndex == index;

          final scale = isActive ? 1.2 : 1.0;

          return GestureDetector(
            key: ValueKey(item),
            // behavior: HitTestBehavior.translucent,
            // onLongPressCancel: () => setState(() => _activeIndex = null),
            // onLongPressDown: (_) => setState(() => _activeIndex = index),
            // onPanStart: (_) => setState(() => _activeIndex = index),
            // onPanEnd: (_) => setState(() => _activeIndex = null),
            child: MouseRegion(
              onEnter: (_) => setState(() => _activeIndex = index),
              onExit: (_) => setState(() => _activeIndex = 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // if (showLabel)
                  SizedBox(
                    height: 20,
                    child: showLabel
                        ? Text(
                            item['label'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 200),
                    tween: Tween<double>(begin: 1.0, end: scale),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: widget.builder(
                          item['icon'] as IconData,
                          item['label'] as String,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
