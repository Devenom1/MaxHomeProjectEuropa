import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maxhome_europa/constants.dart';
import 'package:maxhome_europa/home/robot_history_details_view.dart';
import 'package:maxhome_europa/models/Collision.dart';
import 'package:maxhome_europa/models/eurobot.dart';
import 'package:maxhome_europa/models/orientation.dart' as euro_ori;

class RobotDetailsView extends StatelessWidget {
  final EuRobot robot;
  final VoidCallback onDelete;

  const RobotDetailsView(this.robot, this.onDelete, {super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> tableRows = [
      _detailsRow(
        "Initial Position",
        "(${robot.initPos.x}, ${robot.initPos.y}) ${robot.initOrientation.cardinalName}",
      ),
      _detailsRow("Path", robot.path),
      if (robot.pathLengthCompleted > 0) _pathCompletedRow("Path Completed"),

      if (robot.pos != robot.initPos)
        _detailsRow("Current Position", "(${robot.pos.x}, ${robot.pos.y}) ${robot.orientation.cardinalName}"),
    ];
    List<TableRow>? collisionDetailsRows = _collisionDetails();
    if (collisionDetailsRows != null) {
      tableRows.addAll(collisionDetailsRows);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(),
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              rotateRobot(robot.orientation, robot.id),
              SizedBox(width: 8),
              Expanded(child: Table(children: tableRows)),
              IconButton(onPressed: onDelete, icon: Icon(Icons.delete_forever)),
            ],
          ),
          if (robot.movementLogs.isNotEmpty)
            RobotHistoryDetailsView(robot, onDelete)
        ],
      ),
    );
  }

  Widget rotateRobot(euro_ori.Orientation orientation, int robotID) {
    Widget flippedWidget;
    if (orientation.cardinalName == Constants.EAST.cardinalName ||
        orientation.cardinalName == Constants.WEST.cardinalName) {
      print("Orientt: ${orientation.rotation}");
      flippedWidget = Transform.flip(
        flipX: orientation.rotation == 0 || orientation.rotation == 360,
        //quarterTurns: matchedRobot.orientation.turns.toInt(),
        //duration: const Duration(seconds: 2),
        child: Image.asset('assets/rover.png', width: 45, height: 45),
      );
    } else {
      flippedWidget = Transform.rotate(
        angle: (orientation.rotation.toDouble() + 180) * pi / 180,
        //quarterTurns: matchedRobot.orientation.turns.toInt(),
        //duration: const Duration(seconds: 2),
        child: Image.asset('assets/rover.png', width: 45, height: 45),
      );
    }
    return Stack(
      children: [
        flippedWidget,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.green,
            ),
            child: Center(
              child: Text(
                "$robotID",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _detailsRow(String title, String text) {
    return TableRow(
      children: [
        Text("$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  TableRow _pathCompletedRow(String title) {
    String completedText = robot.path.substring(0, robot.pathLengthCompleted);
    TextStyle completedTextStyle = TextStyle(color: Colors.lightGreen);

    String pendingText = robot.path.substring(
      robot.pathLengthCompleted,
      robot.path.length,
    );
    TextStyle pendingTextStyle = TextStyle(color: Colors.redAccent);
    return TableRow(
      children: [
        Text("$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: completedText, style: completedTextStyle),
              TextSpan(text: pendingText, style: pendingTextStyle),
            ],
          ),
        ),
      ],
    );
  }

  List<TableRow>? _collisionDetails() {
    print("Collision Detecting");
    if (robot.collisionsDetected.isEmpty) {
      return null;
    }
    print("Collision Detected");
    Collision collision = robot.collisionsDetected.last;
    return [
      //SizedBox(height: 8),
      TableRow(
        children: [
          SizedBox(height: 10),
          SizedBox(height: 10),
          SizedBox(height: 10),
        ],
      ),
      _detailsRow("Possible Collision", "YES"),
      _detailsRow(
        "Collision With",
        collision.collisionType == CollisionType.BOUNDARY ? "WALL" : "ROBOT",
      ),
      _detailsRow(
        "Collision Point",
        "(${collision.atPos.x}, ${collision.atPos.y}) ${robot.orientation.cardinalName}",
      ),
    ];
  }
}
