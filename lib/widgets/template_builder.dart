import 'package:flutter/material.dart';

class TemplateBuilder extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;

  const TemplateBuilder({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<TemplateBuilder> createState() => _TemplateBuilderState();
}

class _TemplateBuilderState extends State<TemplateBuilder> {
  late TextEditingController _nameController;
  late TextEditingController _configController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _parseInitialValue();
  }

  void _parseInitialValue() {
    final value = widget.initialValue;
    // Format: [Name] #[Group] !template { [Definition] }
    final bracketIndex = value.indexOf('{');
    final closeBracketIndex = value.lastIndexOf('}');

    if (bracketIndex != -1 &&
        closeBracketIndex != -1 &&
        closeBracketIndex > bracketIndex) {
      final namePart = value.substring(0, bracketIndex).trim();
      final configPart = value
          .substring(bracketIndex + 1, closeBracketIndex)
          .trim();
      _nameController = TextEditingController(text: namePart);
      _configController = TextEditingController(text: configPart);
    } else {
      _nameController = TextEditingController(text: value);
      _configController = TextEditingController();
    }

    _nameController.addListener(_notifyChanged);
    _configController.addListener(_notifyChanged);
  }

  void _notifyChanged() {
    final name = _nameController.text.trim();
    final config = _configController.text.trim();
    final fullValue = '$name { $config }';

    setState(() {
      _error = _validateConfig(config);
    });

    widget.onChanged(fullValue);
  }

  String? _validateConfig(String config) {
    if (config.isEmpty) return null;
    // Simple validation for keys
    final validKeys = [
      'layout',
      'fields',
      'suggest',
      'primaryRow',
      'secondaryRow',
    ];
    final regExp = RegExp(r'([a-zA-Z]+)\s*:');
    final matches = regExp.allMatches(config);

    for (final match in matches) {
      final key = match.group(1);
      if (key != null && !validKeys.contains(key)) {
        return 'Unknown key: "$key"';
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _configController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText:
                'View Name & Trigger (e.g. Grocery List #groceries !template)',
            hintText: 'My View #tag !template',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _configController,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Definition { ... }',
            hintText: "layout: 'row', fields: ['title', 'qty:right']",
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Live Preview (Dummy Record):',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        _buildPreview(),
      ],
    );
  }

  Widget _buildPreview() {
    // Dummy render based on config
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_box_outline_blank,
            size: 20,
            color: Colors.white54,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Item Title', style: TextStyle(color: Colors.white)),
          ),
          if (_configController.text.contains('qty'))
            const Text(
              '5kg',
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
