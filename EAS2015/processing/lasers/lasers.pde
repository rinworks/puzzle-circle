import java.util.Comparator; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
import java.util.Arrays;

void setup() {
  size(750, 1080);


  // ;==v and :==/
  String[] positionsGood = {
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

  String[] positions = {
    ".....////....", 
    ".../.....:...", 
    ".Y...>..Z ....", 
    ".....;>..:::.", 
    "..>/E:.. ....", 
    "./.:../...:I.", 
    "..>./...J....", 
    "...T.../...<.", 
    "...P...OD....", 
    "...:....:..<.", 
    "...U../X^....", 
    ".^//.::..//<.", 
    ".>./.N..:^...", 
    "..:.:..<:./..", 
    "....^.^..X...", 
    "............."
  };


  // Grid coordinates: (i, j) are like rows of an array/matrix. So i is vertical,
  // with increasing i going downwards.
  // Angles: normal interpration (0 == going right; 90== going up, etc.)

  int[] laserIds = {11, 5, 7, 13, 6, 14, 10, 8, 12, 15, 3, 9, 1, 2, 4};

  //Grid g = genObjects(positions, laserIds);
  String puzzleText = "JUNE EXPIDITION";
  Grid g = createDotGrid(13, 16); 
  addToGrid(g, puzzleText);
  //randomlyBackUpLasers(g);
  for (int i=0; i<10; i++) {
    randomlyBackUpLasers(g);
    addRandomMirrors(g);
  }
  drawPaths(g, puzzleText);
  g.draw();
  //println(PFont.list());
  printGrid(g);
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
        println("Laser " + laserIds[laserCount] + " at ["+i+","+j+"]");
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
    println("Found laser " + l.id + " at (" + c.i + "," + c.j + ")");
    ArrayList<Cell> path = computeLaserPath(g, c);
    markPath(path);
    String s = i<expectedText.length() ? expectedText.substring(i, i+1) : "";
    drawLaserPath(g, path, s);
    //break;
    i++;
  }
  highlightUnvisitedObjects(g);
}

