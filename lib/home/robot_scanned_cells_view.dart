import 'package:collection/collection.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maxhome_europa/constants.dart';
import 'package:maxhome_europa/models/eurobot.dart';
import 'package:maxhome_europa/models/orientation.dart' as euro_ori;

class RobotScannedCellsView extends StatelessWidget {
  final EuRobot robot;
  final VoidCallback onDelete;

  const RobotScannedCellsView(this.robot, this.onDelete, {super.key});

  @override
  Widget build(BuildContext context) {
    List<TableRow> allRows = [];
    allRows.add(
        TableRow(
          children: [
            Center(child: Text("Index", style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text("Grid Cell", style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text("Scan Frequency", style: TextStyle(fontWeight: FontWeight.bold)))
          ]
        )
    );
    List<TableRow> dataRows = robot.gridCellsScanned.entries.mapIndexed((i, r) {

      return TableRow(
        //padding: const EdgeInsets.all(8.0),
        children: [
          Center(child: Text(i.toString())),
          Center(child: Text(r.key.toString())),
          Center(child: Text(r.value.toString())),
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
        title: Text("Grid cell scan frequency"),
        children: [
          Table(
            border: TableBorder(),
            children: allRows,
          )
        ],
      ),
    );
  }

}
