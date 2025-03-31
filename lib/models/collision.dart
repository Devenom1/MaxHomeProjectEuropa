

class Collision {
  CollisionType collisionType;
  String? robotID;
  String? boundaryWall;

  Collision(this.collisionType, {this.robotID, this.boundaryWall});
}

enum CollisionType {
  BOUNDARY, ROBOT
}