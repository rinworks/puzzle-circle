// //<>// //<>// //<>//
// Module: LASERS.PDE
// Description: Main file for the lasers puzzle generator.
// History:
//	November 2015 - JMJ created
//
// General notes:
//     Grid coordinates: (i, j) are like rows of an array/matrix. So i is vertical,
//     with increasing i going downwards.
//     Angles: normal interpration (0 == going right; 90== going up, etc.)
//
import java.util.Comparator;
import java.util.Arrays;
Boolean SKIP_DIAGONALS = false; // Set to true to generate only horiz/vert laser paths
final  String LASER_CHARS = ">}^{<[;]";
final  String MIRROR_CHARS = "/|:-";
final  String SPECIAL_CHARS = LASER_CHARS + MIRROR_CHARS + '.';
final String ESCAPE_CHARS = ""; //"BDFGHIJLMNOPQRST";


void setup() {
  size(1300, 1300);
  //size(2000, 2000);


  // To recreate a specific puzzle, make a note of the printed seed value and 
  // set seed to that printed seed value (comment out the call to round(random(...))).
  long seed = round(random(MAX_INT));
  println("SEED: " + seed);
  randomSeed(seed);

  // Set runSpecific to true to run a specific, previously-computed puzzle
  Boolean runSpecific = true;
  if (runSpecific) {
    runSpecific();
  } else { 
    String puzzleText = "D=880 & W=A+23";

    Boolean bestOfMany = true; // Whether to generate a bunch of puzzles and pick
    // the best of the based on certain metrics
    Grid g;
    LaserHelper lh;

    // Size of the grid...
    int rows = 25;
    int cols = 25;

    if (bestOfMany) {
      // This code picks the "best" puzzle out of numPuzzles random puzzles
      int numPuzzles = 1000;
      g = generateGoodPuzzle(rows, cols, puzzleText, numPuzzles);  
      lh = new LaserHelper(g);
    } else {
      // Create a random puzzle specified rows and columns, 
      // (and attempt to grow the laser paths
      // up to a growthIterations times). If growthIterations is set to 0,
      // a degenerate (but valid) puzzle is created with all lasers directly
      // next to their target letter.
      int growthIterations=100;
      lh = createRandomPuzzle(rows, cols, puzzleText, growthIterations);
      g = lh.g;
    }

    // Actually draw out the paths taken by all the lasers
    // (comment out to NOT draw paths - the puzzle itself of course does NOT have
    // any paths drawn)
    drawPaths(g, puzzleText);

    // Draw the lasers and the grid (drawn on TOP of the paths so that the labels, etc
    // are shown)
    g.draw();

    // Print out a text representation of the grid. This is actually Java code that defines
    // a couple of arrays - you can cut and paste this code into the runSpecific() method to
    // regenerate exactly that puzzle.
    printGrid(g, null);

    // Compute various "goodness" stats about this puzzle and print it out.
    PuzzleStats pStats = lh.computePuzzleStats();
    println("Puzzle Stats:");
    println(pStats);
  }
}

// Look (chiefly color) of default objects
GraphicsParams gParams = new GraphicsParams();

// Look (chiefly color) of lasers
GraphicsParams gLaserParams = new GraphicsParams();

