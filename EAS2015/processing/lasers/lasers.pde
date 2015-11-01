import java.util.Comparator; //<>// //<>// //<>// //<>// //<>//
import java.util.Arrays;

void setup() {
  //size(770, 1100);
  size(1300, 1300);

  if (true) {
    runTest();
    return;
  }
  // ;==v and :==/
  String[] positions = {
    ".............", 
    ".../.....:...", 
    ".....>...::..", 
    ".....;>..:::.", 
    "..>/E:.. ....", 
    "./.:......:I.", 
    "..>./...J....", 
    "...T.../...<.", 
    "...P...OD....", 
    "...:....:..<.", 
    "...U../X^....", 
    ".^//.::..//<.", 
    ".>./.N..:^...", 
    "..:.:..<:./..", 
    "....^.^......", 
    "............."
  };

  // Grid coordinates: (i, j) are like rows of an array/matrix. So i is vertical,
  // with increasing i going downwards.
  // Angles: normal interpration (0 == going right; 90== going up, etc.)
  boolean synthPuzzles = true;
  String puzzleText = "JUNE EXPEDITION";
  Grid g;

  if (!synthPuzzles) {
    int[] laserIds = {11, 5, 7, 13, 6, 14, 10, 8, 12, 15, 3, 9, 1, 2, 4};

    g = genObjects(positions, laserIds);
  } else {
    puzzleText = "HOW PLANTS USE SUNLIGHT";
    g = generateGoodPuzzle(25, 25, puzzleText, 10000);
  }
  drawPaths(g, puzzleText);
  g.draw();
  //println(PFont.list());
  printGrid(g, null);
  LaserHelper lh = new LaserHelper(g);
  PuzzleStats pStats = lh.computePuzzleStats();
  println("Puzzle Stats:");
  println(pStats);
}

GraphicsParams gParams = new GraphicsParams();
GraphicsParams gLaserParams = new GraphicsParams();

