import 'dart:convert';
import 'dart:io';

import 'package:file_based_transaction_manager/src/session.dart';
import 'package:file_based_transaction_manager/src/transaction_history.dart';

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

  Future<List<TransactionHistory>> history() async {
    List<TransactionHistory> lst = [];

    var transactions = _rootFolder.listSync();

    for (var transaction in transactions.toList()) {
      var lines = await File('${transaction.path}/metadata.txt')
          .openRead()
          .map(utf8.decode)
          .transform(const LineSplitter())
          .toList();

      var date = "";
      for (var value in lines) {
        if (value.contains("DATE")) {
          date = value.replaceAll("DATE:     ", "");
        }
      }
      var transactionHistory = TransactionHistory(transaction.name, date);
      lst.add(transactionHistory);
    }
    lst.sort((i, d) => i.date.compareTo(d.title));
    return lst;
  }

  Future<void> rollbackById(String sessionId) async {
    var session = Session.byId(_rootFolder.path, sessionId);

    rollback(session);
  }
}
