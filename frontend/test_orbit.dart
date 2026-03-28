import 'package:o3d/o3d.dart';

class MyOrbit implements CameraOrbit {
  @override
  double get theta => 0;
  @override
  set theta(double v) {}
  
  @override
  double get phi => 0;
  @override
  set phi(double v) {}

  @override
  double get radius => 0;
  @override
  set radius(double v) {}

  @override
  String toString() => "foo";
}

void main() {
  print(MyOrbit().toString());
}
