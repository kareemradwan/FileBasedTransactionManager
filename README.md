File Based Transaction Manager

## Features

Create Multiple Sessions
Add Files to Sessions
Remove Files from Session
Rollback Sessions
Close Sessions


## Getting started

TODO: Save a Copy from your files easily and rollback them any time.
start using the package.

## Usage

Example of how you can use the library:

```dart

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

```

## Additional information

draft version