import 'package:o3d/o3d.dart';
void main() {
  print(CameraOrbit(0, 75, 105));
  final viewer = O3D.asset(src: "x", cameraTarget: CameraTarget(0,0,0));
}
