import 'dart:io';

import 'package:file_based_transaction_manager/src/util/file.dart';
import 'package:file_based_transaction_manager/transaction_manager.dart';

class Session {
  final String _root;
  final Map<String, String> _files = {};
  bool _isValid = true;
  late String _sessionId;

  Directory get currentSessionFolder =>
      Directory('${Directory.current.path}/$_root/$_sessionId/files');

  static Session byId(String root, String id) {
    var session = Session(root, id: id);
    return session;
  }

  Session(this._root, {String? id, List<File>? files}) {
    _sessionId = id ?? "${DateTime.now().microsecondsSinceEpoch}";
    var isDirectoryExists = currentSessionFolder.existsSync();
    if (!isDirectoryExists) {
      currentSessionFolder.createSync(recursive: true);
    }
    for (var element in (files ?? [])) {
      addFile(element);
    }

    _saveInfoMetaData();
  }

  void addFile(File file) {
    _checkIsValid();

    if (!file.existsSync()) {
      print("ignore add file");
      return;
    }
    var randomNumber = "${DateTime.now().microsecondsSinceEpoch}";
    if (!_files.containsKey(file)) {
      _files[file.path] = randomNumber;
      copyFileSync(file.path, "${currentSessionFolder.path}/$randomNumber");
    }
  }

  Future<void> removeFile(File file) async {
    _checkIsValid();

    if (!_files.containsKey(file.path)) {
      print("File not exists");
      return;
    }

    var targetId = _files[file.path];
    var targetFile = File("${currentSessionFolder.path}/${targetId}");
    if (targetFile.existsSync()) {
      targetFile.deleteSync(recursive: true);
    }
    _files.remove(file.path);
  }

  void rollback() async {
    _checkIsValid();

    print("Rollback Started");

    try {
      for (var entry in _files.entries) {
        var target = entry.key;
        var source = "${currentSessionFolder.path}/${entry.value}";

        try {
          var x = File(source).copySync(target);
        } catch (error, stack) {
          print("error: ${error}");
        }
      }
    } catch (error, stack) {
      print("Rollback Error: ${error}");
      print(stack);
      throw error;
    }

    _isValid = false;
  }

  Future<void> removeAll() async {
    _checkIsValid();
    currentSessionFolder.deleteSync(recursive: true);

    for (var entry in _files.entries) {
      var file = File("${currentSessionFolder.path}/${entry.value}");
      print("remove file: ${file.path}");
      await removeFile(file);
    }

    _files.clear();
  }

  void _checkIsValid() {
    if (!_isValid) {
      throw Exception("This session has been rolled back");
    }
  }

  void close() {
    currentSessionFolder.parent.deleteSync(recursive: true);
    print("session has been closed");
  }

  void _saveInfoMetaData() {
    var metadata = """
DATE:     ${DateTime.now()}
PROJECT:  ${Directory.current.name}
    """;

    var file = File('${currentSessionFolder.path}/metadata.txt');
    file.createSync();
    file.writeAsStringSync(metadata);
  }

  String getId() {
    return _sessionId;
  }

  String getRoot() {
    return _root;
  }
}
