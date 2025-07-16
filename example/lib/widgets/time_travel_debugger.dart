import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// یک پنل شناور و تعاملی برای دیباگ بصری تاریخچه تغییرات.
/// A floating, interactive panel for visually debugging the change history.
class TimeTravelDebugger extends StatefulWidget {
  final TimeTravelQuantumWidgetController controller;

  const TimeTravelDebugger({Key? key, required this.controller})
      : super(key: key);

  @override
  State<TimeTravelDebugger> createState() => _TimeTravelDebuggerState();
}

class _TimeTravelDebuggerState extends State<TimeTravelDebugger> {
  Offset position = const Offset(10, 10);
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E1E1E).withOpacity(0.9),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade300),
            ),
            child: StreamBuilder(
              stream: widget.controller.historyStream,
              builder: (context, snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    if (_isExpanded) Flexible(child: _buildContent()),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        width: 250, // Fixed width for the header
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(11),
            topRight: Radius.circular(11),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.history_toggle_off_rounded, size: 18),
            const SizedBox(width: 8),
            const Text('Time-Travel Debugger',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Icon(_isExpanded
                ? Icons.keyboard_arrow_down
                : Icons.keyboard_arrow_up),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final undoStack = widget.controller.commandHistory.reversed.toList();
    final redoStack = widget.controller.redoHistory.reversed.toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
                child: Text('Undo Stack (Click to travel)',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(height: 10),
            if (undoStack.isEmpty)
              const Text('  (Initial State)',
                  style: TextStyle(color: Colors.grey)),
            ...undoStack.asMap().entries.map((entry) {
              final reversedIndex = entry.key;
              // Convert reversed index back to original undo stack index
              final originalIndex =
                  widget.controller.commandHistory.length - 1 - reversedIndex;
              final cmd = entry.value;
              final isCurrentState =
                  reversedIndex == 0; // The top of the reversed stack

              return InkWell(
                onTap: () => widget.controller.travelTo(originalIndex),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  color: isCurrentState
                      ? Colors.purple.withOpacity(0.3)
                      : Colors.transparent,
                  child: Text('  ${cmd.description}',
                      style: TextStyle(
                          fontWeight: isCurrentState
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
              );
            }),
            const SizedBox(height: 12),
            const Center(
                child: Text('Redo Stack',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(height: 10),
            if (redoStack.isEmpty)
              const Text('  (empty)', style: TextStyle(color: Colors.grey)),
            ...redoStack.map((cmd) => Text('  - ${cmd.description}',
                style: const TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}
