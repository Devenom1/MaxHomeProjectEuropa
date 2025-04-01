// Create a stateful widget
import 'dart:core';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:maxhome_europa/constants.dart';
import 'package:maxhome_europa/extensions/eurobot_extensions.dart';
import 'package:maxhome_europa/extensions/grid_position_extensions.dart';
import 'package:maxhome_europa/extensions/orientation_extensions.dart';
import 'package:maxhome_europa/home/robot_details_view.dart';
import 'package:maxhome_europa/models/eurobot.dart';
import 'package:maxhome_europa/models/grid_position.dart';
import 'package:maxhome_europa/models/orientation.dart' as euro_ori;

import '../models/Collision.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _gridSizeTextController = TextEditingController();
  int _maxGridX = -1;
  int _maxGridY = -1;
  bool _gridTextEnabled = true;

  final TextEditingController _robot1TextController = TextEditingController();
  int robot1X = -1;
  int robot1Y = -1;
  final FocusNode _robotCoordsFocusNode = FocusNode();

  final TextEditingController _robotPathTextController =
      TextEditingController();
  final FocusNode _robotPathFocusNode = FocusNode();

  List<EuRobot> robots = [];
  List<EuRobotLog>? movementLogs;
  int? selectedRobotID;

  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.redAccent, content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Welcome to Europa"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Welcome message
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Hey there! You've reached Europa."
                  "There's an iced up ocean here. Could you determine the area for me? "
                  "Input the top right co-ordinates of the grid separated by spaces. e.g. \"4 7\"",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text("Enter the top right grid co-ordinates below"),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _gridSizeTextController,
                              decoration: const InputDecoration(
                                hintText: "e.g. \"5 5\"",
                              ),
                              enabled: _gridTextEnabled,
                              onSubmitted: (value) => _visualizeGrid,
                              onEditingComplete: _visualizeGrid,
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (_maxGridX != -1 && _maxGridY != -1)
                            IconButton(
                              onPressed: _removeGridValues,
                              icon: Icon(Icons.close),
                            ),
                        ],
                      ),

                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _visualizeGrid,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.remove_red_eye),
                            SizedBox(width: 10),
                            Text("Visualise ocean grid"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_maxGridX != -1 && _maxGridY != -1) addRobotWidget(),
                ],
              ),

              SizedBox(height: 10),
              generateGrid(_maxGridX, _maxGridY),

              SizedBox(height: 8),
              robotDisplayList2(),
              SizedBox(height: 8),
              if (robots.isNotEmpty)
                ElevatedButton(
                  onPressed: _moveRobots,
                  child: Text("Move Robots"),
                ),
              robotDisplayMovementLogs(selectedRobotID ?? 0),
            ],
          ),
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// This method resets the grid values and robots to their initial state
  void _removeGridValues() {
    setState(() {
      _maxGridX = -1;
      _maxGridY = -1;
      _gridSizeTextController.clear();
      _gridTextEnabled = true;
      robots = [];
    });
  }

  /// This method is used to set up the grid
  /// It validates the input just like we would in a terminal application
  void _visualizeGrid() {
    String gridSizeText = _gridSizeTextController.text.trim();
    List<String> sizesStr = gridSizeText.split(" ");
    if (sizesStr.length > 2) {
      showErrorSnackbar(
        context,
        "Oh Oh. We require it for a 2D Grid. We are not that advanced!",
      );
      return;
    }
    for (var s in sizesStr) {
      if (int.tryParse(s) == null) {
        showErrorSnackbar(
          context,
          "Input should only be 2 numbers that are co-ordinates",
        );
        return;
      }
    }
    List<int> sizesInt = sizesStr.map((e) => int.parse(e)).toList();
    setState(() {
      _maxGridX = sizesInt[0];
      _maxGridY = sizesInt[1];
      robots = []; // reset robots if grid is redrawn with a new size
      _gridTextEnabled = false; // disable grid dimensions text editing
    });
    /// request focus on the robot co-ordinates text box
    _robotCoordsFocusNode.requestFocus();
  }

  void _addRobot() {
    setState(() {
      String initPos = _robot1TextController.text.trim();
      if (!initPos.contains(RegExp("^\\d+\\s+\\d+\\s+(N|E|S|W)\$"))) {
        showErrorSnackbar(
          context,
          "Invalid characters detected!. Input should be like \"2 3 E\"",
        );
        return;
      }

      String path = _robotPathTextController.text.trim();
      if (path.contains(RegExp("^((?!L|R|M).)*\$"))) {
        showErrorSnackbar(
          context,
          "Invalid characters detected!. Supported characters are L, R and M",
        );
        return;
      }
      if (!path.contains("M")) {
        showErrorSnackbar(context, "M is required to move the robot");
        return;
      }

      List<String> allSplits = _robot1TextController.text.trim().split(" ");
      int x = int.parse(allSplits[0]);
      int y = int.parse(allSplits[1]);
      if (robots.any((r) => r.pos == GridPosition(x, y))) {
        showErrorSnackbar(context, "There's already a robot there!");
        return;
      }
      if (x > _maxGridX || y > _maxGridY) {
        showErrorSnackbar(
          context,
          "That's out of the grid! $x > $_maxGridX: $y > $_maxGridY",
        );
        return;
      }
      String direction = allSplits[2];
      int newId = (robots.lastOrNull?.id ?? 0) + 1;
      EuRobot newEuRobot = EuRobot(
        newId,
        GridPosition(x, y),
        direction.getOrientation(),
        path,
      );
      print("Orientation: ${newEuRobot.orientation.turns}");
      robots.add(newEuRobot);
      _robotPathTextController.clear();
      _robot1TextController.clear();
      _robotCoordsFocusNode.requestFocus();
    });
  }

  void _moveRobots() {
    Map<GridPosition, int> occupiedPositions = { for (var r in robots) r.pos : r.id };

    /// Iterate through all existing Robots
    for (var (i, r) in robots.indexed) {
      /// Here we check if the current robot has complete it's path
      /// If it has we continue on to the next one
      /// This is done so that we can check if any robots were previous
      /// blocked by others and can continue now
      if (r.pathComplete()) {
        showErrorSnackbar(
          context,
          "Robot ${i + 1} ran it's course. It is overworked!",
        );
        continue;
      }
      String path = r.path.substring(r.pathLengthCompleted, r.path.length);
      print("Path Travelled 1. $i : $path");
      pathLoop:
      for (var pathI = 0; pathI < path.length; pathI++) {
        String action = path[pathI];
        switch (action) {
          case "L":
          case "R":
            r.orientation = r.orientation.getNewOrientation(action);
            setState(() {
              robots[i].orientation = r.orientation;
            });
            r.pathLengthCompleted += 1;
            int newMovementLogId = (r.movementLogs.lastOrNull?.id ?? 0) + 1;
            r.movementLogs.add(
              EuRobotLog(newMovementLogId, r.pos, r.orientation, action),
            );
            break;
          case "M":
            GridPosition newGridPos = r.getMoveForwardGridPosition(action);
            print("Path Travelled 2. $i : $path");

            /// Detection of collision with other robots at their current position
            if (occupiedPositions.containsKey(newGridPos)) {
              print("Collision Detected");
              r.collisionsDetected.add(
                Collision(
                  CollisionType.ROBOT,
                  r.pos,
                  r.orientation,
                  robotID: occupiedPositions[newGridPos],
                ),
              );
              break pathLoop;
            }
            if (newGridPos.isOutsideBounds(_maxGridX, _maxGridY)) {
              r.collisionsDetected.add(
                Collision(CollisionType.BOUNDARY, r.pos, r.orientation),
              );
              break pathLoop;
            }
            occupiedPositions.remove(r.pos);
            r.pos = newGridPos;
            occupiedPositions[r.pos] = r.id;
            r.pathLengthCompleted += 1;
            int newMovementLogId = (r.movementLogs.lastOrNull?.id ?? 0) + 1;
            r.movementLogs.add(
              EuRobotLog(newMovementLogId, r.pos, r.orientation, action),
            );
            if (!r.gridCellsScanned.containsKey(newGridPos)) {
              r.gridCellsScanned[newGridPos] = 0;
            }
            r.gridCellsScanned[newGridPos] = r.gridCellsScanned[newGridPos]! + 1;
            break;
          default:
            throw Exception(
              "Invalid Input: \"$action\" is an invalid character.",
            );
        }
        setState(() {
          robots[i] = r;
        });
      }
      if (i == 0) {
        print("Robot 1 grid cells scanned");
        for (var map in r.gridCellsScanned.entries) {
          print("${map.key}: ${map.value}");
        }
      }
    }
    setState(() {
      robots = robots;
    });
  }

  Widget generateGrid(int endX, int endY) {
    if (endX == -1 && endY == -1) {
      return Container();
    }
    int rowsCount = endY;
    int columnsCount = endX;
    //List<int> rowsIter = List<int>.generate(rowsCount, (i) => i + 1);
    List<int> rowsIter = [];
    for (int i = rowsCount; i >= 0; i--) {
      rowsIter.add(i);
    }
    //List<int> columnsIter = List<int>.generate(columnsCount, (i) => i + 1);
    List<int> columnsIter = [];
    for (int i = 0; i <= columnsCount; i++) {
      columnsIter.add(i);
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage("assets/icy_ocean.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Table(
        border: TableBorder(
          top: BorderSide(),
          bottom: BorderSide(),
          left: BorderSide(),
          right: BorderSide(),
          verticalInside: BorderSide(),
          horizontalInside: BorderSide(),
          borderRadius: BorderRadius.circular(5),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children:
            rowsIter.map((rowI) {
              return TableRow(
                children:
                    columnsIter.map((columnI) {
                      return Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          () {
                            if (robots.any(
                              (r) => r.pos == GridPosition(columnI, rowI),
                            )) {
                              EuRobot matchedRobot = robots.firstWhere(
                                (r) => r.pos == GridPosition(columnI, rowI),
                              );
                              return rotateRobot(
                                matchedRobot.orientation,
                                matchedRobot.id,
                              );
                            } else {
                              return SizedBox(width: 45, height: 45);
                            }
                          }(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: Container(
                                color: Colors.black,
                                child: Text(
                                  "($columnI, $rowI)",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              );
            }).toList(),
      ),
    );
  }

  Widget addRobotWidget() {
    if (_maxGridX == -1 && _maxGridY == -1) {
      return Container();
    }
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextFormField(
              controller: _robot1TextController,
              decoration: InputDecoration(
                label: Text(
                  "Input the co-ordinates and directions here",
                  style: TextStyle(fontSize: 10),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: "e.g. \"1 2 N\"",
              ),
              textAlign: TextAlign.center,
              onEditingComplete: () {
                _robotPathFocusNode.requestFocus();
              },
              onFieldSubmitted: (value) {
                _robotPathFocusNode.requestFocus();
              },
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 200,
            child: TextFormField(
              controller: _robotPathTextController,
              decoration: InputDecoration(
                label: Text(
                  "Input the movement path here",
                  style: TextStyle(fontSize: 10),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: "e.g. \"LMLMRMLMRM\"",
              ),
              textAlign: TextAlign.center,
              focusNode: _robotPathFocusNode,
              onEditingComplete: _addRobot,
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(onPressed: _addRobot, child: Text("Add Robot")),
        ],
      ),
    );
  }

  Widget robotDisplayList() {
    if (robots.isEmpty) return Container();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
            robots.mapIndexed((i, r) {
              String finalPos = "";
              String finalOrientation = "";
              if (r.movementLogs.length > 1) {
                finalPos = " -> ${r.pos}";
                finalOrientation = " -> ${r.orientation.cardinalAbbr}";
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  rotateRobot(r.orientation, r.id),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                        "Position: ${r.initPos}$finalPos, Orientation: ${r.initOrientation.cardinalAbbr}$finalOrientation\npath: ${r.path}",
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  if (r.movementLogs.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          movementLogs = r.movementLogs;
                          selectedRobotID = r.id;
                        });
                      },
                      child: Text("Logs"),
                    ),
                  if (r.movementLogs.isNotEmpty) SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        robots.remove(r);
                        robots = robots;
                        movementLogs = null;
                        selectedRobotID = null;
                      });
                    },
                    icon: Icon(Icons.delete_forever),
                  ),
                  if (r.collisionsDetected.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Text(
                        "Will collide!",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget robotDisplayList2() {
    if (robots.isEmpty) return Container();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
            robots.mapIndexed((i, r) {
              onDelete() {
                setState(() {
                  robots.remove(r);
                  robots = robots;
                  movementLogs = null;
                  selectedRobotID = null;
                });
              }

              return RobotDetailsView(r, onDelete);
            }).toList(),
      ),
    );
  }

  Widget robotDisplayMovementLogs(int robotID) {
    if (movementLogs == null || movementLogs?.isEmpty == true) {
      return Container();
    }
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              movementLogs = null;
              selectedRobotID = null;
            });
          },
          child: Text("Close"),
        ),
        Text("Movement Logs"),
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
                movementLogs!.mapIndexed((i, r) {
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
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        rotateRobot(r.orientation, robotID),
                        SizedBox(width: 10),
                        Text(
                          "${r.pos}, path: ${r.orientation.cardinalName}",
                        ),
                        SizedBox(width: 10),
                        Icon(actionIcon),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
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
}