Grid genObjects(String[] spec, int[] laserIds) {
  String DEFAULT_FONT = "Segoe WP Black";

  // Set look of the textboxes
  gParams.font = createFont(DEFAULT_FONT, 7); // null means don't set
  gParams.textColor = 0;
  gParams.backgroundFill = 255;

  // Set look of the lasers
  gLaserParams.font = createFont(DEFAULT_FONT, 7); // null means don't set
  gLaserParams.textColor = 255;
  gLaserParams.backgroundFill = color(255, 0, 0);
  gLaserParams.borderColor = -1;

  int rows = spec.length;
  int cols = (rows>0)? spec[0].length():0;
  int laserCount = 0;
  int GRID_WIDTH = width;
  int GRID_HEIGHT = height;
  int GRID_PADDING = 10;
  Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING);
  for (int i=0; i<rows; i++) {
    String row = spec[i];
    for (int j=0; j<cols; j++) {
      Drawable d = null;
      float orientation = 0;
      char c = row.charAt(j);
      if (c=='.') {
        d = new Dot(gParams, gParams);
        //} else if (c=='<'||c=='>'||c=='^'||c==';') {
      } else if (LASER_CHARS.indexOf(c)!=-1) {
        d = new Laser(laserIds[laserCount], gLaserParams, gLaserParams);
        //println("Laser " + laserIds[laserCount] + " at ["+i+","+j+"]");
        int k = LASER_CHARS.indexOf(c);
        orientation = 45*k;
        if (orientation>180) {
          orientation = orientation-360; // convert 270 to -90, etc.
        }
        laserCount++;
        //} else if  (c=='|'||c=='-'||c=='/'||c==':') {
      } else if  (MIRROR_CHARS.indexOf(c)!=-1) {
        d = new TwowayMirror(gParams, gParams);
        int k = MIRROR_CHARS.indexOf(c);
        orientation = 45*k-45; // Sequence: -45, 0, 45, 90
      } else {
        c = unescapeChar(c);
        d = new TextBox(""+c, gParams, gParams);
      }

      if (d!=null) {
        Cell cl = g.cells[i][j];
        cl.dObject = d;
        cl.orientation = orientation;
        String cName = cl.getClassName();
        if (cName.equals("Laser")) {
          //println(cl.getClassName() + " at ["+i+","+j+"] orientation "+orientation + cl.center);
        }
      }
    }
  }
  return g;
}


// Draw the laser paths using appropriate styling
// depending on whether there are discrepancies
// with the expected puzzle text.
void drawPaths(Grid g, String expectedText) {
  Cell[] laserCells = getLasersOrderedById(g);
  int i = 0;
  for (Cell c : laserCells) {
    Laser l = laserFromCell(c);
    //println("Found laser " + l.id + " at (" + c.i + "," + c.j + ")");
    ArrayList<Cell> path = computeLaserPath(g, c, true);
    String s = i<expectedText.length() ? expectedText.substring(i, i+1) : "";
    drawLaserPath(g, path, s);
    //break;
    i++;
  }
  highlightUnvisitedObjects(g);
}

// Draw the laser paths for the specific ID using appropriate styling
// depending on whether there are discrepancies
// with the expected puzzle text.
void drawLaserPath(Grid g, int id, String expectedText) {
  Cell[] laserCells = getLasers(g);
  for (Cell c : laserCells) {
    Laser l = laserFromCell(c);
    if (l.id==id) {
      //println("Found laser " + l.id + " at (" + c.i + "," + c.j + ")");
      ArrayList<Cell> path = computeLaserPath(g, c, true);
      drawLaserPath(g, path, expectedText);
      break;
    }
  }
}

// Set exactly those cells that are touched by
// beams to "visited" status.
void markAllPaths(Grid g) {
  g.clearVisited();
  Cell[] laserCells = getLasers(g);
  int i = 0;
  for (Cell c : laserCells) {
    Laser l = laserFromCell(c);
    computeLaserPath(g, c, true);
    i++;
  }
}


// Hilight all non-DOT objects that have not
// been visited
void highlightUnvisitedObjects(Grid g) {
  stroke(0, 0, 255);
  strokeWeight(8);
  noFill();
  for (Cell[] row : g.cells) {
    for (Cell c : row) {
      if (!c.visited && c.dObject != null && !(c.dObject instanceof Dot)) {
        ellipse(c.center.x, c.center.y, c.iW, c.iH);
      }
    }
  }
}

ArrayList<Cell> computeLaserPath(Grid g, Cell c, Boolean mark) {
  ArrayList<Cell> path = new ArrayList<Cell>();
  LaserHelper lh = new LaserHelper(g);
  path.add(c);
  lh.tracePath(c, lh.cardinalDirection(c.orientation), path, null, mark);
  return path;
}

// Return all cells with lasers, in order of
// increasing laserIds.
Cell[] getLasersOrderedById(Grid g) {
  Cell[] ret = getLasers(g);
  Comparator<Cell> comp 
    = new Comparator<Cell>() {
    public int compare(Cell c1, Cell c2) {
      return laserFromCell(c1).id-laserFromCell(c2).id;
    }
  };
  Arrays.sort(ret, comp);
  return ret;
}

