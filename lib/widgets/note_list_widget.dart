import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'note_widget.dart';
import 'package:firenotes/note_model.dart';
import 'note_edit_widget.dart';
import 'package:firenotes/note.dart';

class NoteListWidget extends StatefulWidget {
  NoteListWidget({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteListWidget> {
  NoteModel get _noteModel => ScopedModel.of<NoteModel>(context);

  void refreshNotes() {
    _noteModel.clearNotes();
    _noteModel.getNotes();
  }

  void addNote() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NoteEditWidget(null)));
  }

  void editNote(Note note) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteEditWidget(Note.clone(note))));
  }

  @override
  Widget build(BuildContext context) {
    refreshNotes();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.refresh), onPressed: () => refreshNotes()),
            IconButton(icon: Icon(Icons.add), onPressed: () => addNote())
          ],
        ),
        body: Center(child:
            ScopedModelDescendant<NoteModel>(builder: (context, child, note) {
          return note.isLoading && note.isEmpty
              ? CircularProgressIndicator(value: null)
              : ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: note.notes.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    final noteWidget = NoteWidget(
                        note.notes[index], () => editNote(note.notes[index]));
                    if (index == note.notes.length - 1 &&
                        note.nextCursor != null &&
                        !note.isLoading) {
                      note.getNotes();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          noteWidget,
                          Center(
                            child: CircularProgressIndicator(
                              value: null,
                            ),
                          )
                        ],
                      );
                    }
                    return noteWidget;
                  },
                );
        })));
  }
}
