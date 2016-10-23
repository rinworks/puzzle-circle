
// Represents and renders one tile.
class SimpleTile implements  Drawable {

  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  SimpleTile(GraphicsParams params, GraphicsParams hilightedParams) {
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }

  void draw(Cell c) { 
    GraphicsParams params = (c.state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    gUtils.setShapeParams(params);
    rectMode(CENTER);
    final float SPACE = 5;
    gUtils.dottedRect(c.center.x, c.center.y, c.eW, c.eH, SPACE);
  }
}

// Utility methods specific to tile world
// For tile world
class CellHelper {

  GraphicsParams gParams;
  GraphicsParams gHParams; // Hilighted

  public CellHelper() {

    gParams = new GraphicsParams();
    gParams.backgroundFill = 255;
    gParams.borderColor =  0;
    gParams.borderWeight = 2;

    gHParams = new GraphicsParams(gParams);
    gHParams.backgroundFill = color(255, 255, 0); // yellow
  }

  public Grid createGrid(int rows, int cols) {
    int GRID_WIDTH = width;
    int GRID_HEIGHT = height;
    int GRID_PADDING = 10;
    Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING);
    for (int i=0; i<rows; i++) {
      for (int j=0; j<cols; j++) {
        Cell cl = g.cells[i][j];
        cl.dObject = new SimpleTile(gParams, gHParams);
      }
    }
    return g;
  }

  // Mark a rectangular portion of the cells highlighted or not.
  // It's ok if the bounds of the rectangle extend outside the grid - only the portion
  // that overlaps will be considered.
  // cornerX and cornerY are the numerically lowest corners (graphically top left)
  public void highlightCells(Grid g, int cornerX, int cornerY, int w, int h, boolean highlight) {
    int iStart = max(0, cornerY); // Remember - i is row, grows downwards with Y
    int jStart = max(0, cornerX);
    int iEnd = min(g.rows, cornerY+h);
    int jEnd = min(g.cols, cornerX+w);

    for (int i=iStart; i<iEnd; i++) {
      for (int j=jStart; j<jEnd; j++) {
        Cell cl = g.cells[i][j];
        cl.state = highlight ? ShapeState.HILIGHTED : ShapeState.NORMAL;
      }
    }
  }

  public int countHighlightedCells(Grid g) {
    int count = 0;
    for (Cell[] row : g.cells) {
      for (Cell c : row) {
        if (c.state == ShapeState.HILIGHTED) {
          count++;
        }
      }
    }
    return count;
  }
  
  // Return the sum of the digits of i
  public int sumDigits(int i) {
    int sum = 0;
    while (i>0) {
      sum += i%10;
      i /= 10;
    }
    return sum;
  }
}