import 'dart:io';

import 'package:file_based_transaction_manager/src/session.dart';
import 'package:file_based_transaction_manager/transaction_manager.dart';

void main() async {
  TransactionManager x2 = TransactionManager(folderName: "temp");
  var session = x2.beginSession();
  var session2 = x2.beginSession();

  var file = File(
      '${Directory.current.path}/example/file_based_transaction_manager_example.dart');
  var file2 = File('${Directory.current.path}/example/example_file.txt');

  session.addFile(file);
  session2.addFile(file2);

  file2.deleteSync();
  await Future.delayed(Duration(seconds: 15));

  x2.rollback(session);
  x2.close(session);
}
