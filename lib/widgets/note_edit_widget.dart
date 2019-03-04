import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firenotes/note_model.dart';
import 'package:firenotes/note.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'upload_task_list_tile_widget.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:io';

class NoteEditWidget extends StatefulWidget {
  final Note _note;

  NoteEditWidget(this._note);

  @override
  _NoteEditWidgetState createState() => _NoteEditWidgetState();
}

class _NoteEditWidgetState extends State<NoteEditWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final FirebaseStorage storage = FirebaseStorage.instance;

  StorageUploadTask _task;
  File _image;

  bool get isEditing => widget._note != null;
  NoteModel get _noteModel => ScopedModel.of<NoteModel>(context);

  uploadFile(File file, Note note) {
    final String uuid = note.uid;

    final StorageReference ref =
        storage.ref().child('images').child("$uuid.jpg");
    final StorageUploadTask task = ref.putFile(
      file,
      StorageMetadata(
        contentType: 'image/jpeg',
      ),
    );

    setState(() {
      _task = task;
    });

    task.onComplete.then((value) {
      value.ref.getDownloadURL().then((v) {
        note.imageURL = v;
        _noteModel.editNote(note, (_) {
          Navigator.pop(context);
        });

        setState(() {
          _task = null;
        });
      }, onError: (e) {
        setState(() {
          _task = null;
        });
      });
    }, onError: (error) {
      setState(() {
        _task = null;
      });

      showInSnackBar('Upload Fails');
    });

    showInSnackBar('Uploading Image...');
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 512, maxWidth: 512);
    setState(() {
      _image = image;
    });
  }

  void addNote(String text) async {
    _noteModel.addNote(Note(text: text), (note) {
      if (_image != null) {
        uploadFile(_image, note);
      } else {
        Navigator.pop(context);
      }
    });
    showInSnackBar('Adding Note...');
  }

  void updateNote(Note note, String text) async {
    widget._note.text = text;
    _noteModel.editNote(widget._note, (updatedNote) {
      if (_image != null) {
        uploadFile(_image, updatedNote);
      } else {
        Navigator.pop(context);
      }
    });
    showInSnackBar('Updating Note');
  }

  void deleteNote(Note note) {
    final noteModel = ScopedModel.of<NoteModel>(context);
    noteModel.deleteNote(widget._note, () => Navigator.pop(context));
    showInSnackBar('Deleting Note...');
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  void initState() {
    _textController.text = isEditing ? widget._note.text : '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _formChildren = List<Widget>();
    if (_image != null) {
      _formChildren.add(Center(
        child: Image.file(_image),
      ));
    } else if (isEditing && widget._note.imageURL != null) {
      _formChildren.add(Center(
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: widget._note.imageURL,
        ),
      ));
    }

    _formChildren.add(TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: _textController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
      },
    ));

    _formChildren.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ScopedModelDescendant<NoteModel>(
          builder: (context, child, note) {
            return RaisedButton(
              onPressed: note.isSubmittingNote || _task != null
                  ? null
                  : () {
                      if (_formKey.currentState.validate()) {
                        final text = _textController.text;
                        if (isEditing) {
                          updateNote(widget._note, text);
                        } else {
                          addNote(text);
                        }
                      }
                    },
              child: Text('Submit'),
            );
          },
        )));

    if (this._task != null && !this._task.isComplete) {
      _formChildren.add(UploadTaskListTile(
        task: _task,
        onDismissed: () => setState(() => _task = null),
        onDownload: () {},
      ));
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Note' : 'Add Note'),
          actions: !isEditing
              ? null
              : <Widget>[
                  IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteNote(widget._note)),
                ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:
              _task != null || _noteModel.isSubmittingNote ? null : getImage,
          tooltip: 'Pick Image',
          child: Icon(Icons.add_a_photo),
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: _formChildren,
              ),
            )));
  }
}
