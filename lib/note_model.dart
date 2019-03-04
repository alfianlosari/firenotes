import 'package:scoped_model/scoped_model.dart';
import 'note_service.dart';
import 'note.dart';

class NoteModel extends Model {
  final INoteService _service = FirestoreNoteService();

  List<Note> notes = [];
  bool isLoading = false;
  bool isSubmittingNote = false;
  bool noteHasSubmitted = false;

  dynamic nextCursor;

  bool get isEmpty => notes.isEmpty;

  void getNotes() async {
    if (isLoading) {
      return;
    }

    isLoading = true;

    if (this.nextCursor == null) {
      notifyListeners();
    }

    final notes = await _service.getNotes(nextCursor: nextCursor);
    if (notes.length >= INoteService.PER_PAGE) {
      this.nextCursor = notes.last.updatedAt;
    } else {
      this.nextCursor = null;
    }

    this.notes.addAll(notes);
    this.isLoading = false;
    notifyListeners();
  }

  void deleteNote(Note note, Function() success) async {
    if (this.isSubmittingNote) {
      return;
    }

    this.noteHasSubmitted = false;
    this.isSubmittingNote = true;
    notifyListeners();
    await _service.deleteNote(note);
    this.noteHasSubmitted = true;
    this.isSubmittingNote = false;
    notifyListeners();
    success();
  }

  void editNote(Note note, Function(Note note) success) async {
    if (this.isSubmittingNote) {
      return;
    }

    this.noteHasSubmitted = false;
    this.isSubmittingNote = true;
    notifyListeners();
    final updatedNote = await _service.updateNote(note);
    this.noteHasSubmitted = true;
    this.isSubmittingNote = false;
    notifyListeners();
    success(updatedNote);
  }

  addNote(Note note, Function(Note note) success) async {
    if (this.isSubmittingNote) {
      return;
    }

    this.noteHasSubmitted = false;
    this.isSubmittingNote = true;
    notifyListeners();
    final createdNote = await _service.addNote(note);
    this.noteHasSubmitted = true;
    this.isSubmittingNote = false;
    notifyListeners();
    success(createdNote);
  }

  void clearNotes() {
    notes = [];
    nextCursor = null;
    notifyListeners();
  }
}