Laser laserFromCell(Cell c) {
  return (Laser) c.dObject;
}

String shortClassName(String className) {
  return className.substring(className.indexOf("$")+1); // relise of indexOf returning -1 if not found.
}





void drawLaserPath(Grid g, ArrayList<Cell> path, String expectedText) {
  if (path.size()==0) {
    return;
  }
  Cell cPrev = null;
  //Check what kind of a path to draw -successful or failed.
  Boolean success = false;
  Cell cLast = path.get(path.size()-1); // can be null
  if (cLast != null && cLast.dObject!= null &&  cLast.dObject instanceof TextBox) {
    TextBox tb = (TextBox) cLast.dObject;
    if (tb.label.equals(expectedText)) {
      {
        // We're good!
        success = true;
      }
    }
  }
  int laserColor = color(255, 0, 0);
  int weight = 2;
  if (!success) {
    laserColor = color(255, 153, 0); // orange (comment out to have it a red path)
    weight = 10; // reduce to 4 to be thinner so that it doesn't extend behind the mirror.
  }



  Cell cFinal = null;
  for (Cell c : path) {
    if (cPrev!=null && c!=null) {
      stroke(laserColor);
      strokeWeight(weight);
      line(cPrev.center.x, cPrev.center.y, c.center.x, c.center.y);
    }
    // Draw a white dot if we have NOT visited this cell - we should have!
    /*
    if (!c.visited) {
     fill(255);
     ellipse(c.center.x, c.center.y, c.iW, c.iH);
     } else {
     fill(0);
     ellipse(c.center.x, c.center.y, c.iW, c.iH);
     }
     */
    cPrev = c;
    cFinal = (c==null) ? cFinal : c;
  }

  // We draw a disk at the final destination (or pre-final if the final is null)
  if (!success) {
    assert(cFinal!=null); // there should be at least one non-null cell!
    fill(laserColor);
    ellipseMode(CENTER);
    ellipse(cFinal.center.x, cFinal.center.y, 40, 40);
  }
}


// Return the compact text representation of the grid
String[] specFromGrid(Grid g) {
  String[] spec = new String[g.rows];
  for (int i=0; i<g.rows; i++) {
    String row = "";
    for (int j=0; j<g.cols; j++) {
      Cell c = g.cells[i][j];
      Drawable d = c.dObject;
      if (d==null) continue;
      int orientation = round(c.orientation);
      if (d instanceof Dot) {
        row += ".";
      } else if (d instanceof Laser) {
        char[] laserChars = {'>', '}', '^', '{', '<', '[', ';', ']'}; // right>  NE}  up^  NW{  left<  SW[  down;  SE]
        int k = ((orientation+360)/45)%8; // 0, 1, 2, 3, 4, 5, 6, 7
        assert(k>=0 && k<8);
        row += laserChars[k];
      } else if (d instanceof TwowayMirror) {
        if (orientation == 0) {
          row += "|";
        } else if (orientation == 90) {
          row += "-";
        } else if (orientation == 45) {
          row += ":";
        } else {
          assert(orientation == -45);
          row += "/";
        }
      } else if (d instanceof TextBox) {
        char letter = ' ';
        TextBox tb = (TextBox) d;
        if (tb.label!=null && tb.label.length()==1) {
          letter = tb.label.charAt(0);
          letter = escapeChar(letter);
        }
        row += letter;
      }
    }
    spec[i] = row;
  }
  return spec;
}


// Return the lasers in the order that they are found in the grid
Cell[] getLasers(Grid g) {
  ArrayList<Cell> list = new ArrayList<Cell>();
  for (int i=0; i<g.rows; i++) {
    for (int j=0; j<g.cols; j++) {
      Cell c = g.cells[i][j];
      if (c.dObject instanceof Laser) {
        list.add(c);
      }
    }
  }  
  Cell[] ret = list.toArray(new Cell[list.size()]);
  return ret;
}

