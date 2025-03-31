
import 'package:maxhome_europa/constants.dart';
import 'package:maxhome_europa/models/Collision.dart';
import 'package:maxhome_europa/models/grid_position.dart';
import 'package:maxhome_europa/models/orientation.dart';

class EuRobot {
  int id;
  GridPosition initPos;
  Orientation initOrientation;
  String path;
  List<EuRobotLog> movementLogs = [];
  GridPosition pos = GridPosition(0, 0);
  Orientation? orientation;
  int pathLengthCompleted = 0;
  bool movementLocked = false;
  List<Collision> collisionsDetected = [];

  EuRobot(this.id, this.initPos, this.initOrientation, this.path) {
    pos = GridPosition(initPos.x, initPos.y);
    orientation = Constants.allOrientations.firstWhere((o) =>
    o.cardinalName == initOrientation.cardinalName);
  }
}

class EuRobotLog {
  int id;
  GridPosition pos;
  Orientation orientation;
  String change;
  bool collided = false;

  EuRobotLog(this.id, this.pos, this.orientation, this.change);
}