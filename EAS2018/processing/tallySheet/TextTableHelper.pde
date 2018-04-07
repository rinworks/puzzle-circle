

// TODO:
// - Verify activity assignments:
//      - Same activity not assigned to same (clan, guild)
//      - Report counts of each activity per clan.
//      - Report counts of each activity per activity sequence#.
//      - Altogether: report Activity, Clan, Guild, Sequence in a table.
// - Increase normal text size.
// 2. 
// Represents and renders one tile.
class TextTile implements  Drawable {

  String centerText;
  String[] borderTexts;
  Cell cl;
  int borderTextSize; // This one is not in graphicsParams so we keep it here.
  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  TextTile(Cell cl, String centerText, String[] borderTexts, GraphicsParams params, GraphicsParams hilightedParams) {
    this.cl = cl;
    this.centerText = centerText; 
    this.borderTexts = borderTexts;
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
    this.borderTextSize = 20;
  }

  void draw() { 
    GraphicsParams params = (cl.state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    float b=20;
    pushMatrix();
    translate(cl.center.x, cl.center.y);
    rotate(radians(-cl.orientation));
    gUtils.setShapeParams(params);
    rectMode(CENTER);
    if (params.borderType == LineType.DOTTED) {
      gUtils.dottedRect(0, 0, cl.eW, cl.eH, 10);
    } else if (params.borderType == LineType.SOLID) {
      rect(0, 0, cl.eW, cl.eH);
    }
    if (centerText!=null) {
      drawMainText(params);
    }

    //textSize(borderTextSize); // setTextParams earlier set text size to graphicsParams.textSize
    gUtils.setSmallTextParams(params); // Style for the border text...

    if (borderTexts!=null) {
      if (borderTexts[0]!=null) { 
        text(borderTexts[0], 0, (-cl.iH/2.0 + 0.5*b)); // North
      }
      if (borderTexts[1]!=null) {
        gUtils.pushTransform((cl.iW/2.0 - 0.5*b), 0, -90);
        text(borderTexts[1], 0, 0); // East
        gUtils.popTransform();
      }
      if (borderTexts[2]!=null) {
        text(borderTexts[2], 0, (cl.iH/2.0 - 0.75*b)); // South
      }
      if (borderTexts[3]!=null) {
        gUtils.pushTransform((-cl.iW/2.0 + 0.75*b), 0, -90);
        text(borderTexts[3], 0, 0); // West
        gUtils.popTransform();
      }
    }
    popMatrix();
  }

  // Draw this.centerText, but honor the in-line formatting:
  // ^^ means up.
  // >> means right justified.
  // Expects current center to be at center of cell.
  void drawMainText(GraphicsParams params) {
    String text = centerText;
    float b=0;
    float dX = 0.0;
    float dY =  params.textSize > 0 ? params.textSize/2 : 2;
    gUtils.setTextParams(params);

    if (centerText.indexOf("^^")==0) {
      // Push to top of cell...
      dY = b/2-cl.iH/2;
      textAlign(CENTER);
      text = centerText.substring(2);
    } else if (centerText.indexOf(">>") == 0) {
      // Push to rilign(RIGHT);
      dX = cl.iW/2;
      textAlign(RIGHT);
      text = centerText.substring(2);
    } else if (centerText.indexOf("<<") == 0) {
      // Push to rilign(RIGHT);
      dX = -cl.iW/2;
      textAlign(LEFT);
      text = centerText.substring(2);
    }  else if (centerText.indexOf("<^") == 0) {
      // Push to left-top
      dY = b/2-cl.iH/2;
      dX = -cl.iW/2;
      textAlign(LEFT);
      text = centerText.substring(2);
    }else {
      textAlign(CENTER);
    }
    text(text, dX, dY);
  }
}



// Utility methods specific to tile world
// For tile world
class TextTableHelper {

  final int NUM_GUILDS = 5;
  final int NUM_CLANS = 5;

  final int MARGIN_WIDTH = 20; // Width of margins around printable areas.
  final String DEFAULT_FONT = "Segoe WP Black";
  final String SMALL_FONT = "Segoe UI Light Italic";
  final int DEFAULT_SIZE = 14;
  final int GRID_PADDING =20;// 10;

