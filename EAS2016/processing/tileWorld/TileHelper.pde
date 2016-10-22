
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
    float a = 30, b=10;
    pushMatrix();
    translate(c.center.x, c.center.y);
    rotate(radians(-c.orientation));
    gUtils.setShapeParams(params);
    rectMode(CENTER);
    gUtils.dottedRect(0, 0, c.eW, c.eH, 10);
    gUtils.setTextParams(params);
    text(centerText, 0, -b/4.0);
    //textSize(borderTextSize); // setTextParams earlier set text size to graphicsParams.textSize
    gUtils.setSmallTextParams(params); // Style for the border text...
    if (borderTexts[0]!=null) { 
      text(borderTexts[0], 0, (-c.iH/2.0 + b/2)); // North
    }
    if (borderTexts[1]!=null) {
      gUtils.pushTransform((c.iW/2.0 - b/2), 0, -90);
      text(borderTexts[1], 0, 0); // East
      gUtils.popTransform();
    }
    if (borderTexts[2]!=null) {
      text(borderTexts[2], 0, (c.iH/2.0 - b*3/2)); // South
    }
    if (borderTexts[3]!=null) {
      gUtils.pushTransform((-c.iW/2.0 + b*3/2), 0, -90);
      text(borderTexts[3], 0, 0); // West
      gUtils.popTransform();
    }
    popMatrix();
  }
}

// Utility methods specific to tile world
// For tile world
class TileHelper {

  GraphicsParams gParams;
  final String DEFAULT_FONT = "Segoe WP Black";
  final String SMALL_FONT = "Segoe UI Light Italic";

  public TileHelper() {

    // Set look of the textboxes
    gParams = new GraphicsParams();
    gParams.font = createFont(DEFAULT_FONT, 50); // null means don't set
    gParams.smallFont = createFont(SMALL_FONT, 18); // null means don't set
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
        cl.dObject = new TextTile("X", borderTexts, gParams, gParams);
      }
    }
    return g;
  }
}