// Set exactly those cells that are touched by
// beams to "visited" status.
void markAllPaths(Grid g) {
  g.clearVisited();
  Cell[] laserCells = getLasers(g);
  int i = 0;
  for (Cell c : laserCells) {
    Laser l = laserFromCell(c);
    ArrayList<Cell> path = computeLaserPath(g, c);
    markPath(path);
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

ArrayList<Cell> computeLaserPath(Grid g, Cell c) {
  ArrayList<Cell> path = new ArrayList<Cell>();
  path.add(c);
  growLaserPath(g, path);
  return path;
}

// Set all path cells visited field to true.
void markPath(ArrayList<Cell> path) {
  for (Cell c : path) {
    if (c!=null) {
      c.visited = true;
    }
  }
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

void growLaserPath(Grid g, ArrayList<Cell> path) {
  println("Entering growLaserPath. #elements: " + path.size());
  int len = path.size();
  if (len==0) {
    return;
  }
  Cell cLast = path.get(len-1);
  Cell cNext = null;
  float orientation;
  if (len == 1) {
    // We're just starting out...
    assert(cLast.dObject instanceof Laser);//, "ERROR - starting out with a NON laser");
    Laser l = laserFromCell(cLast);
    orientation = cLast.orientation;
    println("Starting with laser " + l.id);
  } else {
    // We have at least two items in the path. We only get here if
    // the last item is a mirror.
    Cell cPrev = path.get(len-2);
    assert(cLast.dObject instanceof TwowayMirror); //, "ERROR - last item path is NOT a mirror.");
    float prevOrientation = getCurrentBeamOrientation(cPrev, cLast);
    orientation = getNextBeamOrientation(prevOrientation, cLast.orientation);
  }
  cNext = findNextTarget(g, cLast, orientation);
  path.add(cNext); // cNext can be null.
  if (cNext!= null && cNext.dObject instanceof TwowayMirror) {
    // we hit a mirror, so we can keep going...
    println("RECURSIVE CALL to growLaserPath");
    growLaserPath(g, path);
  }
}

// Find the next target the laser would hit, starting from Cell c and going in direction specified by
// orientation (in degrees). Return a boundary Dot cell if you hit a boundary. Return null if
// Cell c is already at the boundary and the laser is leaving the boundary.
Cell findNextTarget(Grid g, Cell c, float orientation) {
  int k = (round(orientation/90.0)+4)%4 ; // 0(right), 1(up), 2(right), 3(down)
  int di=0, dj=0;
  switch (k) {
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
    // If it's null of a Dot, we keep going...
    if (!(cNext.dObject instanceof Dot)) {
      println("Hit object at [" + cNext.i + "," + cNext.j + "]");
      break;
    }
    i += di;
    j += dj;
  }
  return cNext;
}

// Assuming a beam with orientation prevOrientation hits the mirror,
// compute the new orientation
float getNextBeamOrientation(float prevOrientation, float mirrorOrientation)
{
  int prev = round((prevOrientation+360)/90.0) % 4; // 0=right 1=up 2=left 3=down
  assert(prev>=0 && prev<4);
  int mO = round(mirrorOrientation); // should be either 45 or -45 - this is the NORMAL of the mirror, NOT the plane of the mirror.
  int[] m45 = {-90, 180, 90, 0}; // If it was 0 (going right) it would now be -90 (going down), etc.
  int[] mMinus45 = {90, 0, -90, 180}; // If it was 0 (going right) it will now be 90 (going up), etc.
  if (mO == 45) {
    return m45[prev];
  } else {
    assert(mO==-45);
    return mMinus45[prev];
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
    laserColor = color(255, 153, 0); // orange
    weight = 10;
  }


  stroke(laserColor);
  strokeWeight(weight);
  Cell cFinal = null;
  for (Cell c : path) {
    if (cPrev!=null && c!=null) {
      line(cPrev.center.x, cPrev.center.y, c.center.x, c.center.y);
    }
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

void printGrid(Grid g) {
  String[] spec = specFromGrid(g);
  int[] ids = getLaserIds(g);
  println("String[] spec = {");
  for (int i=0; i<spec.length; i++) {
    println("   \"" + spec[i] + "\"" + ((i<spec.length-1)?",":""));
  }
  println("};");

  print("int[] ids = {");
  for (int i=0; i<ids.length; i++) {
    print(ids[i] + ((i<ids.length-1)?", ":""));
  }
  println("};");
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
Cell pickRandomTopViableCellForTextBox(Grid g, ArrayList<Cell> candidateCells, ArrayList<Integer> candidateScores) { //<>//
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
        return c; // ******** EARLY RETURN ********** //<>//
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
          if (cj.dObject == null || cj.dObject instanceof Dot) {
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
      Cell c = getCellIfAvailable(g, i, j); //<>//
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



// Add a laser that targets the specified text cell. Return true if the laser was //<>//
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
      ArrayList<Cell> path = computeLaserPath(g, newC);
      markPath(path);
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
    // 45-degree (normal) mirror adds -90, -45-degree mirror adds 90 (including changing 180 into (180+90)=270=-90.
    float mirrorOrientation = (random(1.0)<0.5) ? 45.0 : -45.0;
    float reverseOrientation = c.orientation+180.0;
    float newReverseOrientation = getNextBeamOrientation(reverseOrientation, mirrorOrientation);
    float newLaserOrientation = (newReverseOrientation+180);
    int reverseDirection = cardinalDirection(newReverseOrientation);

    /*
    int laserDirection = cardinalDirection(c.orientation);
     int newLaserDirection = (laserDirection + ((mirrorOrientation==45) ? 3 : 1))%4; // note that 3 == -1 mod 4.
     float newLaserOrientation = orientationFromCardinalDirection(newLaserDirection);
     int reverseDirection = (newLaserDirection+2)%4;
     */




    Cell newC = randomlyPickBackedupLaserCell(g, c, reverseDirection);
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
      TwowayMirror m = new TwowayMirror(gParams, gParams);
      dTemp = m;
      orientationTemp = mirrorOrientation;

      c.dObject = dTemp;
      c.orientation = orientationTemp;

      // Re-do the path - it will backwards-extend
      // the existing path
      ArrayList<Cell> path = computeLaserPath(g, newC);
      markPath(path);
    }
  }
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
  println("randomly backing up laser " + ((Laser) cLaser.dObject).id + "in direction " + direction + "di:" + dI + " dj:"+ dJ);

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
  return newC;
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
    swapCells(lasers, i, j);
  }
  return lasers;
}

void swapCells(Cell[] cells, int i, int j) {
  Cell c = cells[i];
  cells[i] =  cells[j];
  cells[j] = c;
}