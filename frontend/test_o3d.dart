import 'package:o3d/o3d.dart';

void main() {
  final viewer = O3D.asset(
    src: 'assets/test.glb',
    cameraOrbit: CameraOrbit(0, 75, 105),
  );
}
