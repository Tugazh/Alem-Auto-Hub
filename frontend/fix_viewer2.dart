import 'dart:io';

void main() {
  var file = File('lib/features/car_detail/widgets/car_3d_viewer.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "cameraOrbit: _parseCameraOrbit(widget.cameraOrbit),",
    "// removed cameraOrbit to prevent 90m clipping bug",
  );
  file.writeAsStringSync(content);
}
