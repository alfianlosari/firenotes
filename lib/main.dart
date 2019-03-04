import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firenotes/widgets/note_list_widget.dart';

void main() {
  final db = Firestore.instance;
  db.settings(timestampsInSnapshotsEnabled: true, persistenceEnabled: false);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final noteModel = NoteModel();
    return ScopedModel(
        model: noteModel,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Firenotes',
          theme: ThemeData(
            primaryColor: Color.fromRGBO(155, 68, 152, 1.0),
          ),
          home: NoteListWidget(title: 'Firenotes'),
        ));
  }
}
