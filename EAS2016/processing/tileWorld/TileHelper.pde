
// Represents and renders one tile.
class TextTile implements  Drawable {

  String centerText;
  String[] borderTexts;
  int borderTextSize; // This one is not in graphicsParams so we keep it here.
  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  TextTile(String centerText, String[] borderTexts, GraphicsParams params, GraphicsParams hilightedParams) {
    this.centerText = centerText;
    this.borderTexts = borderTexts;
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
    this.borderTextSize = 20;
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
    text(centerText, 0, -b/4.0);
    textSize(borderTextSize);
    if (borderTexts[0]!=null) {
      text(borderTexts[0], 0, (-c.iH/2.0 + b)); // North
    }
    if (borderTexts[1]!=null) {
      text(borderTexts[1], (c.iW/2.0 - b), 0); // East
    }
    if (borderTexts[2]!=null) {
      text(borderTexts[2], 0, (c.iH/2.0 - b)); // South
    }
    if (borderTexts[3]!=null) {
      text(borderTexts[3], (-c.iW/2.0 + b), 0); // West
    }
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
    String[] borderTexts = {"North", "East", "South", "West"};
    Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING);
    for (int i=0; i<rows; i++) {
      //String row = spec[i];
      for (int j=0; j<cols; j++) {
        Cell cl = g.cells[i][j];
        cl.dObject = new TextTile("FOO", borderTexts, gParams, gParams);
      }
    }
    return g;
  }
}