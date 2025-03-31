
import 'package:maxhome_europa/constants.dart';
import 'package:maxhome_europa/models/orientation.dart';
import 'package:collection/collection.dart';

extension OrientationExtensions on String {
  Orientation getOrientation() {
    return Constants.allOrientations.firstWhere((e) => e.cardinalAbbr == this);
  }



}

extension OrientationExtensions2 on Orientation {

  Orientation getNewOrientation(String turn) {
    int degreeDelta = (turn == 'L') ? -90 : 90;
    var finalDegrees = (rotation + degreeDelta) % 360;
    if (finalDegrees < 0) {
      finalDegrees += 360;
    }
    Orientation? retOrientation = Constants.allOrientations.firstWhereOrNull((o) => o.rotation == finalDegrees);
    if (retOrientation == null) {
      throw Exception("Invalid orientation");
    }
    return retOrientation;
  }
}