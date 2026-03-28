import 'dart:io';

void main() {
  var file = File('lib/features/home/home_page.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "carName: car.name,",
    "carName: car.name,\n            cameraOrbit: '-45deg 75deg 105%',"
  );
  file.writeAsStringSync(content);
}
