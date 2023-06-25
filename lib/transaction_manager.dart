import 'dart:io';

import 'package:file_based_transaction_manager/src/session.dart';

extension FileExtention on FileSystemEntity {
  String get name {
    return path.split("/").last;
  }
}

class TransactionManager {
  late String _tempFolderName = "";
  static final TransactionManager _singleton = TransactionManager._internal();

  final Map<String, Session> _sessions = {};

  late Directory _rootFolder;

  factory TransactionManager({String? folderName}) {
    _singleton._tempFolderName = folderName ?? ".transactions";

    _singleton._rootFolder =
        Directory('${Directory.current.path}/${_singleton._tempFolderName}');
    if (!_singleton._rootFolder.existsSync()) {
      _singleton._rootFolder.createSync(recursive: true);
    }

    return _singleton;
  }

  TransactionManager._internal();

  Session beginSession({List<File>? files}) {
    var uuid = "${DateTime.now().microsecondsSinceEpoch}";
    var session = Session(_rootFolder.name, files: files);
    _sessions[uuid] = session;
    return session;
  }

  void rollback(Session session) {
    session.rollback();
  }

  close(Session session) {
    session.close();
  }
}
