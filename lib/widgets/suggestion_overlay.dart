import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../utils/tool_parser.dart';

class SuggestionOverlay extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final LayerLink layerLink;
  final VoidCallback onSuggestionSelected;

  const SuggestionOverlay({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.layerLink,
    required this.onSuggestionSelected,
  });

  @override
  State<SuggestionOverlay> createState() => _SuggestionOverlayState();
}

class _SuggestionOverlayState extends State<SuggestionOverlay> {
  OverlayEntry? _overlayEntry;
  List<dynamic> _suggestions = [];
  String _activePrefix = '';
  String _activeQuery = '';
  int _activeStart = -1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _hideOverlay();
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus) {
      _hideOverlay();
    } else {
      _onTextChanged();
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (!selection.isValid || !selection.isCollapsed) {
      _hideOverlay();
      return;
    }

    final cursorPosition = selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPosition);

    // Find the last @ or # before cursor
    final lastAt = textBeforeCursor.lastIndexOf('@');
    final lastHash = textBeforeCursor.lastIndexOf('#');

    final lastTrigger = lastAt > lastHash ? lastAt : lastHash;

    if (lastTrigger != -1) {
      // Check if there's a space between trigger and cursor
      final textAfterTrigger = textBeforeCursor.substring(lastTrigger + 1);
      if (textAfterTrigger.contains(' ')) {
        _hideOverlay();
        return;
      }

      _activePrefix = textBeforeCursor[lastTrigger];
      _activeQuery = textAfterTrigger;
      _activeStart = lastTrigger;
      _updateSuggestions();
    } else {
      _hideOverlay();
    }
  }

  void _updateSuggestions() {
    final provider = Provider.of<TodoProvider>(context, listen: false);

    if (_activePrefix == '#') {
      final tags = provider.availableTags;
      final query = _activeQuery.toLowerCase();
      // Exact startsWith first
      final matches = tags
          .where((t) => t.toLowerCase().startsWith(query))
          .toList();
      // Then contains (for similar names)
      final similar = tags
          .where(
            (t) =>
                !t.toLowerCase().startsWith(query) &&
                t.toLowerCase().contains(query),
          )
          .toList();
      _suggestions = [...matches, ...similar];
    } else if (_activePrefix == '@') {
      // Combine dates and people
      final dateSuggestions = ToolParser.getDateSuggestions(_activeQuery);
      final people = provider.availablePeople;
      final query = _activeQuery.toLowerCase();

      final filteredPeople = people
          .where((p) {
            final title = p.title.toLowerCase();
            // Check title (name), and tags
            return title.contains(query) ||
                p.tags.any((t) => t.toLowerCase().contains(query));
          })
          .map((p) => p.title)
          .toSet()
          .toList(); // toSet to avoid duplicates if multiple todos have same person tag

      _suggestions = [...dateSuggestions, ...filteredPeople];
    }

    if (_suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: widget.layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // Adjust based on text field height
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(suggestion.toString()),
                    leading: _activePrefix == '#'
                        ? const Icon(Icons.label_outline, size: 20)
                        : (ToolParser.getDateSuggestions(
                                '',
                              ).contains(suggestion)
                              ? const Icon(Icons.calendar_today, size: 20)
                              : const Icon(Icons.person_outline, size: 20)),
                    onTap: () => _selectSuggestion(suggestion.toString()),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectSuggestion(String suggestion) {
    final text = widget.controller.text;
    final newText = text.replaceRange(
      _activeStart + 1,
      _activeStart + 1 + _activeQuery.length,
      suggestion,
    );

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: _activeStart + 1 + suggestion.length,
      ),
    );

    _hideOverlay();
    widget.onSuggestionSelected();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // This widget just manages the overlay
  }
}
