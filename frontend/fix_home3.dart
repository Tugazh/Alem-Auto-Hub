import 'dart:io';

void main() {
  var file = File('lib/features/home/home_page.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "cameraOrbit: '45deg 75deg 105%',",
    "cameraOrbit: '45deg 75deg auto',"
  );
  content = content.replaceAll(
    "cameraOrbit: '0deg 75deg 105%',",
    "cameraOrbit: '45deg 75deg auto',"
  );
  file.writeAsStringSync(content);
}
