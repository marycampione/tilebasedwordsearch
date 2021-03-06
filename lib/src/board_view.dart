part of tilebasedwordsearch;

class TileCoord {
  num x, y;
  TileCoord(this.x, this.y);
}

class BoardView {
  final int WIDTH = 800;
  final int HEIGHT = 600;
  CanvasElement canvas;
  String selectedLetters = '';
  final Set<int> selectedTiles = new Set<int>();

  num tileSize;
  num gapSize;

  RectangleTransform canvasTransform;
  final List<RectangleTransform> letterTiles = new List<RectangleTransform>();

  final Board board;

  BoardView(this.board, this.canvas) {
    letterTiles.length = 16;
    init();
  }


  void init() {
    canvas.width = WIDTH;
    canvas.height = HEIGHT;

    var constraint = min(WIDTH, HEIGHT);

    tileSize = constraint / 4.75;
    gapSize = tileSize * 0.25;

    // Loop through the tiles and draw each one.
    for (int i = 0; i < GameConstants.BoardDimension; i++) {
      for (int j = 0; j < GameConstants.BoardDimension; j++) {
        num x = (i * (tileSize + gapSize)).toInt();
        num y = (j * (tileSize + gapSize)).toInt();
        num width = tileSize.toInt();
        num height = tileSize.toInt();
        letterTiles[GameConstants.rowColumnToIndex(i, j)] =
            new RectangleTransform.raw(x, y, width, height);
      }
    }
  }

  void clearSelected() {
    selectedTiles.clear();
    selectedLetters = '';
  }

  void selectSearchString(String searchString) {
    Set<List<int>> paths = new Set<List<int>>();
    if (searchString.length == 0) {
      return;
    }
    clearSelected();
    if (board.config.stringInGrid(searchString, paths)) {
      paths.forEach((path) {
        for (int i = 0; i < path.length; i++) {
          selectedTiles.add(path[i]);
        }
      });
    }
  }

  RectangleTransform getTileRectangle(int row, int column) {
    return letterTiles[GameConstants.rowColumnToIndex(row, column)];
  }

  TileCoord getTileCoord(int row, int column) {
    num x = column * (tileSize + gapSize);
    num y = row * (tileSize + gapSize);
    return new TileCoord(x, y);
  }

  void update(GameLoopTouch touch) {
    double scaleX = canvas.clientWidth/canvas.width;
    double scaleY = canvas.clientHeight/canvas.height;
    if (touch != null) {
      for (var position in touch.positions) {
        int x = (position.x * scaleX).toInt();
        int y = (position.y * scaleY).toInt();
        for (int i = 0; i < GameConstants.BoardDimension; i++) {
          for (int j = 0; j < GameConstants.BoardDimension; j++) {
            int index = GameConstants.rowColumnToIndex(i, j);
            if (selectedTiles.contains(index)) {
              continue;
            }
            var transform = getTileRectangle(i, j);
            if (transform.contains(x, y)) {
              print('Adding $index');
              selectedTiles.add(index);
              selectedLetters += board.config.getChar(i,j);
            }
          }
        }
      }
    } else {
      clearSelected();
    }
    if (selectedTiles.length > 0) {
      print(selectedTiles);
      print(selectedLetters);
    }
  }

  void render() {
    var c = canvas.context2D;
    // Clear canvas.
    c.clearRect(0, 0, WIDTH, HEIGHT);

    const int X_OFFSET = 5;
    const int Y_OFFSET = 60;

    for (int i = 0; i < letterTiles.length; i++) {
      int x = letterTiles[i].left;
      int y = letterTiles[i].top;
      if (selectedTiles.contains(i)) {
        c.strokeStyle = '#ff0000';
      } else {
        c.strokeStyle = '#000000';
      }
      letterTiles[i].drawOutline(canvas);
      var elementName = board.config.getChar(
          GameConstants.rowFromIndex(i),
          GameConstants.columnFromIndex(i));
      letterAtlas.draw(elementName, c, x, y);
      c.fillText(GameConstants.letterScores[elementName].toString(),
                 x + X_OFFSET, y + Y_OFFSET);
    }
  }
}