  final String TITLE_STYLE = "TITLE";
  final String TITLE_FONT = DEFAULT_FONT;
  final int TITLE_SIZE = 20;
  final color TITLE_COLOR = color(0); //color(255, 0, 0);

  final String H1_STYLE = "H1";
  final String H1_FONT = DEFAULT_FONT;
  final int H1_SIZE = 18;
  final color H1_COLOR = color(0); //color(128, 128, 255);

  final String NORMAL_STYLE = "NORMAL";
  final String NORMAL_FONT = "Segoe";
  final int NORMAL_SIZE = 13;
  final color NORMAL_COLOR = color(0);

  GraphicsParams gParams;
  TextRenderer texter; 
  final String ACTIVITY  = "Activity";
  final String CLAN = "Clan";
  final String GUILD = "Guild";
  final String SEQUENCE = "Sequence";
  final DataOrganizer dataOrg;

  public TextTableHelper(DataOrganizer dataOrg) {
    this.dataOrg = dataOrg;
    texter = new TextRenderer(new Point(MARGIN_WIDTH, MARGIN_WIDTH), width-2*MARGIN_WIDTH, height-2*MARGIN_WIDTH);
    texter.addStyle(TITLE_STYLE, TITLE_FONT, TITLE_SIZE, TITLE_COLOR);
    texter.addStyle(H1_STYLE, H1_FONT, H1_SIZE, H1_COLOR);
    texter.addStyle(NORMAL_STYLE, NORMAL_FONT, NORMAL_SIZE, NORMAL_COLOR);
    // Set look of the textboxes
    gParams = new GraphicsParams();
    gParams.font = createFont(DEFAULT_FONT, DEFAULT_SIZE); // null means don't set
    gParams.smallFont = createFont(SMALL_FONT, DEFAULT_SIZE); // null means don't set
    gParams.textColor = 0;
    gParams.backgroundFill = 255;
    gParams.borderColor =  0;
    gParams.borderWeight = 1;
  }

  // Greate a grid nested within Grid pg - located at cell(i,j).
  public Grid createNestedGrid(Grid pg, int i, int j, int rows, int cols, String[][]text) {
    Cell cl = pg.cells[i][j];
    Grid g = new Grid(cl, rows, cols, GRID_PADDING);
    initGrid(g, text);
    cl.dObject = g;
    return g;
  }


  // text - go in the center of each tile.
  public Grid createGrid(int rows, int cols, String[][]text, int dX, int dY) {
    int GRID_WIDTH = cols*dX;
    int GRID_HEIGHT = rows*dY;
    Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING);
    initGrid(g, text);
    return g;
  }

