import 'package:maxhome_europa/models/orientation.dart';

class Constants {
  static const Orientation NORTH = Orientation("N", "NORTH", "^", 90, 2);
  static const Orientation EAST = Orientation("E", "EAST", ">", 180, 4);
  static const Orientation SOUTH = Orientation("S", "SOUTH", "v", 270, 6);
  static const Orientation WEST = Orientation("W", "WEST", "<", 0, 8);

  static List<Orientation> allOrientations = [
    NORTH, EAST, SOUTH, WEST
  ];
}