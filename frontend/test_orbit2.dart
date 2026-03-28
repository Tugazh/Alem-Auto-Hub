import 'package:flutter/foundation.dart';
import 'package:o3d/o3d.dart';

class RawOrbit implements CameraOrbit {
  final String raw;
  RawOrbit(this.raw);

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
  String toString() => raw;
}

void main() {
  final orbit = RawOrbit("45deg 75deg auto");
  print(orbit.toString());
}
