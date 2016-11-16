
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
    gUtils.dottedRect(0, 0, cl.eW, cl.eH, 10);
    gUtils.setTextParams(params);
    if (centerText!=null) {
      drawMainText();
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
  void drawMainText() {
    String text = centerText;
    float b=20;
    float dX = 0.0;
    float dY =  - b/4.0;
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
    } else {
      textAlign(CENTER);
    }
    text(text, dX, dY);
  }
}



// Utility methods specific to tile world
// For tile world
class TextTableHelper {

  GraphicsParams gParams;
  final String DEFAULT_FONT = "Segoe WP Black";
  final String SMALL_FONT = "Segoe UI Light Italic";
  final int GRID_PADDING =20;// 10;

  public TextTableHelper() {


    // Set look of the textboxes
    gParams = new GraphicsParams();
    gParams.font = createFont(DEFAULT_FONT, 20); // null means don't set
    gParams.smallFont = createFont(SMALL_FONT, 20); // null means don't set
    gParams.textColor = 0;
    gParams.backgroundFill = 255;
    gParams.borderColor =  128;
    gParams.borderWeight = 3;
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
  public Grid createGrid(int rows, int cols, String[][]text, int originX, int originY, int dX, int dY) {
    int GRID_WIDTH = cols*dX;
    int GRID_HEIGHT = rows*dY;
    Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING, originX, originY);
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
  Grid generateAnswersGrid(Point origin, int guildNo) {
    String[][]puzzles = generateGuildPuzzles(guildNo);
    String[] heading = {"No.", "PUZZLE NAME", "YOUR SOLUTION"};
    String[][] tableData = new String[puzzles.length+1][3]; // 3: (#, name, solution)
    tableData[0] = heading;
    for (int i=0; i<puzzles.length; i++) {
      tableData[i+1][0] = puzzles[i][0];
      tableData[i+1][1] = puzzles[i][1];
    }
    //public Grid createGrid(int rows, int cols, String[][]text, int originX, int originY, int dX, int dY) {
    final int DX = 300;
    final int DY = 50;
    int rows = tableData.length;
    int cols = tableData[0].length;
    Grid g= createGrid(rows, cols, tableData, (int)origin.x, (int)origin.y, DX, DY);
    return g;
  }

  // questNames: {"Quest 1", "Quest 3", ...}
  // Returns a nested grid.
  Grid generateStickerGrid(Point origin, int clanNo, int guildNo) {
    String[][] questNames = generateGuildQuests(clanNo, guildNo);
    Grid pg = new Grid(1, 2, width/2, height/2, GRID_PADDING, origin.x, origin.y); // Two cols, 1 row.
    // Insert quests...
    Grid qg = createNestedGrid(pg, 0, 0, 2, 2, questNames); // Max 2x2 grid of quests.
    //initGrid(qg, questNames);    
    Cell cl = pg.cells[0][1]; // the challenges section
    cl.dObject = new TextTile(cl, "^^Challenge Stickers", null, gParams, gParams);

    return pg;
  }

  // activities: {"Quest 1", "Furnature Factory", "Perspectives 2", ...}
  Grid generateTicketsGrid(Point origin, int clanNo, int guildNo) {
    String[][]tickets = generateGuildTickets(clanNo, guildNo);
    final int DX = 300;
    final int DY = 100;
    int rows = tickets.length;
    int cols = tickets[0].length;
    Grid g= createGrid(rows, cols, tickets, (int)origin.x, (int)origin.y, DX, DY);
    return g;
  }

  void renderTallySheet(Grid puzzleGrid, Grid stickerGrid, Grid ticketGrid) {
    if (puzzleGrid!=null) {
      puzzleGrid.horizontallyCenter();
      puzzleGrid.draw();
    }
    if (stickerGrid!=null) {
      stickerGrid.moveBy(0, puzzleGrid.gridHeight);
      stickerGrid.horizontallyCenter();
      stickerGrid.draw();
    }
    pushMatrix();
    rotate(radians(-90));
    translate(-600,0);
    if (ticketGrid!=null) ticketGrid.draw();
    popMatrix();
  }

  // guildNo: One-based guild number
  String[][] generateGuildPuzzles(int guildNo) {
    final int NUM_GUILDS = 5;
    int numPuzzles = g_puzzleData.length;
    assert(guildNo>0 && guildNo<= NUM_GUILDS);
    assert(numPuzzles%NUM_GUILDS == 0); 
    // We pick out every (NUM_GUILDS+guildNo-1) puzzle - these are the 
    // puzzles for guild guidNo, ASSUMING that they are numbered exactly that way.
    ArrayList<Object> list = new ArrayList<Object>();
    for (int i=0; i<g_puzzleData.length; i+= NUM_GUILDS) {
      int index = i+guildNo-1;
      assert(index<g_puzzleData.length);
      list.add(g_puzzleData[i]);
    }
    String[][] puzzles = new String[list.size()][2]; // For puzzle ID and  name
    int i = 0;
    for (Object obj : list) {
      String[]puzzle = (String[])obj;
      assert(puzzle.length>=2);
      puzzles[i][0] = puzzle[0]; // ID
      puzzles[i][1] = puzzle[1]; // Name
      i++;
    }
    assert(i==puzzles.length);
    return puzzles;
  }

  // Generate the quests that this (clanNo, guildNo) will participate in.
  // These must be in the form of a 2D array.
  String[][] generateGuildQuests(int clanNo, int guildNo) {
    // For now - just return a hardcoded set of quest names...
    String[][] quests = {
      {"Quest 1", "Quest 3"}, 
      {"Quest 5"}
    };

    // Tack on " sticker" to each string.
    for (String[] row : quests) {
      for (int i=0; i<row.length; i++) {
        row[i] = "^^" + row[i] + " sticker";
      }
    }
    return quests;
  }

  // Generate the tickets that this (clanNo, guildNo) will participate in.
  // These must be in the form of a 2D array.
  String[][] generateGuildTickets(int clanNo, int guildNo) {
    // For now - just return a hardcoded set of quest names...
    String[] activities = {
      "Quest 1", "Furnature Factory", "Perspectives 3"
      //{"Quest 1", "Quest 1\nBears-1 ticket"}, 
      //{"Quest 5"}
    };
    String[][] cellText = new String[activities.length][2]; 
    for (int i=0; i<cellText.length; i++) {
      char letter = (char)('a'+i);
      String a = activities[i];
      cellText[i][1] = "<<   "+letter + ") " + a;
      cellText[i][0] = "<<"+a.toUpperCase()+"\nBears-1 ticket";
    }
    return cellText;
  }
}