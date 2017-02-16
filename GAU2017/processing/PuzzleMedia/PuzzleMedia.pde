// Module: PuzzleMedia  - entrypoint
// History:
//  Feb 2017  - JMJ created.
public static final int DISPLAY_HEIGHT = 1300;
public static final int DISPLAY_WIDTH = 1300;
public static final int DEFAULT_BACKGROUND = 150;
public CommonUtils gUtils = new CommonUtils();
public MasterSolutionList gSolutions = null; // initialized in setup
// Just set display height and width here.
// No processing methods other than setting up the display are permitted here.
void settings() {
  size(DISPLAY_WIDTH, DISPLAY_HEIGHT);
}

void setup() {
  noLoop();
  gSolutions = new MasterSolutionList("data/solution-table.csv", "ES Hint");
  generateAllPuzzleMedia();
}

void generateAllPuzzleMedia() {
  ClocksMain clocks = new ClocksMain();
  clocks.genAllMedia();
  
  BricksMain bricks = new BricksMain();
  bricks.genAllMedia();
}