// Create a stateful widget
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:maxhome_europa/constants.dart';
import 'package:maxhome_europa/extensions/orientation_extensions.dart';
import 'package:maxhome_europa/models/eurobot.dart';
import 'package:maxhome_europa/models/grid_position.dart';
import 'package:maxhome_europa/models/orientation.dart' as euro_ori;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _gridSizeTextController = TextEditingController();
  int _maxGridX = -1;
  int _maxGridY = -1;

  final TextEditingController _robot1TextController = TextEditingController();
  int robot1X = -1;
  int robot1Y = -1;

  final TextEditingController _robotPathTextController =
      TextEditingController();

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
              // Title
              Text("Hey there! You've reached Europa."),
              SizedBox(height: 10),
              // message
              Text(
                "There's an iced up ocean here. Could you determine the area for me? "
                "Input the top right co-ordinates of the grid separated by spaces. e.g. (4, 7)",
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(controller: _gridSizeTextController),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        String gridSizeText =
                            _gridSizeTextController.text.trim();
                        List<String> sizesStr = gridSizeText.split(" ");
                        if (sizesStr.length > 2) {
                          showErrorSnackbar(
                            context,
                            "Oh Oh. We require it for a 2D Grid. We are not that advanced!",
                          );
                          return;
                        }
                        List<int> sizesInt =
                            sizesStr.map((e) => int.parse(e)).toList();
                        setState(() {
                          _maxGridX = sizesInt[0];
                          _maxGridY = sizesInt[1];
                          robots = [];
                          movementLogs = null;
                        });
                      },
                      child: Text("Visualise ocean grid"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              generateGrid(_maxGridX, _maxGridY),
              addRobotWidget(),
              SizedBox(height: 8),
              robotDisplayList(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _moveRobots() {
    for (var (i, r) in robots.indexed) {
      if (r.movementLocked) {
        showErrorSnackbar(context, "Robots ran their course. They are overworked!");
        return;
      }
      String path = r.path;
      for (var rune in path.runes) {
        String action = String.fromCharCode(rune);
        switch (action) {
          case "L":
          case "R":
            r.orientation = r.orientation?.getNewOrientation(
              action,
            );
            setState(() {
              robots[i].orientation = r.orientation;
            });
            break;
          case "M":
            switch (r.orientation) {
              case Constants.NORTH:
                r.pos?.y += 1;
                break;
              case Constants.EAST:
                r.pos?.x += 1;
                break;
              case Constants.SOUTH:
                r.pos?.y -= 1;
                break;
              case Constants.WEST:
                r.pos?.x -= 1;
                break;
              default:
                throw Exception(
                  "Invalid Input: \"$action\" is an invalid character.",
                );
            }
            break;
          default:
            throw Exception(
              "Invalid Input: \"$action\" is an invalid character.",
            );
        }
        r.movementLogs.add(
          EuRobotLog(r.pos ?? GridPosition(0, 0), r.orientation ?? Constants.NORTH, action),
        );
        setState(() {
          robots[i] = r;
        });
      }
      r.movementLocked = true;
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
                          (r) => r.pos?.x == columnI && r.pos?.y == rowI,
                    )) {
                      EuRobot matchedRobot = robots.firstWhere(
                            (r) => r.pos?.x == columnI && r.pos?.y == rowI,
                      );
                      return rotateRobot(matchedRobot.orientation ?? Constants.NORTH, matchedRobot.id);
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
                              color: Colors.white
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: TextField(
            controller: _robot1TextController,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _robotPathTextController,
            textAlign: TextAlign.center,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
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

              List<String> allSplits = _robot1TextController.text.trim().split(
                " ",
              );
              int x = int.parse(allSplits[0]);
              int y = int.parse(allSplits[1]);
              if (robots.any((r) => r.pos?.x == x && r.pos?.y == y)) {
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
              print("Orientation: ${newEuRobot.orientation?.turns}");
              robots.add(newEuRobot);
            });
          },
          child: Text("Add Robot"),
        ),
      ],
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
                finalPos = " -> (${r.pos?.x},${r.pos?.y})";
                finalOrientation = " -> ${r.orientation?.cardinalAbbr}";
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  rotateRobot(r.orientation ?? Constants.NORTH, r.id),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Text("Position: (${r.initPos.x},${r.initPos.y})$finalPos, Orientation: ${r.initOrientation.cardinalAbbr}$finalOrientation\npath: ${r.path}"),
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
                ],
              );
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
                          "x: ${r.pos.x}, y: ${r.pos.y}, path: ${r.orientation.cardinalName}",
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
            child: Center(child: Text(
              "$robotID",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
              ),
            )),
          ),
        )
      ],
    );
  }
}
