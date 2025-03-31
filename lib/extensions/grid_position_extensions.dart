import 'package:collection/collection.dart';
import 'package:maxhome_europa/models/eurobot.dart';
import 'package:maxhome_europa/models/grid_position.dart';

extension GridPositionExtensions on GridPosition {

  EuRobot? firstCollidingRobot(List<EuRobot> otherRobots) {
    return otherRobots.firstWhereOrNull((ro) => ro.pos == this);
  }

  bool isWithinBounds(int maxX, int maxY) =>
    x > maxX || x < 0 || y > maxY || y < 0;

}