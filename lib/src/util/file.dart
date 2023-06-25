import 'dart:convert';
import 'dart:io';

extension FileExtention on File {
  bool inCurrentProject() {
    var currentPath = Directory.current.path;
    return path.startsWith(currentPath);
  }

  Future<List<String>> lines() async {
    var lines = await openRead()
        .map(utf8.decode)
        .transform(const LineSplitter())
        .toList();
    return lines;
  }

  Future<Map<int, String>> linesIndexed() async {
    var lines = await openRead()
        .map(utf8.decode)
        .transform(const LineSplitter())
        .toList();
    Map<int, String> map = {};

    var i = 0;
    for (var line in lines) {
      map[i] = line;
      i += 1;
    }
    return map;
  }

  Future<List<SearchResult>> search(String word) async {
    List<SearchResult> result = [];
    (await linesIndexed()).forEach((index, value) {
      if (value.contains(word)) {
        result.add(SearchResult(index, value));
      }
    });
    return result;
  }
}

class SearchResult {
  int index;
  String line;

  SearchResult(this.index, this.line);
}

void copyFileSync(String source, String target) {
  var file = File(source);

  if (file.existsSync()) {
    var targetFile = File(target);
    if (!targetFile.existsSync()) {
      targetFile.createSync();
    }
    file.copySync(target);
  }
}

Future<void> copyFile(String source, String target) async {
  var file = File(source);

  if (await file.exists()) {
    var targetFile = File(target);
    if (!await targetFile.exists()) {
      await targetFile.create();
    }
    await file.copy(target);
  }
}
