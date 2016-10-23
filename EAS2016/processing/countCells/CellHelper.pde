
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
    gUtils.dottedRect(c.center.x, c.center.y, c.eW, c.eH, 10);
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
    gParams.borderColor =  128;
    gParams.borderWeight = 3;

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
    int iStart = max(0,cornerX);
    int jStart = max(0,cornerY);
    int iEnd = min(g.rows, cornerX+w);
    int jEnd = min(g.cols, cornerX+w);
    for (int i=iStart; i<iEnd; i++) {
      for (int j=jStart; j<jEnd; j++) {
        Cell cl = g.cells[i][j];
        cl.state = highlight ? ShapeState.HILIGHTED : ShapeState.NORMAL;
      }
    }
  }
}