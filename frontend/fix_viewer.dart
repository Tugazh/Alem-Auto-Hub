import 'dart:io';

void main() {
  var file = File('lib/features/car_detail/widgets/car_3d_viewer.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    '''        final radius =
            double.parse(parts[2].replaceAll(RegExp(r'[^0-9\\.\\-]'), ''));
        return CameraOrbit(theta, phi, radius);''',
    '''        double radius = 105.0; // fallback
        if (parts[2] != 'auto') {
          radius = double.tryParse(parts[2].replaceAll(RegExp(r'[^0-9\\.\\-]'), '')) ?? 105.0;
        }
        return CameraOrbit(theta, phi, radius);'''
  );
  file.writeAsStringSync(content);
}
