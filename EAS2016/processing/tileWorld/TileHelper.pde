
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
    float a = 30, b=20;
    pushMatrix();
    translate(c.center.x, c.center.y);
    rotate(radians(-c.orientation));
    gUtils.setShapeParams(params);
    rectMode(CENTER);
    gUtils.dottedRect(0, 0, c.eW, c.eH, 10);
    gUtils.setTextParams(params);
    if (centerText!=null) {
      text(centerText, 0, -b/4.0);
    }
    //textSize(borderTextSize); // setTextParams earlier set text size to graphicsParams.textSize
    gUtils.setSmallTextParams(params); // Style for the border text...
    if (borderTexts[0]!=null) { 
      text(borderTexts[0], 0, (-c.iH/2.0 + 0.5*b)); // North
    }
    if (borderTexts[1]!=null) {
      gUtils.pushTransform((c.iW/2.0 - 0.5*b), 0, -90);
      text(borderTexts[1], 0, 0); // East
      gUtils.popTransform();
    }
    if (borderTexts[2]!=null) {
      text(borderTexts[2], 0, (c.iH/2.0 - 0.75*b)); // South
    }
    if (borderTexts[3]!=null) {
      gUtils.pushTransform((-c.iW/2.0 + 0.75*b), 0, -90);
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
    gParams.smallFont = createFont(SMALL_FONT, 20); // null means don't set
    gParams.textColor = 0;
    gParams.backgroundFill = 255;
    gParams.borderColor =  128;
    gParams.borderWeight = 3;
  }


  // letters - go in the center of each tile.
  // borderText - pairs of related words - used to generate borders.
  // Both are laid out in row-major order.
  // permutation - scrambles the order. If cell i's true position is i, it will be located
  // in permutation[i]. If permutation is [0, 1, 2,... n-1] then there is no scrambling.
  // permutation.length MUST be rows*cols.
  public Grid createGrid(int rows, int cols, String letters, String[] borderText, int[] tilePermutation, int[]borderPermutation) {
    assert(tilePermutation.length == rows*cols);
    assert(borderPermutation.length == borderText.length);
    String[][][] borders = generateBorders(rows, cols, borderText, borderPermutation); // borders - used to the 4 borders  - N, E, S, W.
    int GRID_WIDTH = width;
    int GRID_HEIGHT = height;
    int GRID_PADDING = 10;
    //String[] borderTexts = {"North", "East", "South", "West"};
    Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING);
    String[] letterArray = splitTokens(letters, " ");
    for (int i=0; i<rows; i++) {
      for (int j=0; j<cols; j++) {
        String[] borderTexts = borders[i][j];
        int pos = i*cols + j; // Position on row-major linearization
        String label = null;
        if (pos<letterArray.length) {
          label = letterArray[pos];
        }
        // We look up the *permuted* version of the cell position, which is at (pi, pj)
        int permutedPos = tilePermutation[pos];
        int pi = permutedPos/cols;
        int pj = permutedPos%cols;
        Cell cl = g.cells[pi][pj];
        cl.dObject = new TextTile(label, borderTexts, gParams, gParams);
      }
    }
    return g;
  }

  // Generates borders: 4 borders  - N, E, S, W, for each cell.
  // borderText - pairs of related words 
  String[][][] generateBorders(int rows, int cols, String[] borderText, int[]borderPermutation) {
    assert(borderPermutation.length == borderText.length);
    String[][][] cells = new String[rows][cols][4]; // 4 for North South East West

    /* Test code - unused now - ignores borderText; just injects a self-validating pattern
     for (int i=0; i<rows; i++) {
     for (int j=0; j<cols; j++) {
     String ij = "("+i+","+j+")";
     String[] borders = {"N"+ij, "E"+ij, "S"+ij, "W"+ij};
     cells[i][j] = borders;
     }
     } */

    if (borderText.length==0) {
      // Nothing more to do...
      return cells; // ********************* EARLY RETURN ******************
    }
    int nextBorder = borderText.length-1;
    final int NORTH=0, EAST=1, SOUTH=2, WEST=3;
    for (int i=0; i<rows; i++) {
      for (int j=0; j<cols; j++) {
        // Setup up only East and South borders, but in doing so, also set up
        // the touching borders of the corresponding adjacent cell. Don't do anything
        // if there is no neighboring cell.
        // East border...
        if (j<(cols-1) && nextBorder >=0) { // There is an East neighbor, and there is text left
          String borderPair = borderText[borderPermutation[nextBorder--]];
          String[] pairs = splitTokens(borderPair, " \t");
          String a, b;
          a = (pairs.length>0) ? pairs[0] : null;
          b = (pairs.length>1) ? pairs[1] : null;
          cells[i][j][EAST] = b;
          cells[i][j+1][WEST] = a;
        }
        if (i<(rows-1) && nextBorder >=0) { // There is an South neighbor, and there is text left
          String borderPair = borderText[borderPermutation[nextBorder--]];
          String[] pairs = splitTokens(borderPair, " \t");
          String a, b;
          a = (pairs.length>0) ? pairs[0] : null;
          b = (pairs.length>1) ? pairs[1] : null;
          cells[i][j][SOUTH] = a;
          cells[i+1][j][NORTH] = b;
        }
      }
    }



    return cells;
  }
}