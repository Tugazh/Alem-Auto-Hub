import 'dart:io';

void main() {
  var file = File('lib/features/car_detail/widgets/car_3d_viewer.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "// removed cameraOrbit to prevent 90m clipping bug",
    "cameraOrbit: _parseCameraOrbit(widget.cameraOrbit),"
  );
  file.writeAsStringSync(content);
}
