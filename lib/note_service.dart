import 'package:firenotes/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

abstract class INoteService {
  static const int PER_PAGE = 20;

  Future<List<Note>> getNotes({dynamic nextCursor});
  Future<Note> getNote(String uid);

  Future<Note> addNote(Note note);
  Future<Note> updateNote(Note note);
  Future<bool> deleteNote(Note note);
}

class FirestoreNoteService implements INoteService {
  static final _notesCollection = Firestore.instance.collection("notes");

  @override
  Future<Note> addNote(Note note) async {
    final Map<String, dynamic> data = {
      'text': note.text,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    };

    if (note.imageURL != null) {
      data['imageURL'] = note.imageURL;
    }

    final ref = await _notesCollection.add(data);

    final addedSnapshot = await ref.get();
    final addedNote = Note.mapFromSnapshot(addedSnapshot);
    return addedNote;
  }

  @override
  Future<bool> deleteNote(Note note) async {
    await _notesCollection.document(note.uid).delete();
    return true;
  }

  @override
  Future<Note> getNote(String uid) async {
    final snapshot =
        await _notesCollection.where("uid", isEqualTo: uid).getDocuments();

    final doc = snapshot.documents.first;
    if (doc != null) {
      return Note.mapFromSnapshot(doc);
    } else {
      return null;
    }
  }

  @override
  Future<List<Note>> getNotes({dynamic nextCursor}) async {
    var query = _notesCollection.orderBy('updatedAt', descending: true);
    if (nextCursor != null) {
      query = query.startAfter([nextCursor]);
    }

    query = query.limit(INoteService.PER_PAGE);

    final snapshot = await query.getDocuments();
    final notes =
        snapshot.documents.map((doc) => Note.mapFromSnapshot(doc)).toList();
    return notes;
  }

  @override
  Future<Note> updateNote(Note note) async {
    final ref = _notesCollection.document(note.uid);

    final Map<String, dynamic> data = {
      'text': note.text,
      'updatedAt': FieldValue.serverTimestamp()
    };

    if (note.imageURL != null) {
      data['imageURL'] = note.imageURL;
    }

    await ref.updateData(data);

    final updatedSnapshot = await ref.get();
    final updatedNote = Note.mapFromSnapshot(updatedSnapshot);
    return updatedNote;
  }
}
