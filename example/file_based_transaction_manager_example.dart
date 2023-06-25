import 'dart:io';

import 'package:file_based_transaction_manager/src/session.dart';
import 'package:file_based_transaction_manager/transaction_manager.dart';

void main() async {
  TransactionManager manager = TransactionManager(folderName: "temp");
  var session = manager.beginSession();
  var session2 = manager.beginSession();

  try {
    var file = File(
        '${Directory.current.path}/example/file_based_transaction_manager_example.dart');
    var file2 = File('${Directory.current.path}/example/example_file.txt');

    session.addFile(file);
    session2.addFile(file2);

    file2.deleteSync();
    await Future.delayed(Duration(seconds: 15));
  } catch (error) {
    print("Error Happen: $error");
  }

  manager.rollback(session);
  manager.close(session);

  manager.rollback(session2);
}
