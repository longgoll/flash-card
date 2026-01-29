import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/folder_model.dart';
import '../../../data/models/deck_model.dart';
import '../../../data/repositories/folder_repository.dart';
import '../providers/deck_provider.dart';

import '../../editor/pages/editor_page.dart';
import '../../editor/providers/editor_provider.dart';

import '../../../core/l10n/app_localizations.dart';

class FolderDetailPage extends StatefulWidget {
  final Folder folder;
  const FolderDetailPage({super.key, required this.folder});

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  final FolderRepository _repo = FolderRepository();
  List<Deck> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    setState(() => _isLoading = true);
    final decks = await _repo.getDecksInFolder(widget.folder.id!);
    if (mounted) {
      setState(() {
        _decks = decks;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddDecksDialog() async {
    final allDecks = context.read<DeckProvider>().decks;
    final l10n = AppLocalizations.of(context);

    // Filter out decks already in folder
    final existingIds = _decks.map((d) => d.id).toSet();
    final availableDecks = allDecks
        .where((d) => !existingIds.contains(d.id))
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addDeckToFolder),

        content: SizedBox(
          width: double.maxFinite,
          child: availableDecks.isEmpty
              ? Text(l10n.noDecks)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableDecks.length,
                  itemBuilder: (context, index) {
                    final deck = availableDecks[index];
                    return ListTile(
                      title: Text(deck.name),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          await _repo.addDeckToFolder(
                            widget.folder.id!,
                            deck.id!,
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            _loadDecks();
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // If folder was deleted from list page, this might be invalid, but we handle that in logic
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: implement edit folder
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDecksDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _decks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(l10n.noDecks),
                  TextButton(
                    onPressed: _showAddDecksDialog,
                    child: Text(l10n.addDeck),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _decks.length,
              itemBuilder: (context, index) {
                final deck = _decks[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.style, color: Colors.blue),
                    title: Text(deck.name),
                    subtitle: Text('${deck.cardCount} ${l10n.cards}'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        await _repo.removeDeckFromFolder(
                          widget.folder.id!,
                          deck.id!,
                        );
                        _loadDecks();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => EditorProvider(),
                            child: EditorPage(deck: deck),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
