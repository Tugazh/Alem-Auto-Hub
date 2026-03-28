import 'dart:io';

void main() {
  var file = File('lib/features/home/home_page.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "cameraOrbit: '-45deg 75deg 90%',",
    "cameraOrbit: '45deg 75deg 105%',"
  );
  content = content.replaceAll(
    "final scale = (1.0 - (delta.abs() * 0.35)) * 1.25;",
    "final scale = (1.0 - (delta.abs() * 0.35)) * 1.45;"
  );
  file.writeAsStringSync(content);
}
