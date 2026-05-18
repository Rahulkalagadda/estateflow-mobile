import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart') && !f.path.contains('app_theme.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    if (!content.contains('AppColors.')) continue;
    
    var lines = content.split('\n');
    for (int i = 0; i < lines.length; i++) {
       if (lines[i].contains('AppColors.')) {
          lines[i] = lines[i].replaceAll('const ', '');
          if (i > 0 && lines[i-1].contains('const ') && !lines[i-1].contains('AppColors')) {
             lines[i-1] = lines[i-1].replaceAll('const ', '');
          }
       }
    }
    content = lines.join('\n');
    content = content.replaceAll('AppColors.', 'context.colors.');
    
    file.writeAsStringSync(content);
    print('Refactored ${file.path}');
  }
}
