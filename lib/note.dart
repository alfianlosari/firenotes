import 'package:cloud_firestore/cloud_firestore.dart';

class Note extends Object {
  String uid;
  String text;
  String imageURL;
  DateTime createdAt;
  DateTime updatedAt;

  String get description => "$uid-$text-$createdAt";
  Note({String uid, String text, String imageURL}) {
    this.uid = uid;
    this.text = text;
    this.imageURL = imageURL;
  }

  Note.clone(Note note)
      : this(uid: note.uid, text: note.text, imageURL: note.imageURL);

  Note.mapFromJSON(Map<String, dynamic> json) {
    this.uid = json['uid'];
    this.text = json['text'];
    this.createdAt = DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'].millisecondsSinceEpoch);
    this.updatedAt = DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'].millisecondsSinceEpoch);
    this.imageURL = json['imageURL'];
  }

  Note.mapFromSnapshot(DocumentSnapshot snapshot) {
    this.uid = snapshot.documentID;

    final json = snapshot.data;
    this.text = json['text'];

    final createdAtTimestamp = json['createdAt']?.millisecondsSinceEpoch;
    this.createdAt = (createdAtTimestamp != null)
        ? DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp)
        : null;

    final updatedAtTimestamp = json['updatedAt']?.millisecondsSinceEpoch;
    this.updatedAt = (updatedAtTimestamp != null)
        ? DateTime.fromMillisecondsSinceEpoch(updatedAtTimestamp)
        : null;

    this.imageURL = json['imageURL'];
  }
}
