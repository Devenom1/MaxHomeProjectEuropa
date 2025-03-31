import 'package:maxhome_europa/models/grid_position.dart';
import 'package:maxhome_europa/models/orientation.dart';

class Collision {
  CollisionType collisionType;
  GridPosition atPos;
  Orientation collisionDirection;
  int? robotID;

  Collision(this.collisionType, this.atPos, this.collisionDirection, {this.robotID});
}

enum CollisionType {
  BOUNDARY, ROBOT
}