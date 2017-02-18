

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
    float dY =  - b/4.0;
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
    } else {
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
  final int DEFAULT_SIZE = 20; // was 13;
  final int GRID_PADDING =20;// 10;

  final String TITLE_STYLE = "TITLE";
  final String TITLE_FONT = "AR DARLING"; // WAS DEFAULT_FONT;
  final int TITLE_SIZE = 60;
  final color TITLE_COLOR = color(0, 51, 204); // WAS color(0); //color(255, 0, 0);

  final String H1_STYLE = "H1";
  final String H1_FONT = DEFAULT_FONT;
  final int H1_SIZE = 15;
  final color H1_COLOR = color(0); //color(128, 128, 255);

  final String NORMAL_STYLE = "NORMAL";
  final String NORMAL_FONT = "Segoe";
  final int NORMAL_SIZE = 12;
  final color NORMAL_COLOR = color(0);

  GraphicsParams gParams;
  TextRenderer texter; 
  Table activityStats;
  final String ACTIVITY  = "Activity";
  final String CLAN = "Clan";
  final String GUILD = "Guild";
  final String SEQUENCE = "Sequence";

  public TextTableHelper() {

    activityStats = new Table();
    initActivityStats();
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

  void initActivityStats() {
    activityStats.addColumn(ACTIVITY);
    activityStats.addColumn(CLAN);
    activityStats.addColumn(GUILD);
    activityStats.addColumn(SEQUENCE);
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
  Grid generateAnswersGrid(int clanNo, int guildNo) {
    String[][]puzzles = generateGuildPuzzles(guildNo);
    String[] heading = {"No.", "PUZZLE NAME", "YOUR SOLUTION"};
    String[][] tableData = new String[puzzles.length+1][3]; // 3: (#, name, solution)
    tableData[0] = heading;
    for (int i=0; i<puzzles.length; i++) {
      tableData[i+1][0] = puzzles[i][0];
      tableData[i+1][1] = ">>" + puzzles[i][1];
    }
    //public Grid createGrid(int rows, int cols, String[][]text, int originX, int originY, int dX, int dY) {
    final int DX = 200;
    final int DY = 25;
    int rows = tableData.length;
    int cols = tableData[0].length;
    Grid g= createGrid(rows, cols, tableData, DX, DY, 0.1);
    return g;
  }



  // questNames: {"Quest 1", "Quest 3", ...}
  // Returns a nested grid.
  Grid generateStickerGrid(int clanNo, int guildNo) {
    String[][] questNames = generateGuildQuests(clanNo, guildNo);
    Grid pg = new Grid(1, 2, width, height/4.5, GRID_PADDING); // Two cols, 1 row.
    pg.adjustColWidth(0, 1.0/3);
    // Insert quests...
    Grid qg = createNestedGrid(pg, 0, 0, 2, 2, questNames); // Max 2x2 grid of quests.
    //initGrid(qg, questNames);    
    Cell cl = pg.cells[0][1]; // the challenges section
    cl.dObject = new TextTile(cl, "^^Challenge Stickers", null, gParams, gParams);

    return pg;
  }

  // activities: {"Quest 1", "Furnature Factory", "Perspectives 2", ...}
  Grid generateTicketsGrid(int clanNo, int guildNo) {
    String[][]tickets = generateGuildTickets(clanNo, guildNo);
    final int DX = 150;
    final int DY = 60;
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


  // TODO: hardcoded for now.
  String generateTitle(int clanNo, int guildNo) {
    return g_clanNames[clanNo-1] + " Clan Guild " + guildNo + " Tally Sheet";
    //return "Orca Clan Guild 1 Tally Sheet";
  }
  // guildNo: One-based guild number
  String[][] generateGuildPuzzles(int guildNo) {
    int numPuzzles = g_puzzleData.length;
    assert(guildNo>0 && guildNo<= NUM_GUILDS);
    assert(numPuzzles%NUM_GUILDS == 0); 
    // We pick out every (NUM_GUILDS+guildNo-1) puzzle - these are the 
    // puzzles for guild guidNo, ASSUMING that they are numbered exactly that way.
    ArrayList<Object> list = new ArrayList<Object> ();
    for (int i=0; i<g_puzzleData.length; i+= NUM_GUILDS) {
      int index = i+guildNo-1;
      assert(index<g_puzzleData.length);
      list.add(g_puzzleData[index]);
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
    String[] activities = generateActivitiesV2(clanNo, guildNo);
    //String[][] quests = {{"Quest 1", "Quest 3"}, {"Quest 5"}};
    String[][] quests = new String[2][2];
    // Tack on " sticker" to each string.
    int index=0;
    for (String[] row : quests) {
      for (int i=0; i<row.length; i++) {
        // Find next activity that is a quest...
        while (index<activities.length && activities[index].indexOf("Quest")!=0) {
          index++;
        }
        if (index==activities.length) {
          // We're done here..
          return quests; // *********** EARLY RETURN **********
        }
        row[i] = "^^" + activities[index] + " sticker";
        index++;
      }
    }
    return quests;
  }

  // Generate the tickets that this (clanNo, guildNo) will participate in.
  // These must be in the form of a 2D array.
  String[][] generateGuildTickets(int clanNo, int guildNo) {
    String[] activities = generateActivitiesV2(clanNo, guildNo); 
    updateActivityStats( clanNo, guildNo, activities);
    String[][] cellText = new String[activities.length][2]; 
    for (int i=0; i<cellText.length; i++) {
      char letter = (char)('a'+i);
      String a = activities[i];
      cellText[i][1] = "<< "+letter + ") " + a;
      cellText[i][0] = "<<"+a.toUpperCase()+"\n" + g_clanNames[clanNo-1] + "-" + guildNo + " ticket";
    }
    return cellText;
  }

  String[] generateActivitiesOld(int clanNo, int guildNo) {
    final int NUM_ACTIVITIES = 8;
    assert(clanNo>0 && clanNo<= NUM_CLANS);
    assert(guildNo>0 && guildNo<= NUM_GUILDS);
    //final int PERIOD = NUM_GUILDS*NUM_CLANS;
    int startOffset = (clanNo-1)*NUM_GUILDS + guildNo;
    // For now - just return  a hardcoded set of quest names...
    //String[] activities = {"Quest 1", "Furnature Factory", "Perspectives 3"};
    String[] activities = new String[NUM_ACTIVITIES];
    for (int i=0; i<activities.length; i++) {
      activities[i] = g_activityNames[(startOffset+i*(NUM_GUILDS+2))%g_activityNames.length];
    }
    return activities;
  }

  String[] generateActivitiesV2(int clanNo, int guildNo) {
    ArrayList<String> list = new ArrayList<String>();
    final int NUM_QUESTS = 4;
    final int NUM_CHALLENGES = 3;
    final int NUM_PERSPECTIVES = 1;
    final int NUM_TOTAL = NUM_QUESTS+NUM_CHALLENGES+NUM_PERSPECTIVES;
    int curQuests = 0;
    int curChallenges = 0;
    int curPerspectives = 0;
    String[][] allNames = {g_questNames, g_challengeNames, g_perspectiveNames};
    int[] limits = {4, 3, 1};
    int[] counts = {0, 0, 0};
    int startList = (NUM_GUILDS*(clanNo-1)+(guildNo-1)) % allNames.length; // Round robin start list.
    while (counts[0]+counts[1]+counts[2]<NUM_TOTAL) {
      for (int i=0; i<allNames.length; i++) {
        int curIndex = (startList+i) % allNames.length;
        String[] curNames = allNames[curIndex];
        int curCount  =counts[curIndex];
        int curLimit = limits[curIndex];
        if (curCount<curLimit) {
          addActivities(clanNo, guildNo, curNames, curCount, list);
          counts[curIndex]++;
        }
      }
    }
    return list.toArray(new String[list.size()]);
  }

  void addActivities(int clanNo, int guildNo, String[]allActivities, int activityCount, ArrayList<String>cumulativeList) {

    assert(clanNo>0 && clanNo<= NUM_CLANS);
    assert(guildNo>0 && guildNo<= NUM_GUILDS);
    assert(activityCount>=0);
    //We want to be sure that offset spans the range of possible combinations without any holes.
    // Otherwise we will not be fair to specific activities (we saw this when we were simply
    // ERROR - activity count must be NOT multiplied - that will increment by one.
    // So need to get the max activity count and multiply it.
    int offset = (guildNo-1) + (clanNo-1)*NUM_GUILDS +  NUM_GUILDS*NUM_CLANS*activityCount;
    cumulativeList.add(allActivities[offset % allActivities.length]);
  }

  void updateActivityStats(int clanNo, int guildNo, String[] activities) {
    verifyActivities(clanNo, guildNo, activities);
    for (int i=1; i<=activities.length; i++) {
      TableRow newRow = activityStats.addRow();
      newRow.setString(ACTIVITY, activities[i-1]);
      newRow.setString(CLAN, g_clanNames[clanNo-1]);
      newRow.setInt(GUILD, guildNo);
      newRow.setInt(SEQUENCE, i);
    }
  }

  void verifyActivities(int clanNo, int guildNo, String[] activities) {
    verifyActivity(clanNo, guildNo, activities, g_questNames, 4);
    verifyActivity(clanNo, guildNo, activities, g_perspectiveNames, 1);
    verifyActivity(clanNo, guildNo, activities, g_challengeNames, 3);
  }

  void verifyActivity(int clanNo, int guildNo, String[] activities, String[]allList, int expectedCount) {
    int[] counts = new int[allList.length];
    int myCount = 0;
    for (String name : activities) {
      for (int i=0; i<allList.length; i++) {
        if (name.equals(allList[i])) {
          counts[i]++;
          myCount++;
        }
      }
    }
    if (expectedCount!=myCount) {
      println("expectedCount: " + expectedCount + " myCount: " + myCount);
      assert(false);
    }
    for (int i=0; i<counts.length; i++) {
      assert(counts[i]<2);
    }
  }



  void saveActivityStats(String fileName) {
    saveTable(activityStats, fileName);
  }
  void renderTallySheet(int clanNo, int guildNo) {
    int curY = 0;
    String title = generateTitle(clanNo, guildNo);
    background(255);
    texter.moveTo(MARGIN_WIDTH, MARGIN_WIDTH, width-2*MARGIN_WIDTH, height-2*MARGIN_WIDTH);
    // Title:
    texter.renderText(title, TITLE_STYLE);
    texter.renderText("<<Puzzle Answers", H1_STYLE);
    curY = texter.moveDownBy(0);
    Grid puzzleGrid = generateAnswersGrid(clanNo, guildNo);
    Grid stickerGrid  = generateStickerGrid(clanNo, guildNo);
    Grid ticketGrid  = generateTicketsGrid( clanNo, guildNo);

    //puzzleGrid = null;
    //stickerGrid = null;
    //ticketGrid = null;

    if (puzzleGrid!=null) {
      puzzleGrid.moveBy(0, curY);
      puzzleGrid.horizontallyCenter();
      puzzleGrid.draw();
      curY = puzzleGrid.bottomY();
    }
    texter.moveDownTo(curY+2*H1_SIZE);
    texter.renderText("<<Sticker Grid", H1_STYLE);
    texter.renderText("<<Place each QUEST sticker you have earned in its correct position in the grid to receive credit.\n" +
      "Place all CHALLENGE stickers in the Challenge stickers area.", NORMAL_STYLE);

    curY = texter.moveDownBy(0);

    if (stickerGrid!=null) {
      stickerGrid.moveBy(0, curY);
      stickerGrid.horizontallyCenter();
      stickerGrid.draw();
      curY = stickerGrid.bottomY();
    }

    texter.moveDownTo(curY+2*H1_SIZE);
    texter.renderText("<<Activity Tickets", H1_STYLE);
    texter.renderText("<<Attempt each of these activities one by one, IN ORDER - left to right.\n" +
      "Tear off a ticket and TWO of your teammates take this ticket to the challenge area.", NORMAL_STYLE);

    curY = texter.moveDownBy(0);

    pushMatrix();
    translate(0, curY);
    rotate(radians(-90));
    translate(-ticketGrid.gridWidth, MARGIN_WIDTH);
    ticketGrid.draw();
    popMatrix();
  }

  // Returns a grid, including header.
  // puzzles: 2D array - 1st col is PuzzleID and 2nd col is puzzle name:
  // {{"886", "Foo bar"},...}
  Grid generateGUAScoresheet(String[]puzzlesData) {
    String[] heading = {"NÚMERO", "SU SOLUCIÓN", "VERIFICACIÓN"};
    String[][] tableData = new String[puzzlesData.length+1][3]; // 3: (#, name, solution)
    tableData[0] = heading;
    for (int i=0; i<puzzlesData.length; i++) {
      tableData[i+1][0] = puzzlesData[i];
    }
    //public Grid createGrid(int rows, int cols, String[][]text, int originX, int originY, int dX, int dY) {
    final int DX = 200;
    final int DY = 100;
    int rows = tableData.length;
    int cols = tableData[0].length;
    Grid g= createGrid(rows, cols, tableData, DX, DY, 0.2);
    return g;
  }

  void renderGAUScoreSheet(String[] puzzleIDs) {
    int curY = 0;
    background(255);
    texter.moveTo(MARGIN_WIDTH, MARGIN_WIDTH, width-2*MARGIN_WIDTH, height-2*MARGIN_WIDTH);
    curY = texter.moveDownBy(100);

    // Title:
    //String title = "ROMPECABEZAS DE TINFA";
    String title = "Rompecabezas de TINFA";
    texter.renderText(title, TITLE_STYLE);
    //texter.renderText("<<Puzzle Answers", H1_STYLE);
    curY = texter.moveDownBy(200);
    Grid puzzleGrid = generateGUAScoresheet(puzzleIDs);

    if (puzzleGrid!=null) {
      puzzleGrid.moveBy(0, curY);
      puzzleGrid.horizontallyCenter();
      puzzleGrid.draw();
      curY = puzzleGrid.bottomY();
    }
  }
}