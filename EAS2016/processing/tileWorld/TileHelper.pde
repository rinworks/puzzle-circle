
// Represents and renders one tile.
class TextTile implements  Drawable {

  String label;
  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  TextTile(String label, GraphicsParams params, GraphicsParams hilightedParams) {
    this.label = label;
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }

  void draw(Cell c) { 
    GraphicsParams params = (c.state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    int a = 30, b=10;
    pushMatrix();
    translate(c.center.x, c.center.y);
    rotate(radians(-c.orientation));
    gUtils.setShapeParams(params);
    rectMode(CENTER);
    rect(0, 0, c.eW, c.eH);
    gUtils.setTextParams(params);
    text(label, 0, -b/4.0);
    popMatrix();
  }
}

// Utility methods specific to tile world
// For tile world
class TileHelper {

  GraphicsParams gParams;
  final String DEFAULT_FONT = "Segoe WP Black";

  public TileHelper() {

    // Set look of the textboxes
    gParams = new GraphicsParams();
    gParams.font = createFont(DEFAULT_FONT, 7); // null means don't set
    gParams.textColor = 0;
    gParams.backgroundFill = 255;
    gParams.borderColor = 128;
    gParams.borderWeight = 3;
  }


  public Grid createGrid(int rows, int cols) {
    int GRID_WIDTH = width;
    int GRID_HEIGHT = height;
    int GRID_PADDING = 10;
    Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING);
    for (int i=0; i<rows; i++) {
      //String row = spec[i];
      for (int j=0; j<cols; j++) {
        Cell cl = g.cells[i][j];
        cl.dObject = new TextTile("FOO", gParams, gParams);
      }
    }
    return g;
  }
}