// Return the text boxes in the order that they are found in the grid
Cell[] getTextBoxes(Grid g) {
  ArrayList<Cell> list = new ArrayList<Cell>();
  for (int i=0; i<g.rows; i++) {
    for (int j=0; j<g.cols; j++) {
      Cell c = g.cells[i][j];
      if (c.dObject instanceof TextBox) {
        list.add(c);
      }
    }
  }  
  Cell[] ret = list.toArray(new Cell[list.size()]);
  return ret;
}

int[] getLaserIds (Grid g) {
  Cell[] cells = getLasers(g);
  int[] ids = new int[cells.length];
  for (int i=0; i<cells.length; i++) {
    ids[i] = ((Laser) cells[i].dObject).id;
  }
  return ids;
}

String getText (Grid g) {
  Cell[] cells = getTextBoxes(g);
  String text = "";
  for (int i=0; i<cells.length; i++) {
    text += ((TextBox) (cells[i].dObject)).label;
  }
  return text;
}

void printGrid(Grid g, String path) {
  String[] spec = specFromGrid(g);
  int[] ids = getLaserIds(g);
  String output = "";
  String text = getText(g);
  output +="String[] spec = {\n";
  for (int i=0; i<spec.length; i++) {
    output += "   \"" + spec[i] + "\"" + ((i<spec.length-1)?",":"") + "\n";
  }
  output +="};\n";

  output +="int[] ids = {";
  for (int i=0; i<ids.length; i++) {
    output +=(ids[i] + ((i<ids.length-1)?", ":""));
  }
  output +="};\n";

  output +="String textboxText = \""+text+"\"\n";

  if (path==null) {
    print(output);
  } else {
    String[] strings = {output};
    saveStrings(path, strings);
  }
}

// Find an available text box (one that can serve
// as a fresh target) or create and insert a new text 
// box.
Cell newOrExistingTextBox(Grid g, String s) {
  Cell c = findViableExistingTextBox(g, s);
  if (c == null) {
    c = placeNewTextBox(g, s);
  }
  return c;
}

Cell findViableExistingTextBox(Grid g, String s) {
  ArrayList<Cell> candidateCells = new ArrayList<Cell>();
  ArrayList<Integer> candidateScores = new ArrayList<Integer>();
  for (int i=0; i<g.rows; i++) {
    for (int j=0; j<g.cols; j++) {
      Cell c = g.cells[i][j];
      if (c.dObject!=null && c.dObject instanceof TextBox) {
        if (((TextBox)c.dObject).label.equals(s)) {
          int score = computeTextBoxViabilityScore(g, c);
          if (score>0) {
            candidateCells.add(c);
            candidateScores.add(score);
          }
        }
      }
    }
  }

  return pickRandomTopViableCellForTextBox(g, candidateCells, candidateScores);
}

// Given a list of candidate cells (all of which are assumed to be viable)
// pick a random one amongst the very top scorers
Cell pickRandomTopViableCellForTextBox(Grid g, ArrayList<Cell> candidateCells, ArrayList<Integer> candidateScores) {
  int maxScore = 0;

  // Find the max score
  for (int score : candidateScores) {
    if (score>maxScore) {
      maxScore = score;
    }
  }

  // A score of 0 implies nothing is viable
  if (maxScore==0) {
    return null;
  }

  // find count of items with the max score.
  int numAtMax=0;
  for (int score : candidateScores) {
    if (score == maxScore) {
      numAtMax++;
    }
  }
  assert(numAtMax>0);

  // Now pick one of these (items with max score) at random...
  int chosen = (int) random(0, numAtMax);
  int maxIndex =0;
  int i=0;
  for (Cell c : candidateCells) {
    if (candidateScores.get(i++)==maxScore) {
      if (maxIndex==chosen) {
        return c; // ******** EARLY RETURN **********
      }
      maxIndex++;
    }
  }
  assert(candidateCells.size()==0); //Should only get here if there were no candidate cell.s
  return null;
}


