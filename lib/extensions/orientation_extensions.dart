
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
    //println()
    //println("Current Degrees: $degrees, rotate: $directionDelta")
    int degreeDelta = (turn == 'L') ? -90 : 90;
    //println("Degree Delta: $degreeDelta")
    var finalDegrees = (this.rotation + degreeDelta) % 360;
    //println("Final Degrees: $finalDegrees")
    if (finalDegrees < 0) {
      finalDegrees += 360;
      //println("Final Degrees corrected: $finalDegrees")
    }
    //println()
    Orientation? retOrientation = Constants.allOrientations.firstWhereOrNull((o) => o.rotation == finalDegrees);
    if (retOrientation == null) {
      throw Exception("Invalid orientation");
    }
    return retOrientation;
  }
}