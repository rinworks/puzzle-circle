import java.util.Comparator; //<>// //<>// //<>// //<>// //<>// //<>//
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
    ".....>.......", 
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
    "....^.^......", 
    "............."
  };


  // Grid coordinates: (i, j) are like rows of an array/matrix. So i is vertical,
  // with increasing i going downwards.
  // Angles: normal interpration (0 == going right; 90== going up, etc.)

  int[] laserIds = {11, 5, 7, 13, 6, 14, 10, 8, 12, 15, 3, 9, 1, 2, 4};

  Grid g = genObjects(positions, laserIds);
  drawPaths(g, "JUNE EXPEDITION");
  g.draw();
  //println(PFont.list());
}

Grid genObjects(String[] spec, int[] laserIds) {
  GraphicsParams params = new GraphicsParams();
  params.textColor = 0;
  params.backgroundFill = 255;
  GraphicsParams laserParams = new GraphicsParams();
  laserParams.textColor = 255;
  laserParams.backgroundFill = color(255, 0, 0);
  laserParams.borderColor = -1;
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
        d = new Dot(params, params);
      } else if (c=='<'||c=='>'||c=='^'||c==';') {
        d = new Laser(laserIds[laserCount], laserParams, laserParams);
        println("Laser " + laserIds[laserCount] + " at ["+i+","+j+"]");
        laserCount++;
      } else if  (c=='|'||c=='-'||c=='/'||c==':') {
        d = new TwowayMirror(params, params);
      } else {
        d = new TextBox(""+c, params, params);
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
String drawPaths(Grid g, String expectedText) {
  Cell[] laserCells = findLasers(g);
  int i = 0;
  for (Cell c : laserCells) {
    Laser l = laserFromCell(c);
    println("Found laser " + l.id + " at (" + c.i + "," + c.j + ")");
    ArrayList<Cell> path = new ArrayList<Cell>();
    path.add(c);
    growLaserPath(g, path);
    String s = i<expectedText.length() ? expectedText.substring(i, i+1) : "";
    drawLaserPath(g, path, s);
    //break;
    i++;
  }
  return "";
}

// Return all cells with lasers, in order of
// increasing laserIds.
Cell[] findLasers(Grid g) {
  ArrayList<Cell> list = new ArrayList<Cell>();
  for (int i=0; i<g.rows; i++) {
    for (int j=0; j<g.cols; j++) {
      Cell c = g.cells[i][j];
      //Drawable
      if (c.dObject instanceof Laser) {
        list.add(c);
      }
    }
  }  
  Comparator<Cell> comp 
    = new Comparator<Cell>() {
    public int compare(Cell c1, Cell c2) {
      return laserFromCell(c1).id-laserFromCell(c2).id;
    }
  };
  Cell[] ret = list.toArray(new Cell[list.size()]);
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
    if (cNext!=null && !(cNext.dObject instanceof Dot)) {
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
  for (int i=0; i<rows; i++) {
    String row = "";
    for (int j=0; j<cols; j++) {
      Cell c = g.cells[i][j];
      Drawable d = (c!=null) ? c.dObject : null;
      if (d==null) continue;
      int orientation = round(c.orientation);
      if (d instanceof Dot) {
        row = ".";
      } else if (d instanceof Laser) {
        char[] laserChars = {'>', '^', '<', ';'}; // right, up, left, down
        int i = ((orientation+360)/90)%4; // 0, 1, 2, 3
        assert(i>0 && i<4);
        row += laserChars[i];
      } else if (d instanceof TwowayMirror) {
        if (orientation == 45) {
          row += ":";
        } else {
          assert(orientation == -45);
          row += "/";
        } else if (d instance TextBox) {
          char c = ' ';
          TextBox tb = (TextBox) d;
          if (d.label!=null && d.label.length==1) {
            c = d.label.charAt(1);
          }
          row += c;
        }
      }
    }
    spec[i] = row;
  }
  return spec;
}

  // Return the IDs of lasers in the order that they are
  // visited when doing a rowmajor traversal of the grid.
  int[] laserIdsFromGrid(Grid g) {
  }