// Compute the viability for this (TextBox) cell to be
// the target for a new laser. Positive score means it's viable.
// (increasing is better). Score of 0 means it is not viable.
int computeTextBoxViabilityScore(Grid g, Cell c) {
  int score = 0;
  // We count the number of places a laser can be placed
  // in the immediate neighborhood
  for (int di = -1; di < 2; di++) {
    for (int dj = -1; dj < 2; dj++) {
      // We wan't to skip center!
      if (di==0 && dj==0) {  // OBSOLETE if ((di+dj) % 2 == 0) {
        continue;
      }
      if (SKIP_DIAGONALS && (di+dj) % 2 == 0) {
        //assert(false);
        continue;
      }
      int i  = c.i + di;
      int j = c.j + dj;
      Cell cj = getCellIfAvailable(g, i, j);
      if (cj!=null) {
        // Note: TwowayMirror is added because *potentially* there could be a way further by bouncing
        // off that existing mirror.
        if (cj.dObject == null || cj.dObject instanceof Dot || cj.dObject instanceof TwowayMirror) {
          score++;
        }
      }
    }
  }
  return score;
}

Cell placeNewTextBox(Grid g, String s) {
  // Place the text box by computing viable locations and then picking
  // randomly among the top scorers.
  ArrayList<Cell> candidateCells = new ArrayList<Cell>();
  ArrayList<Integer> candidateScores = new ArrayList<Integer>();
  for (int i=0; i<g.rows; i++) {
    for (int j=0; j<g.cols; j++) {
      Cell c = getCellIfAvailable(g, i, j);
      if (c!=null) {
        int score = computeTextBoxViabilityScore(g, c);
        if (score > 0) {
          candidateCells.add(c);
          candidateScores.add(score);
        }
      }
    }
  }
  Cell chosenCell = pickRandomTopViableCellForTextBox(g, candidateCells, candidateScores);
  if (chosenCell!=null) {
    chosenCell.dObject = new TextBox(s, gParams, gParams);
  }
  return chosenCell;
}

// Return the cell if available to place
// an object without disrupting anything
Cell getCellIfAvailable(Grid g, int i, int j) {

  Cell cj = g.tryGetCell(i, j);
  return (cj !=null && (cj.dObject == null || (cj.dObject instanceof Dot && !cj.visited))) ? cj : null;
}

// Add more lasers so that the supplied text
// is *appended* to the existing answer text.
// Laser Ids start with one more than the max Id
// already in the system, (or 1 if none exists)
Boolean addToGrid(LaserHelper lh, String text) {
  Grid g = lh.g;
  int[] existingIds = getLaserIds(g);
  int prevMax = 0;
  for (int id : existingIds) {
    assert(id!=0);
    if (prevMax < id) {
      prevMax = id;
    }
  }
  int startId = prevMax+1;
  for (int i=0; i<text.length(); i++) {
    String s = "" + text.charAt(i);
    Cell textCell = newOrExistingTextBox(g, s);
    Boolean ok = false;
    if (textCell!=null) {
      ok = lh.addLaserToTarget(textCell, startId + i);
    }
    if (!ok) {
      assert(false);
      return false; // *********** EARLY RETURN
    }
  }
  return true;
}


// Create a gid and fill it with dots.
Grid createDotGrid(int rows, int cols) {
  String[] spec = new String[rows];
  if (rows>0) {
    String dots = "";
    for (int i=0; i<cols; i++) {
      dots += ".";
    }
    for (int i=0; i<rows; i++) {
      spec[i] = dots;
    }
  }
  return genObjects(spec, null);
}


String locationToString(Cell c) {
  return "["+c.i+","+c.j+"]";
}
// How much do we increment the col to take
// one step in the given direction
int getColStep(int direction) {
  assert(direction>=0 && direction<4);
  int[] deltas = {1, 0, -1, 0}; // left, up, right, down
  return deltas[direction];
}

// How much do we increment the row to take
// one step in the given direction
int getRowStep(int direction) {
  assert(direction>=0 && direction<4);
  int[] deltas = {0, -1, 0, 1}; // left, up, right, down
  return deltas[direction];
}


// Return the list of lasers in random order.
Cell[] pickRandomLaserOrder(Grid g) {
  Cell[] lasers = getLasers(g);
  for (int i=0; i<lasers.length; i++) {
    int j = (int) random(i, lasers.length);
    swapCells(lasers, i, min(j, lasers.length-1)); // Sometimes (very rarely) j turns out to be lases.length!
  }
  return lasers;
}