Grid genObjects(String[] spec, int[] laserIds) {
  String DEFAULT_FONT = "Segoe WP Black";
  gParams.font = createFont(DEFAULT_FONT, 7); // null means don't set
  gParams.textColor = 0;
  gParams.backgroundFill = 255;

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
      } else if (c=='<'||c=='>'||c=='^'||c==';') {
        d = new Laser(laserIds[laserCount], gLaserParams, gLaserParams);
        //println("Laser " + laserIds[laserCount] + " at ["+i+","+j+"]");
        laserCount++;
      } else if  (c=='|'||c=='-'||c=='/'||c==':') {
        d = new TwowayMirror(gParams, gParams);
      } else {
        d = new TextBox(""+c, gParams, gParams);
      }

      if (c=='<') {
        orientation = 180; // left facing
      } else if (c=='^'||c=='-') {
        orientation = 90; // upwards facing
      } else if (c==';') {
        orientation = -90; // downwards facing
      } else if (c=='/') {
        orientation = -45;
      } else if (c==':') { // equivalent to backslash
        orientation = 45;
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
  lh.tracePath(c, cardinalDirection(c.orientation), path, null, mark);
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



// Find the next target the laser would hit, starting from Cell c and going in direction specified by
// orientation (in degrees). Return a boundary Dot cell if you hit a boundary. Return null if
// Cell c is already at the boundary and the laser is leaving the boundary.
// We use dotCount just to pass-by-reference the count of dots back. A bit of a hack.
// NOTE: cStart is the start of the path - it is to detect cycles in the path, which
// can happen.
Cell findNextTarget(Grid g, Cell cStart, Cell c, int direction, ArrayList<TraceCellInfo>dotInfoList, int[]dotCount, Boolean mark) {
  assert(direction>=0 && direction<4);
  if (dotCount!=null) {
    assert( dotCount.length==1);
    dotCount[0]=0; // int count of dots.
  }
  int di=0, dj=0;
  switch (direction) {
  case 0:  // right
    dj=1;
    break;
  case 1:  // up
    di=-1;
    break;
  case 2:  // left
    dj=-1;
    break;
  case 3:  // down
    di=1;
    break;
  default: // shouldn't get here.
    assert(false);
    break;
  }
  Cell cNext = null;
  int i=c.i + di;
  int j=c.j + dj;
  while (i>=0 && j>=0 && i<g.rows && j<g.cols) {
    cNext = g.cells[i][j];
    if (cNext == cStart) {
      // Oops, we've encountered a cycle!
      //println("CYCLE DETECTED AT " + locationToString(cNext)); // *************** EARLY RETURN **************
      dotCount[0] = 0;
      return null;
    }
    Boolean visited = cNext.visited;
    if (!visited && mark) {
      cNext.visited=true;
    }
    // If it's null or a Dot, we keep going...
    if (cNext.dObject instanceof Dot) {
      if (dotInfoList!=null) {
        dotInfoList.add(new TraceCellInfo(cNext, direction));
      }
      if (!visited &&/* BOO !visited && */dotCount!=null) {
        dotCount[0]+=1;
      }
    } else {
      //println("Hit object at " + locationToString(cNext));
      break;
    }
    i += di;
    j += dj;
  }
  return cNext;
}

// Assuming a beam with orientation prevOrientation hits the mirror,
// compute the new orientation
int getNextBeamDirection(int direction, float mirrorOrientation)
{
  assert(direction>=0 && direction<4);
  int mO = round(mirrorOrientation); // should be either 45 or -45 - this is the NORMAL of the mirror, NOT the plane of the mirror.
  int[] m45 = {3, 2, 1, 0}; // If it was 0 (going right) it would now be -90 (going down), etc.
  int[] mMinus45 = {1, 0, 3, 2}; // If it was 0 (going right) it will now be 90 (going up), etc.
  if (mO == 45) {
    return m45[direction];
  } else {
    assert(mO==-45);
    return mMinus45[direction];
  }
}

// Compute the beam orientation for a beam coming
// from cPrev and hitting Cell c.
// Return value is in degrees.
float getCurrentBeamOrientation(Cell cPrev, Cell c) {
  // We assume direction is only in the cardinal directions for now.
  float ret = 0; 
  if (cPrev.j<c.j) {
    ret = 0.0; // increasing j is leftwards
  } else if (cPrev.j>c.j) {
    ret =   180.0;
  } else if (cPrev.i<c.i) {
    ret =  -90; // increasing i is downwards
  } else if (cPrev.i>c.i) {
    ret = 90;
  } else {
    assert(false); // The cells are identifical - beam orientation is undefined. We shoudl never get here.
  }
  return ret;
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
        char[] laserChars = {'>', '^', '<', ';'}; // right, up, left, down
        int k = ((orientation+360)/90)%4; // 0, 1, 2, 3
        assert(k>=0 && k<4);
        row += laserChars[k];
      } else if (d instanceof TwowayMirror) {
        if (orientation == 45) {
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

int[] getLaserIds (Grid g) {
  Cell[] cells = getLasers(g);
  int[] ids = new int[cells.length];
  for (int i=0; i<cells.length; i++) {
    ids[i] = ((Laser) cells[i].dObject).id;
  }
  return ids;
}

void printGrid(Grid g, String path) {
  String[] spec = specFromGrid(g);
  int[] ids = getLaserIds(g);
  String output = "";
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
      // We wan't to skip diagonals and center!
      if ((di+dj) % 2 != 0) {
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
  }
  return score;
}

Cell placeNewTextBox(Grid g, String s) {
  // We just find the first available one (for now)
  // TODO: pick a random one from the top two scorers.
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



// Add a laser that targets the specified text cell. Return true if the laser was
// successfully added. The location is assumed to be a viable location
// to add a laser (there is a spot for the laser)
// TODO: pick a spot randomly among available spots.
Boolean addLaserToTarget(Grid g, Cell textCell, int laserId) {
  int i, j;
  Cell c;
  ArrayList<Cell> candidateCells = new ArrayList<Cell>();
  ArrayList<Integer> candidateOrientations = new ArrayList<Integer>();

  // Check top...
  i = textCell.i-1;
  j = textCell.j;
  c = getCellIfAvailable(g, i, j);
  if (c!=null) {
    candidateCells.add(c);
    candidateOrientations.add(-90); // pointing down.
  }

  // Check bottom
  i = textCell.i+1;
  j = textCell.j;
  c = getCellIfAvailable(g, i, j);
  if (c!=null) {
    candidateCells.add(c);
    candidateOrientations.add(90); // pointing up.
  }

  // Check left
  i = textCell.i;
  j = textCell.j-1;
  c = getCellIfAvailable(g, i, j);
  if (c!=null) {
    candidateCells.add(c);
    candidateOrientations.add(0); // pointing left.
  }

  // Check right
  i = textCell.i;
  j = textCell.j+1;
  c = getCellIfAvailable(g, i, j);
  if (c!=null) {
    candidateCells.add(c);
    candidateOrientations.add(180); // pointing right.
  }

  if (candidateCells.size()>0) {
    int chosenIndex = (int) random(0, candidateCells.size());
    Cell chosenCell = candidateCells.get(chosenIndex);
    chosenCell.dObject = new Laser(laserId, gLaserParams, gLaserParams);
    chosenCell.orientation = candidateOrientations.get(chosenIndex);
    return true;
  } else {
    return false;
  }
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
Boolean addToGrid(Grid g, String text) {
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
      ok = addLaserToTarget(g, textCell, startId + i);
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

// Attempt to back up lasers by varying amounts.
// g is assumed to be already in a viable configuration,
// i.e., it solves the puzzle. This transformation
// preserves that.
void randomlyBackUpLasers(Grid g) {
  markAllPaths(g);
  Cell[] lasers  = pickRandomLaserOrder(g);
  for (Cell c : lasers) {
    int direction = cardinalDirection(180+c.orientation); // Get the reverse direction
    Cell newC = randomlyPickBackedupLaserCell(g, c, direction);
    if (newC!=null) {
      // Back up the laser to here by swapping cell content
      Drawable dTemp = newC.dObject;
      float orientationTemp = newC.orientation;
      assert(newC.dObject instanceof Dot);
      assert(newC.visited==false);
      assert(c.dObject instanceof Laser);
      newC.dObject = c.dObject;
      newC.orientation = c.orientation;
      c.dObject = dTemp;
      c.orientation = orientationTemp;

      // Re-do the path - it will backwards-extend
      // the existing path
      computeLaserPath(g, newC, true);
    }
  }
}

// Visit each laser in random order and
// attempt to add a random mirror where the laser was.
// Move the laser by one step (it will be next to the
// mirror that was just added.) The configuration
// is assumed to be viable on entry and it will remain
// vaible on exit.
void addRandomMirrors(Grid g) {
  markAllPaths(g);
  Cell[] lasers  = pickRandomLaserOrder(g);
  for (Cell c : lasers) {
    //Cell cExistingMirror  = backedAgainstMirror(g, c);
    // 45-degree (normal) mirror adds -90, -45-degree mirror adds 90 (including changing 180 into (180+90)=270=-90.
    float mirrorOrientation = (random(1.0)<0.5) ? 45.0 : -45.0;
    float reverseOrientation = c.orientation+180.0;
    int reverseDirection = round((reverseOrientation+360)/90.0) % 4; // 0=right 1=up 2=left 3=down
    int newReverseDirection = getNextBeamDirection(reverseDirection, mirrorOrientation);
    float newLaserOrientation = orientationFromCardinalDirection((newReverseDirection+2)%4); // flip directions


    Cell newC = randomlyPickBackedupLaserCell(g, c, newReverseDirection);
    if (newC!=null) {
      // This means that we CAN backup the laser in the new direction.
      // Let's place the mirror here and move the laser to the proposed
      // backed-up location.
      Drawable dTemp = newC.dObject;
      float orientationTemp = newC.orientation;
      assert(newC.dObject instanceof Dot);
      assert(newC.visited==false);
      assert(c.dObject instanceof Laser);
      newC.dObject = c.dObject;
      newC.orientation = newLaserOrientation;

      // Insert mirror!
      println("Inserting mirror at location " + locationToString(c) + " with orientation " + mirrorOrientation);

      TwowayMirror m = new TwowayMirror(gParams, gParams);
      dTemp = m;
      orientationTemp = mirrorOrientation;

      c.dObject = dTemp;
      c.orientation = orientationTemp;

      // Re-do the path - it will backwards-extend
      // the existing path
      computeLaserPath(g, newC, true);
    }
  }
}

// Check and return mirror if the laser cell is
// backed up against a mirror. Return null otherwise.
Cell backedAgainstMirror(Grid g, Cell laserCell) {
  return null;
}


float orientationFromCardinalDirection(int direction) {
  assert(direction>=0 && direction<4);
  return (direction<3) ? direction * 90.0  : -90.0;
}

// Attempt to backup from cell c in the specified 
// cardinal direction. Return the existing cell at
// this new location if one is found, null otherwise.
// NOTE: orientation MAY NOT be compatible with cLaser - this 
// happens when we are contemplating adding a mirror at the current
// laser's position!
Cell randomlyPickBackedupLaserCell(Grid g, Cell cLaser, int direction) {
  int dI = getRowStep(direction);
  int dJ = getColStep(direction);
  println("randomly backing up laser " + ((Laser) cLaser.dObject).id + " in direction " + direction + "di:" + dI + " dj:"+ dJ);

  ArrayList<Cell> candidateCells = new ArrayList<Cell>();
  ArrayList<Integer> candidateScores = new ArrayList<Integer>();
  candidateCells.add(cLaser);
  candidateScores.add(computeTextBoxViabilityScore(g, cLaser));
  Cell c = cLaser;
  do {
    c = g.tryGetCell(c.i+dI, c.j+dJ);
    if (c!=null && getCellIfAvailable(g, c.i, c.j)!=null) {
      // found a candidate slot.
      candidateCells.add(c);
      candidateScores.add(computeTextBoxViabilityScore(g, c));
    }
  } while (c!=null && (c.dObject==null || c.dObject instanceof Dot));

  Cell newC =  pickRandomTopViableCellForTextBox(g, candidateCells, candidateScores); // could be nothing there
  // If we picked ourself, we return null - indicating we didn't pick any *backed up* cell.
  if (newC == cLaser) {
    newC = null;
  }
  if (newC!=null) {
    println("   Backed from location " + locationToString(cLaser) + " to location " + locationToString(newC));
  } else {
  }
  return newC;
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

// convert orientation in degrees to a number from 1-4
// representing the cardinal directions.
// 0=E(right), 1=N(up), 2=W(left), 3=S(down)
// orientation is assumed to be one of these directions.
int cardinalDirection(float orientation) {
  assert(orientation>=-360.0);
  return (round(orientation)+360)/90 % 4;
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
        int dirI = cardinalDirection(lcI.orientation);
        int dirJ = cardinalDirection(lcJ.orientation);
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
  addToGrid(g, puzzleText);
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

void  runTest() {

String[] spec = {
   ">...:....../:..;/..:/...:",
   "/.........../..:.:/.::/<.",
   "./...:./.:/...:+.:../:.:.",
   "../.....:....3:.../...:/.",
   "...=...:........:.....:<.",
   ":.../.............:/...:.",
   ">....:../...../...././...",
   "//./.:.../..:..:.........",
   "././...:.........:.......",
   "^....:..../..../.....A...",
   "/...:......:..........:/.",
   "....^5........:.:....:...",
   ".:........./:.././.......",
   "./...:.......0:...//../..",
   "....B./........:..:...:..",
   "....:..........:.:.......",
   "..:...:......./:.../.....",
   "../..//.////.2...:../....",
   ".......:...../....:.:....",
   "...:././....:.......:.../",
   ".../.........../....:...:",
   ".:....:///:..........//6/",
   ":../..:.:...../:../1:..:.",
   "/./.....:.../^..:../.:..:",
   "^......:.............../^"
};
int[] ids = {5, 9, 6, 7, 8, 4, 3, 2, 1, 10};



  String puzzleText = "3A+2B=1650";
  Grid g = genObjects(spec, ids);
  background(200);
  g.draw();
  save("output\\ouput-noPaths.png");
  background(200);
  //drawLaserPath(g, 1, "a"); // To draw a specific path for the answer doc.
  drawPaths(g, puzzleText);
  g.draw();
  save("output\\ouput-withPaths.png");
  printGrid(g, sketchPath("output\\output-spec.txt"));
}