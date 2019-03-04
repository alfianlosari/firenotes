import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadTaskListTile extends StatelessWidget {
  const UploadTaskListTile(
      {Key key, this.task, this.onDismissed, this.onDownload})
      : super(key: key);

  final StorageUploadTask task;
  final VoidCallback onDismissed;
  final VoidCallback onDownload;

  String get status {
    String result;
    if (task.isComplete) {
      if (task.isSuccessful) {
        result = 'Complete';
      } else if (task.isCanceled) {
        result = 'Canceled';
      } else {
        result = 'Failed ERROR: ${task.lastSnapshot.error}';
      }
    } else if (task.isInProgress) {
      result = 'Uploading';
    } else if (task.isPaused) {
      result = 'Paused';
    }
    return result;
  }

  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    final percentage =
        (snapshot.bytesTransferred / snapshot.totalByteCount) * 100;
    return "${percentage.toInt()}%";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageTaskEvent>(
      stream: task.events,
      builder: (BuildContext context,
          AsyncSnapshot<StorageTaskEvent> asyncSnapshot) {
        Widget subtitle;
        if (asyncSnapshot.hasData) {
          final StorageTaskEvent event = asyncSnapshot.data;
          final StorageTaskSnapshot snapshot = event.snapshot;
          subtitle = Text('${_bytesTransferred(snapshot)}');
        } else {
          subtitle = const Text('Starting...');
        }
        return ListTile(
          key: Key(task.hashCode.toString()),
          title: Text('$status'),
          subtitle: subtitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Offstage(
                offstage: !task.isInProgress,
                child: IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () => task.pause(),
                ),
              ),
              Offstage(
                offstage: !task.isPaused,
                child: IconButton(
                  icon: const Icon(Icons.file_upload),
                  onPressed: () => task.resume(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
