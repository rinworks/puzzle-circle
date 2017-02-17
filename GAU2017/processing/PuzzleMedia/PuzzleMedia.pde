// Module: PuzzleMedia  - entrypoint
// History:
//  Feb 2017  - JMJ created.
public static final int DISPLAY_HEIGHT = 1300;
public static final int DISPLAY_WIDTH = 1300;
public static final int DEFAULT_BACKGROUND = 150;
public static final int WHITE_BACKGROUND = 255;
public static final int LIGHT_GRAY_BACKGROUND = 220;
public CommonUtils gUtils = new CommonUtils();
public GraphicsUtils gGrUtils = new GraphicsUtils();

public MasterSolutionList gSolutions = null; // initialized in setup
// Just set display height and width here.
// No processing methods other than setting up the display are permitted here.
void settings() {
  size(DISPLAY_WIDTH, DISPLAY_HEIGHT);
}

void setup() {
  noLoop();
  gSolutions = new MasterSolutionList("data/puzzle-phrases.csv", "ES Hint");
  generateAllPuzzleMedia();
}

void generateAllPuzzleMedia() {
  ClocksMain clocks = new ClocksMain();
  clocks.genAllMedia();
  
  BricksMain bricks = new BricksMain();
  bricks.genAllMedia();
  
  CountCellsMain ccells = new CountCellsMain();
  ccells.genAllMedia();

  LasersMain lasers = new LasersMain();
  lasers.genAllMedia();

  println("***ALL PUZZLES FOR ALL TYPES GENERATED!***");
}