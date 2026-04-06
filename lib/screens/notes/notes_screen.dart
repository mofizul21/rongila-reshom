import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/long_press_refresh_wrapper.dart';
import 'note_form_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Note> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredNotes(context.read<NoteProvider>().notes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredNotes(List<Note> notes) {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredNotes = notes;
      });
    }
  }

  void _searchNotes(String query) {
    final noteProvider = context.read<NoteProvider>();
    if (query.isEmpty) {
      setState(() {
        _filteredNotes = noteProvider.notes;
      });
    } else {
      noteProvider.searchNotes(query).then((results) {
        if (mounted) {
          setState(() {
            _filteredNotes = results;
          });
        }
      });
    }
  }

  void _showNoteForm({Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteFormScreen(note: note),
      ),
    );
  }

  void _confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: note.title,
        message: 'Are you sure you want to delete this note?',
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<NoteProvider>().deleteNote(note.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteForm(),
        heroTag: 'notes_fab',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchNotes('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchNotes,
            ),
          ),
          Expanded(
            child: Consumer<NoteProvider>(
              builder: (context, noteProvider, child) {
                final notesToShow = _searchController.text.isEmpty
                    ? noteProvider.notes
                    : _filteredNotes;

                if (noteProvider.isLoading && notesToShow.isEmpty) {
                  return const LoadingWidget(message: 'Loading notes...');
                }

                if (notesToShow.isEmpty) {
                  return const EmptyWidget(
                    message: 'No notes found.\nTap + to add a new note.',
                    icon: Icons.note_outlined,
                  );
                }

                return LongPressRefreshWrapper(
                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 300));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: notesToShow.length,
                    itemBuilder: (context, index) {
                    final note = notesToShow[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          note.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Updated: ${note.updatedAt.toString().split('.')[0]}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showNoteForm(note: note),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(note),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              );
              },
            ),
          ),
        ],
      ),
    );
  }
}
