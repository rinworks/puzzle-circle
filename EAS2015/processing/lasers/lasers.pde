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
  Grid g = createDotGrid(10, 10); 
  addToGrid(g, puzzleText);
  //gdrawPaths(g, puzzleText);
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


// Draw the laser paths and return a string containing
// any letters hit, in order of laserIds.
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
    c.visited = true;
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
  for (int i=0; i<g.rows; i++) {
    for (int j=0; j<g.cols; j++) {
      Cell c = g.cells[i][j];
      if (c.dObject!=null && c.dObject instanceof TextBox) {
        if (((TextBox)c.dObject).label.equals(s)) {
          int score = computeTextBoxViabilityScore(g, c);
          if (score>0) {
            candidateCells.add(c);
          }
        }
      }
    }
  }

  return pickRandomTopViableCellForTextBox(g, candidateCells);
}

// Given a list of candidate cells (all of which are assumed to be viable
// pick a random one amongst the very top scorers
Cell pickRandomTopViableCellForTextBox(Grid g, ArrayList<Cell> candidateCells) {
  int[] scores = new int[candidateCells.size()];
  int maxScore = 0;

  // initialize scores array and find the max score
  int i=0;
  for (Cell c : candidateCells) {
    scores[i] = computeTextBoxViabilityScore(g, c);
    if (scores[i]>maxScore) {
      maxScore = scores[i];
    }
    i++;
  }

  // A score of 0 implies nothing is viable
  if (maxScore==0) {
    return null;
  }

  // find count of items with the max score.
  int numAtMax=0;
  for (int score : scores) {
    if (score == maxScore) {
      numAtMax++;
    }
  } //<>//
  assert(numAtMax>0);

  // Now pick one of these (items with max score) at random...
  int chosen = (int) random(0, numAtMax);
  int maxIndex =0;
  i=0;
  for (Cell c : candidateCells) {
    if (scores[i++]==maxScore) {
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
        int i  = c.i + di; //<>//
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
  for (int i=0; i<g.rows; i++) {
    for (int j=0; j<g.cols; j++) {
      Cell c = getCellIfAvailable(g, i, j);
      if (c!=null) {
        int score = computeTextBoxViabilityScore(g, c);
        if (score > 0) {
          candidateCells.add(c);
        }
      }
    }
  }
  Cell chosenCell = pickRandomTopViableCellForTextBox(g, candidateCells);
  if (chosenCell!=null) {
    chosenCell.dObject = new TextBox(s, gParams, gParams);
  }
  return chosenCell;
}



// Add a laser that targets the specified text cell. Return true if the laser was
// successfully added. The location is assumed to be a viable location
// to add a laser (there is a spot for the laser)
// TODO: pick a spot randomly among available spots.
Boolean addLaserToTarget(Grid g, Cell textCell, int laserId) { //<>//
  int i, j;
  float orientation=0.0;
  Cell c;
  Boolean found=false;

  // Check top...
  i = textCell.i-1;
  j = textCell.j;
  c = getCellIfAvailable(g, i, j);
  if (c!=null) {
    found = true;
    orientation = -90; // pointing down.
  }

  if (!found) {
    // Check bottom
    i = textCell.i+1;
    j = textCell.j;
    c = getCellIfAvailable(g, i, j); //<>//
    if (c!=null) {
      found = true;
      orientation = 90; // pointing up.
    }
  }

  if (!found) {
    // Check left
    i = textCell.i;
    j = textCell.j-1;
    c = getCellIfAvailable(g, i, j);
    if (c!=null) {
      found = true;
      orientation = 0; // pointing left.
    }
  }

  if (!found) {
    // Check right
    i = textCell.i;
    j = textCell.j+1;
    c = getCellIfAvailable(g, i, j);
    if (c!=null) {
      found = true;
      orientation = 180; // pointing right.
    }
  }

  if (found) {
    c.dObject = new Laser(laserId, gLaserParams, gLaserParams);
    c.orientation = orientation;
  }
  return found;
}

Cell getCellIfAvailable(Grid g, int i, int j) {
  if (i>=0 && i<g.rows && j>=0 && j<g.cols) {
    Cell cj = g.cells[i][j];
    if (cj.dObject == null || cj.dObject instanceof Dot) {
      return cj;
    }
  }
  return null;
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