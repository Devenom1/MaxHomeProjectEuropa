import 'package:collection/collection.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maxhome_europa/constants.dart';
import 'package:maxhome_europa/models/Collision.dart';
import 'package:maxhome_europa/models/eurobot.dart';
import 'package:maxhome_europa/models/orientation.dart' as euro_ori;

class RobotHistoryDetailsView extends StatelessWidget {
  final EuRobot robot;
  final VoidCallback onDelete;

  const RobotHistoryDetailsView(this.robot, this.onDelete, {super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> allRows = [];
    allRows.add(
        TableRow(
          children: [
            Center(child: Text("Move", style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text("Robot", style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text("Co-ordinates", style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text("Facing", style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text("Movement action", style: TextStyle(fontWeight: FontWeight.bold))),
          ]
        )
    );
    List<TableRow> dataRows = robot.movementLogs.mapIndexed((i, r) {
      IconData actionIcon = Icons.ev_station;
      switch (r.change) {
        case "L":
          actionIcon = Icons.turn_left;
          break;
        case "R":
          actionIcon = Icons.turn_right;
          break;
        case "M":
          actionIcon = Icons.forward;
          break;
      }
      return TableRow(
        //padding: const EdgeInsets.all(8.0),
        children: [
          Center(child: Text(i.toString())),
          Center(child: rotateRobot(r.orientation, robot.id)),
          //SizedBox(width: 10),
          Center(
            child: Text(
              "(${r.pos.x}, ${r.pos.y})",
            ),
          ),
          Center(child: Text(r.orientation.cardinalName)),
          //SizedBox(width: 10),
          Center(child: Icon(actionIcon)),
        ],
      );
    }).toList();
    allRows.addAll(dataRows);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(),
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text("Movement History"),
        children: [
          Table(
            border: TableBorder(),
            children: allRows,
          )
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
        child: Image.asset('assets/rover.png', width: 45, height: 45),
      );
    } else {
      flippedWidget = Transform.rotate(
        angle: (orientation.rotation.toDouble() + 180) * pi / 180,
        child: Image.asset('assets/rover.png', width: 45, height: 45),
      );
    }
    return flippedWidget;
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
        "(${collision.atPos.x}, ${collision.atPos.y}) ${robot.orientation?.cardinalName}",
      ),
    ];
  }
}
