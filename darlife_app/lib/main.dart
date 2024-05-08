import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game of Life',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameOfLifePage(),
    );
  }
}

class GameOfLifePage extends StatefulWidget {
  const GameOfLifePage({super.key});

  @override
  _GameOfLifePageState createState() => _GameOfLifePageState();
}

class _GameOfLifePageState extends State<GameOfLifePage> {
  static const int gridHeight = 20;
  static const int gridWidth = 20;
  List<List<bool>> grid = List.generate(gridHeight, (_) => List.generate(gridWidth, (_) => false));
  Timer? timer;
  bool isRunning = false;

  void toggleCell(int x, int y) {
    setState(() {
      grid[x][y] = !grid[x][y];
    });
  }

  void clearGrid() {
    setState(() {
      grid = List.generate(gridHeight, (_) => List.generate(gridWidth, (_) => false));
      stopSimulation();
    });
  }

  void updateGrid() {
    List<List<bool>> newGrid = List.generate(gridHeight, (_) => List.generate(gridWidth, (_) => false));
    for (int x = 0; x < gridHeight; x++) {
      for (int y = 0; y < gridWidth; y++) {
        int numAlive = countAliveNeighbors(x, y);
        if (grid[x][y]) {
          newGrid[x][y] = numAlive == 2 || numAlive == 3;
        } else {
          newGrid[x][y] = numAlive == 3;
        }
      }
    }
    setState(() {
      grid = newGrid;
    });
  }

  int countAliveNeighbors(int x, int y) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;
        int newX = x + i;
        int newY = y + j;
        if (newX >= 0 && newX < gridHeight && newY >= 0 && newY < gridWidth) {
          if (grid[newX][newY]) {
            count++;
          }
        }
      }
    }
    return count;
  }

  void startSimulation() {
    if (!isRunning) {
      timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        updateGrid();
      });
      setState(() {
        isRunning = true;
      });
    }
  }

  void stopSimulation() {
    if (timer?.isActive == true) {
      timer?.cancel();
      setState(() {
        isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game of Life'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: isRunning ? null : startSimulation,
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: !isRunning ? null : stopSimulation,
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearGrid,
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          // Get the height of the AppBar and the status bar
          double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;
          double statusBarHeight = MediaQuery.of(context).padding.top;

          // Calculate the available height for the grid by subtracting the AppBar and status bar height from the total height
          double gridAreaHeight = MediaQuery.of(context).size.height - appBarHeight - statusBarHeight;

          return GestureDetector(
            onPanUpdate: (details) {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              var localPosition = renderBox.globalToLocal(details.globalPosition);

              // Adjust the y-coordinate by subtracting the AppBar and status bar height
              double adjustedYPosition = localPosition.dy - appBarHeight - statusBarHeight;

              // Calculate cell indices
              int x = ((localPosition.dx / renderBox.size.width) * gridWidth).floor();
              int y = ((adjustedYPosition / gridAreaHeight) * gridHeight).floor();

              if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
                setState(() {
                  grid[y][x] = true;
                });
              }
            },
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridWidth,
              ),
              itemCount: gridHeight * gridWidth,
              itemBuilder: (BuildContext context, int index) {
                int x = index % gridWidth;
                int y = index ~/ gridWidth;
                return GestureDetector(
                  onTap: () => toggleCell(y, x),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey),
                      color: grid[y][x] ? Colors.black : Colors.white,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