void swapCells(Cell[] cells, int i, int j) {
  Cell c = cells[i];
  cells[i] =  cells[j];
  cells[j] = c;
}

Grid generateGoodPuzzle(int rows, int cols, String puzzleText, int numTrials) {

  PuzzleStats[] puzzleStats = new PuzzleStats[numTrials];
  String[][] puzzleSpecs = new String[numTrials][];
  int[][]laserIds = new int[numTrials][];
  Boolean[] qualifiedPuzzles = new Boolean[numTrials];

  for (int i=0; i<numTrials; i++) {
    LaserHelper lh = createRandomPuzzle(rows, cols, puzzleText, 100);
    qualifiedPuzzles[i] = !disqualifyPuzzle(lh);
    puzzleStats[i] = lh.computePuzzleStats();
    puzzleSpecs[i] = specFromGrid(lh.g);
    laserIds[i] = getLaserIds(lh.g);
    if (lh.hasError) {
      return lh.g; // ******* EARLY RETURN WITH BAD PUZZLE
    }
  }

  // Lets compute the average of the averages (they all have the same weight - number of lasers per puzzle)
  float mirrorCountAvg=0;
  float ssDAvg=0;
  float maxSpanAvg=0;
  for (PuzzleStats ps : puzzleStats) {
    mirrorCountAvg += ps.mirrorCount.avg;
    ssDAvg += ps.ssDistance.avg;
    maxSpanAvg += ps.maxSpan.avg;
  }
  mirrorCountAvg/=puzzleStats.length;
  ssDAvg/=puzzleStats.length;
  maxSpanAvg /= puzzleStats.length;
  println("mcAvg:" + mirrorCountAvg + " ssDAvg:" + ssDAvg + " maxSpanAvg:" + maxSpanAvg);

  // Now let's pick the one puzzle with the max(min/avg value for every stat.

  float bestPrimaryScore = -1;
  for (int i=0; i<puzzleStats.length; i++) {
    if (qualifiedPuzzles[i]) {
      float score = primaryCompositeScore(puzzleStats[i], mirrorCountAvg, ssDAvg, maxSpanAvg);
      if (bestPrimaryScore < score) {
        bestPrimaryScore = score;
      }
    }
  }

  float bestSecondaryScore = -1;
  int bestIndex = -1;
  for (int i=0; i<puzzleStats.length; i++) {
    if (qualifiedPuzzles[i]) {
      float score1 = primaryCompositeScore(puzzleStats[i], mirrorCountAvg, ssDAvg, maxSpanAvg);
      float score2 = secondaryCompositeScore(puzzleStats[i], mirrorCountAvg, ssDAvg, maxSpanAvg);
      if (score1>=bestPrimaryScore && bestSecondaryScore < score2) {
        bestSecondaryScore = score2;
        bestIndex=i;
      }
    }
  }

  println("BEST SCORE: " + bestPrimaryScore +  "-" + bestSecondaryScore);
  Grid bestGrid = genObjects(puzzleSpecs[bestIndex], laserIds[bestIndex]);
  return bestGrid;
}

Boolean disqualifyPuzzle(LaserHelper lh) {
  // Check if any two lasers are back-to-back.
  Cell[] laserCells = getLasers(lh.g);
  for (int i=0; i<laserCells.length; i++) {
    Cell lcI = laserCells[i];
    for (int j=0; j<i; j++) {
      Cell lcJ = laserCells[j];
      if (abs(lcI.i-lcJ.i)+abs(lcI.j-lcJ.j) == 1) { // adjacent
        int dirI = lh.cardinalDirection(lcI.orientation);
        int dirJ = lh.cardinalDirection(lcJ.orientation);
        if ((4+dirI-dirJ)%4==2) {
          // opposite directions
          if ((dirI%2 == 0 && lcI.j!=lcJ.j) || (dirI%2 == 1&&lcI.i!=lcJ.i)) {
            return true;
          }
        }
      }
    }
  }
  return false;
}

