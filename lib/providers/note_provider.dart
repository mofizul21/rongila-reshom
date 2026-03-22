import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class NoteProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NoteProvider() {
    _initNotesStream();
  }

  void _initNotesStream() {
    _databaseService.notesStream.listen((notes) {
      _notes = notes;
      notifyListeners();
    });
  }

  Future<void> addNote({
    required String title,
    required String content,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final note = Note(
        id: const Uuid().v4(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.addNote(note);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final note = getNoteById(id);
      if (note == null) return;

      final updatedNote = note.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateNote(updatedNote);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _databaseService.deleteNote(noteId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<Note>> searchNotes(String query) async {
    try {
      return await _databaseService.searchNotes(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
