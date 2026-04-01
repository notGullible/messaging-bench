import 'dart:io';

void main() {
  final modelsDir = Directory('assets/models');
  final pubspec = File('pubspec.yaml');

  if (!modelsDir.existsSync()) {
    print('Error: assets/models directory does not exist');
    return;
  }

  final subfolders = modelsDir.listSync().whereType<Directory>().map((d) {
    final path = d.path.replaceAll('\\', '/');
    return '    - $path/';
  }).toList();

  if (subfolders.isEmpty) {
    print('No model folders found in assets/models/');
    return;
  }

  final subfolderEntries = subfolders.join('\n');
  print('Found model folders:\n$subfolderEntries\n');

  var content = pubspec.readAsStringSync();

  final assetsBlock = '  assets:';
  final assetsIndex = content.indexOf(assetsBlock);

  if (assetsIndex == -1) {
    print('Could not find assets section in pubspec.yaml');
    return;
  }

  final afterAssets = content.substring(assetsIndex + assetsBlock.length);
  final nextNonWhitespace = RegExp(r'\n\S').firstMatch(afterAssets);

  int endIndex;
  if (nextNonWhitespace != null) {
    endIndex = assetsIndex + assetsBlock.length + nextNonWhitespace.start;
  } else {
    endIndex = content.length;
  }

  final newContent =
      content.substring(0, endIndex) +
      '\n$subfolderEntries\n' +
      content.substring(endIndex);

  pubspec.writeAsStringSync(newContent);
  print('pubspec.yaml updated successfully');
}
