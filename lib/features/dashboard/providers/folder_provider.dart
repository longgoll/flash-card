import 'package:flutter/material.dart';
import '../../../data/models/folder_model.dart';
import '../../../data/repositories/folder_repository.dart';

class FolderProvider extends ChangeNotifier {
  final FolderRepository _repository = FolderRepository();

  List<Folder> _folders = [];
  bool _isLoading = false;

  List<Folder> get folders => _folders;
  bool get isLoading => _isLoading;

  Future<void> loadFolders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _folders = await _repository.getAllFolders();
    } catch (e) {
      debugPrint("Error loading folders: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createFolder(String name, String description) async {
    final newFolder = Folder(
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    await _repository.createFolder(newFolder);
    await loadFolders();
  }

  Future<void> deleteFolder(int id) async {
    await _repository.deleteFolder(id);
    await loadFolders();
  }

  Future<void> updateFolder(Folder folder) async {
    await _repository.updateFolder(folder);
    await loadFolders();
  }
}