  // Enhanced version - this one adjusts col0 fraction.
  public Grid createGrid(int rows, int cols, String[][]text, int dX, int dY, float col0Frac) {
    int GRID_WIDTH = cols*dX;
    int GRID_HEIGHT = rows*dY;
    Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING);
    g.adjustColWidth(0, col0Frac);
    initGrid(g, text);
    return g;
  }

  void initGrid(Grid g, String[][]text) {
    int rows = g.rows;
    int cols = g.cols;
    for (int i=0; i<rows; i++) {
      String[]textRow = text!=null && text.length>i ? text[i] : null;
      for (int j=0; j<cols; j++) {
        String label = textRow!=null && textRow.length>j ? textRow[j] : null;
        if (label==null) {
          //println("Label null at (" + i + "," + j + ")");
          //println("textRow: "+textRow);
          //println("textRow.length:" + textRow.length);
          //println("textRow[j]:" + textRow[j]);
        }
        Cell cl = g.cells[i][j];
        cl.dObject = new TextTile(cl, label, null, gParams, gParams);
      }
    }
  }

  // Override the graphics param of all cells in the specified col to the supplied params.
  void setColGraphicsParams(Grid g, int col, GraphicsParams params) {
    int rows = g.rows;
    int cols = g.cols;
    assert(col<cols);
    for (int i=0; i<rows; i++) {
      Cell cl = g.cells[i][col];
      if (cl.dObject instanceof TextTile) {
        TextTile tile = (TextTile) cl.dObject;
        tile.graphicsParams = params;
      }
    }
  }


  // Override the graphics param of all cells in the specified col to the supplied params.
  void setRowGraphicsParams(Grid g, int row, GraphicsParams params) {
    int rows = g.rows;
    int cols = g.cols;
    Cell[] cellRow = g.cells[row];
    assert(row<rows);
    for (int j=0; j<cols; j++) {
      Cell cl = cellRow[j];
      if (cl.dObject instanceof TextTile) {
        TextTile tile = (TextTile) cl.dObject;
        tile.graphicsParams = params;
      }
    }
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

  // Returns a grid, including header.
  // puzzles: 2D array - 1st col is PuzzleID and 2nd col is puzzle name:
  // {{"886", "Foo bar"},...}
  Grid generateAnswersGrid(int guildNo) {
    String[][]puzzles = this.dataOrg.generateGuildAnswerRowInfo(guildNo);
    String[] heading = {"No.", "NAME", "YOUR SOLUTION"};
    String[][] tableData = new String[puzzles.length+1][3]; // 3: (#, name, solution)
    tableData[0] = heading;
    for (int i=0; i<puzzles.length; i++) {
      tableData[i+1][0] = puzzles[i][0];
      tableData[i+1][1] = ">>" + puzzles[i][1];
    }
    //public Grid createGrid(int rows, int cols, String[][]text, int originX, int originY, int dX, int dY) {
    final int DX = 250;
    final int DY = 25;
    int rows = tableData.length;
    int cols = tableData[0].length;
    Grid g= createGrid(rows, cols, tableData, DX, DY, 0.1);
    return g;
  }

 

  Grid generateTicketsGrid(int clanNo, int guildNo) {
    String[][]tickets = this.dataOrg.generateGuildTickets(clanNo, guildNo);
    final int DX = 200;
    final int DY = 70;
    int rows = tickets.length;
    int cols = tickets[0].length;
    assert(cols==2);
    Grid g= createGrid(rows, cols, tickets, DX, DY);
    // Now go through and fix up the cell borders.
    GraphicsParams noBorderParams = new GraphicsParams(gParams);
    noBorderParams.borderWeight(0);
    setColGraphicsParams(g, 1, noBorderParams);
    GraphicsParams dashedBorderParams = new GraphicsParams(gParams);
    dashedBorderParams.borderType(LineType.DOTTED);
    setColGraphicsParams(g, 0, dashedBorderParams);
    return g;
  }

  void renderGlobalText(String text, int size, color c, int y) {
    textAlign(CENTER);
    fill(c);
    textSize(size);
    text(text, width/2, y);
  }



  String generateTitle(int clanNo, int guildNo) {
    return g_clanNames[clanNo-1] + " Clan, " + g_guildNames[guildNo-1] + " Guild Tally Sheet";
  }
  


  void renderTallySheet(int clanNo, int guildNo) {
    int curY = 0;
    String title = generateTitle(clanNo, guildNo);
    background(255);
    texter.moveTo(MARGIN_WIDTH, MARGIN_WIDTH, width-2*MARGIN_WIDTH, height-2*MARGIN_WIDTH);
    // Title:
    texter.renderText(title, TITLE_STYLE);
    texter.renderText("<<Answers", H1_STYLE);
    curY = texter.moveDownBy(0);
    Grid puzzleGrid = generateAnswersGrid(guildNo);
    Grid ticketGrid  = generateTicketsGrid( clanNo, guildNo);
    
    if (puzzleGrid!=null) {
      puzzleGrid.moveBy(0, curY);
      puzzleGrid.horizontallyCenter();
      puzzleGrid.draw();
      curY = puzzleGrid.bottomY();
    }
    texter.moveDownTo(curY+H1_SIZE);
    curY = texter.moveDownBy(0);
    texter.moveDownTo(curY+2*H1_SIZE);
    texter.renderText("<<Challenge Tickets", H1_STYLE);
    texter.renderText("<<Attempt one challenge at a time, IN ORDER - left to right.\n" +
      "Tear off a ticket and TWO of your teammates take this ticket to the challenge area.", NORMAL_STYLE);

    curY = texter.moveDownBy(0);

    pushMatrix();
    translate(0, curY);
    rotate(radians(-90));
    translate(-ticketGrid.gridWidth, MARGIN_WIDTH);
    ticketGrid.draw();
    popMatrix();
  }
}