import 'package:collection/collection.dart';
import 'package:maxhome_europa/constants.dart';
import 'package:maxhome_europa/models/eurobot.dart';
import 'package:maxhome_europa/models/grid_position.dart';
import 'package:maxhome_europa/models/orientation.dart';

extension EurobotExtensions on EuRobot {

  GridPosition getMoveForwardGridPosition(String action) {
    GridPosition newGridPos = GridPosition(pos.x, pos.y);
    switch (orientation) {
      case Constants.NORTH:
        newGridPos.y += 1;
        break;
      case Constants.EAST:
        newGridPos.x += 1;
        break;
      case Constants.SOUTH:
        newGridPos.y -= 1;
        break;
      case Constants.WEST:
        newGridPos.x -= 1;
        break;
      default:
        throw Exception(
          "Invalid Input: \"$action\" is an invalid character.",
        );
    }
    return newGridPos;
  }

}