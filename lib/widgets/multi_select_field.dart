import 'package:flutter/material.dart';

class MultiSelectField extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(List<String>) onChanged;
  final List<String> suggestions;
  final String? hintText;
  final int? maxItems;

  const MultiSelectField({
    Key? key,
    required this.title,
    required this.items,
    required this.onChanged,
    this.suggestions = const [],
    this.hintText,
    this.maxItems,
  }) : super(key: key);

  @override
  State<MultiSelectField> createState() => _MultiSelectFieldState();
}

class _MultiSelectFieldState extends State<MultiSelectField> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem(String item) {
    if (item.isNotEmpty && !widget.items.contains(item)) {
      if (widget.maxItems == null || widget.items.length < widget.maxItems!) {
        final newItems = [...widget.items, item];
        widget.onChanged(newItems);
        _controller.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Máximo ${widget.maxItems} elementos permitidos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _removeItem(String item) {
    final newItems = widget.items.where((i) => i != item).toList();
    widget.onChanged(newItems);
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddItemDialog(
          title: 'Agregar ${widget.title}',
          suggestions: widget.suggestions,
          existingItems: widget.items,
          onAdd: _addItem,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con título y botón expandir
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
            ),
          ],
        ),
        
        // Lista de items actuales (siempre visible si hay items)
        if (widget.items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.items.map((item) => _buildItemChip(item)).toList(),
            ),
          ),
        ],
        
        // Área expandida con opciones
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón para agregar nuevo item
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Agregar ${widget.title}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                // Sugerencias rápidas
                if (widget.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Sugerencias:',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.suggestions
                        .where((suggestion) => !widget.items.contains(suggestion))
                        .take(6)
                        .map((suggestion) => _buildSuggestionChip(suggestion))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItemChip(String item) {
    return Chip(
      label: Text(
        item,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
      onDeleted: () => _removeItem(item),
      backgroundColor: Colors.blue[700],
      deleteIconColor: Colors.white,
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(
        suggestion,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      backgroundColor: Colors.grey[700],
      onPressed: () => _addItem(suggestion),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final String title;
  final List<String> suggestions;
  final List<String> existingItems;
  final Function(String) onAdd;

  const _AddItemDialog({
    required this.title,
    required this.suggestions,
    required this.existingItems,
    required this.onAdd,
  });

  @override
  State<_AddItemDialog> createState() => __AddItemDialogState();
}

class __AddItemDialogState extends State<_AddItemDialog> {
  final TextEditingController _controller = TextEditingController();
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredSuggestions();
    _controller.addListener(_updateFilteredSuggestions);
  }

  void _updateFilteredSuggestions() {
    setState(() {
      final query = _controller.text.toLowerCase();
      _filteredSuggestions = widget.suggestions
          .where((suggestion) =>
              !widget.existingItems.contains(suggestion) &&
              suggestion.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem(String item) {
    if (item.trim().isNotEmpty) {
      widget.onAdd(item.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: Text(
        widget.title,
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Escribir nuevo elemento...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onSubmitted: _addItem,
          ),
          if (_filteredSuggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Sugerencias:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filteredSuggestions.map((suggestion) {
                    return ActionChip(
                      label: Text(
                        suggestion,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: Colors.grey[700],
                      onPressed: () => _addItem(suggestion),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => _addItem(_controller.text),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Agregar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