// We return the min of the min after normalizing each by dividing by the supplied population average.
float primaryCompositeScore(PuzzleStats ps, float mirrorCountAvg, float ssDAvg, float maxSpanAvg) {
  float min1 = ps.mirrorCount.min/mirrorCountAvg;
  float min2 = ps.ssDistance.min/ssDAvg;
  float min3 = ps.maxSpan.min/maxSpanAvg;
  return min(min1, min2, min3);
  //return min(min2, min3);
}

float secondaryCompositeScore(PuzzleStats ps, float mirrorCountAvg, float ssDAvg, float maxSpanAvg) {
  //float min1 = ps.mirrorCount.min/mirrorCountAvg;
  float min2 = ps.ssDistance.min/ssDAvg;
  float min3 = ps.maxSpan.min/maxSpanAvg;
  //return min(min1, min2, min3);
  return min(min2, min3);
}


LaserHelper createRandomPuzzle(int rows, int cols, String puzzleText, int iterations) {
  Grid g = createDotGrid(rows, cols); 
  LaserHelper lh = new LaserHelper(g);
  addToGrid(lh, puzzleText);
  int prevDotCount=-1;
  int noProgressCount=0;
  int MAX_NO_PROGRESS_COUNT = 10;
  for (int i=0; i<iterations; i++) {
    lh.addToPathComplexity();
    int dotCount = lh.dotCount();
    if (dotCount==prevDotCount) {
      //println("STOPPING AFTER " + i + " ITERATIONS!");
      noProgressCount++;
      if (noProgressCount>MAX_NO_PROGRESS_COUNT) {
        break;
      }
    } else {
      //Had this code to check if we would have made progress - doesn't hit for the current max count we set of 10.
      //if (noProgressCount>MAX_NO_PROGRESS_COUNT) {
      //  println("Hmm, PROGRESS *AFTER* we would have stopped. DC: " + dotCount + " prevDC: " + prevDotCount + " NPCount:" + noProgressCount);
      //}
      //assert(!hitBreak);
      noProgressCount=0;
    }
    prevDotCount = dotCount;
  }
  return lh;
}

// Generate a specific puzzle from its textual description.
// This same description is printed by the call to printGrid().
void  runSpecific() {
String[] spec = {
   "........--.../......:]--[",
   "../........../..[..-.|--|",
   "....-........./....=.||||",
   "/./|-.|---.|...--|//.-|||",
   "..-D|.-|..--.......-...-|",
   ".|-|...-................{",
   ".A....|..|....:.:....-./:",
   "^.-|..-|...-.....0...--..",
   "|.........-....|...3.->./",
   "||..-..|-.....-..../..:.{",
   "|-|+..............:./....",
   "||||...|.W.....|.|.......",
   "||-.....|...-.|-........{",
   "|.|..|....-.-..|.|.:.../.",
   ".|.|.|-./&...|...|...|...",
   "|.|...|..||-....../.../.|",
   "||||-./......<.|.....|...",
   "|.-|-/..:......:....|../:",
   "..-|.......2-.-..|.......",
   "./.../....----......|||..",
   "../.../-../......./---...",
   "/............:-:.....:-..",
   ".... ...:.:8....:......./",
   ":.../--.-.:........../<.{",
   ">/:........../.{...-{:./."
};
int[] ids = {4, 5, 11, 1, 2, 3, 12, 8, 6, 10, 13, 7, 14, 9};
String textboxText = "=DA03+W&2 8";
  Grid g = genObjects(spec, ids);
  background(200);
  g.draw();
  save("output\\ouput-noPaths.png");
  background(200);
  String puzzleText = "1";
  //drawLaserPath(g, 1, "a"); // Uncomment to draw a specific path for the answer doc.
  drawPaths(g, puzzleText);
  g.draw();
  save("output\\ouput-withPaths.png");
  printGrid(g, sketchPath("output\\output-spec.txt"));
  //printGrid(g, null); // To print to console
}

char escapeChar(char c) {
  int i = SPECIAL_CHARS.indexOf(c);
  return (i==-1) ? c : ESCAPE_CHARS.charAt(i);
}

char unescapeChar(char c) {
  int i = ESCAPE_CHARS.indexOf(c);
  return (i==-1) ? c : SPECIAL_CHARS.charAt(i);
}