import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/deck_model.dart';

import '../providers/editor_provider.dart';
import '../../../core/l10n/app_localizations.dart';

class ImportPage extends StatefulWidget {
  final Deck deck;
  const ImportPage({super.key, required this.deck});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final _textController = TextEditingController();
  final _customSepController = TextEditingController();

  String _selectedSeparator = 'tab'; // tab, comma, semicolon, custom
  List<Map<String, String>> _parsedCards = [];
  bool _hasParsed = false;

  void _parseContent() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).noContent)),
      );
      return;
    }

    String separator;
    switch (_selectedSeparator) {
      case 'tab':
        separator = '\t';
        break;
      case 'comma':
        separator = ',';
        break;
      case 'semicolon':
        separator = ';';
        break;
      case 'custom':
        separator = _customSepController.text;
        break;
      default:
        separator = '\t';
    }

    if (separator.isEmpty) separator = '\t';

    final lines = text.split('\n');
    final List<Map<String, String>> results = [];

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(separator);
      String term = parts.isNotEmpty ? parts[0].trim() : '';
      String def = parts.length > 1
          ? parts.sublist(1).join(separator).trim()
          : '';

      if (term.isNotEmpty || def.isNotEmpty) {
        results.add({'term': term, 'definition': def});
      }
    }

    setState(() {
      _parsedCards = results;
      _hasParsed = true;
    });
  }

  void _importCards() {
    if (_parsedCards.isEmpty) return;

    final provider = context.read<EditorProvider>();
    int count = 0;
    for (var card in _parsedCards) {
      provider.addCard(card['term'] ?? '', card['definition'] ?? '');
      count++;
    }

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.importSuccess.replaceAll('{count}', count.toString()),
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importCards),
        actions: [
          if (_hasParsed && _parsedCards.isNotEmpty)
            TextButton.icon(
              onPressed: _importCards,
              icon: const Icon(Icons.check),
              label: Text(l10n.save),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Settings Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text("${l10n.separator}: "),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedSeparator,
                  items: [
                    DropdownMenuItem(value: 'tab', child: Text("Tab (Excel)")),
                    DropdownMenuItem(value: 'comma', child: Text(l10n.comma)),
                    DropdownMenuItem(
                      value: 'semicolon',
                      child: Text(l10n.semicolon),
                    ),
                    DropdownMenuItem(value: 'custom', child: Text(l10n.custom)),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedSeparator = val!;
                      _hasParsed = false;
                    });
                  },
                ),
                if (_selectedSeparator == 'custom') ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _customSepController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _parseContent,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.preview),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Content
          Expanded(
            child: Row(
              children: [
                // Input Area
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pasteContent,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: l10n.termDefinitionExample,
                            ),
                            onChanged: (_) {
                              if (_hasParsed)
                                setState(() => _hasParsed = false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Vertical Divider
                const VerticalDivider(width: 1),
                // Preview Area
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "${l10n.preview} (${_parsedCards.length})",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: _hasParsed
                              ? ListView.separated(
                                  itemCount: _parsedCards.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final card = _parsedCards[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        card['term'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(card['definition'] ?? ''),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    l10n.preview,
                                    style: TextStyle(
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
