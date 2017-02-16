// Module: LasersHelper - underlying (core) code to generate Lasers puzzle media
// History:
//  Feb 2017  - JMJ created, adapted from earlier code I wrote for EAS and Puzzle Safari puzzles
// Keep track of a single cell in a chain
// of cells visited in a laser beam trace.


class TraceCellInfo {
  public final Cell c;
  public final int direction;
  public int viabilityScore=0; // used to track suitability of cell for (re)placement of objects.
  public TraceCellInfo(Cell c, int direction) {
    this.c = c;
    this.direction=direction;
  }
}


class Stats {

  public int n;
  public int min;
  public int max;
  public float avg;
  public float sd;

  public String toString() {
    return "N:" + n + " min:" + min + " max:" + max + " avg:" + avg + " sd: " + sd;
  }
}


class PuzzleStats {
  public Stats mirrorCount; // Number of mirrors in path.
  public Stats ssDistance;  // Manhattan distance between source and sink.
  public Stats maxSpan; // Max distance between adjacent mirrors.

  public String toString() {
    return "  mirrorCount:" + mirrorCount + "\n   ssDist:" + ssDistance + "\n  maxSpan:" + maxSpan + "\n";
  }
}


class Laser implements  Drawable {
  final int LASER_WIDTH = 15;
  int id;
  String label;
  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  Laser(int id, GraphicsParams params, GraphicsParams hilightedParams) {
    this.label = "L"+id;
    this.id = id;
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }


  void draw(Cell c) {
    float x = c.center.x;
    float y = c.center.y;
    float orientation = c.orientation;
    ShapeState state = c.state;
    GraphicsParams params = (state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    int a = (int)(2*LASER_WIDTH), b=LASER_WIDTH;
    int aDelta = 0;
    pushMatrix();
    translate(x, y);
    rotate(radians(-orientation));
    gGrUtils.setShapeParams(params);
    beginShape();
    vertex(-a, -b);
    vertex(-a, b);
    vertex(2*a/3, b);
    vertex(a, 0);
    vertex(2*a/3, -b);
    vertex(-a, -b);
    endShape();
    gGrUtils.setTextParams(params);
    // Don't have upside-down text
    if (abs(orientation % 360)>90) {
      rotate(radians(180));
      aDelta = a/5;
    }
    text(label, aDelta-a/10, -4*b/10);
    popMatrix();
  }
}


class Dot implements  Drawable {
  public final int DOT_DIA = 3;
  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  Dot(GraphicsParams params, GraphicsParams hilightedParams) {
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }


  void draw(Cell c) {
    float x = c.center.x;
    float y = c.center.y;
    ShapeState state = c.state;
    GraphicsParams params = (state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    noStroke();
    fill(params.borderColor);
    ellipseMode(CENTER);
    ellipse(x, y, DOT_DIA, DOT_DIA);
  }
}


class TextBox implements  Drawable {
  public final int TEXTBOX_HEIGHT = 40;
  String label;
  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;


  TextBox(String label, GraphicsParams params, GraphicsParams hilightedParams) {
    this.label = label;
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }


  void draw(Cell c) {
    float x = c.center.x;
    float y = c.center.y;
    float orientation = c.orientation;
    ShapeState state = c.state;
    GraphicsParams params = (state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    int a = 30, b=10;
    pushMatrix();
    translate(x, y);
    rotate(radians(-orientation));
    gGrUtils.setShapeParams(params);
    rectMode(CENTER);
    rect(0, 0, TEXTBOX_HEIGHT, TEXTBOX_HEIGHT);
    gGrUtils.setTextParams(params);
    text(label, 0, -b/4.0);
    popMatrix();
  }
}


class TwowayMirror implements  Drawable {
  public final int MIRROR_WIDTH = 50;
  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;


  TwowayMirror(GraphicsParams params, GraphicsParams hilightedParams) {
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }


  void draw(Cell c) {
    float x = c.center.x;
    float y = c.center.y;
    float orientation = c.orientation;
    ShapeState state = c.state;
    GraphicsParams params = (state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    gGrUtils.pushTransform(x, y, orientation);
    //gUtils.setShapeParams(params);
    noStroke();
    fill(params.borderColor);
    rectMode(CENTER);
    rect(0, 0, 5, MIRROR_WIDTH); // A vertical mirror - corresponding to it's NORMAL having an orientation of0
    gGrUtils.popTransform();
  }
}


class LaserHelper {
  final  String LASER_CHARS = ">}^{<[;]";
  final  String MIRROR_CHARS = "/|:-";
  final  String SPECIAL_CHARS = LASER_CHARS + MIRROR_CHARS + '.';
  final String ESCAPE_CHARS = ""; //"BDFGHIJLMNOPQRST";

  final String DEFAULT_FONT = "Segoe WP Black";
  final int TEXT_SIZE = 30;
  // Directions
  // 3   2   1
  //  \  |  /
  //   \ | /
  //4 -- . -- 0
  //   / | \
  //  /  |  \
  // 5   6   7
  boolean SKIP_DIAGONALS = false; // Set to true to generate only horiz/vert laser paths
  int[] DIRECTIONS = {0, 1, 2, 3, 4, 5, 6, 7};
  int[] REVERSE_DIRECTIONS = {4, 5, 6, 7, 0, 1, 2, 3};
  int DIRECTION_LIMIT = DIRECTIONS.length; // 1 more than max allowed value
  int RIGHT_ANGLE_INCREMENT = 2; // how much to increment a direction to get one that is 90 degrees rotratded.
  int[] ANGLES = {0, 45, 90, 135, 180, 225, 270, 315}; // CW from 0 in 45 degree increments.
  int[][] NEXT_CELL = { // By how much to increment i(row) and j(col) to get to the next cell
    {0, 1}, // Going E
    {-1, 1}, // Going NE
    {-1, 0}, // Going N
    {-1, -1}, // Going NW
    {0, -1}, // Going W
    {1, -1}, // Going SW
    {1, 0}, // Going S
    {1, 1}   // Going SE
  };
  //int[] CW90_MIRROR_ANGLE = {-45, 45, -45, 45}; // mirror angle to turn each incoming dir clockwise (CW) by 90 degrees.
  //int[] CCW90_MIRROR_ANGLE = {45, -45, 45, -45}; // mirror angle to turn each incoming dir COUNTER-clockwise (CCW) by 90 degrees.
  int[] CW90_MIRROR_ANGLE = {-45, 0, 45, 90, -45, 0, 45, 90}; // mirror angle to turn each incoming dir clockwise (CW) by 90 degrees.
  int[] CCW90_MIRROR_ANGLE = {45, 90, -45, 0, 45, 90, -45, 0}; // mirror angle to turn each incoming dir COUNTER-clockwise (CCW) by 90 degrees.

  // Look (chiefly color) of default objects
  GraphicsParams gParams = new GraphicsParams();

  // Look (chiefly color) of lasers
  GraphicsParams gLaserParams = new GraphicsParams();

  public Grid g;
  public Boolean hasError=false; // If there was an internal error while computing puzzle patterns.


  public  LaserHelper(Grid g) {
    this.g = g;


    // Set look of the textboxes
    gParams.font = createFont(DEFAULT_FONT, TEXT_SIZE); // null means don't set
    gParams.textSize = TEXT_SIZE;
    gParams.textColor = 0;
    gParams.backgroundFill = 255;

    // Set look of the lasers
    gLaserParams.font = createFont(DEFAULT_FONT, TEXT_SIZE); // null means don't set
    gLaserParams.textSize = TEXT_SIZE;
    gLaserParams.textColor = 255;
    gLaserParams.backgroundFill = color(255, 0, 0);
    gLaserParams.borderColor = -1;
  }


  void initFromSpec(String[] spec, int[] laserIds) {
    int laserCount = 0;
    for (int i=0; i<g.rows; i++) {
      String row = spec[i];
      for (int j=0; j<g.cols; j++) {
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
  }


  // convert orientation in degrees to a number from 1-7
  // representing the cardinal directions.
  // 0=E(right), 1=N(up), 2=W(left), 3=S(down)
  // orientation is assumed to be one of these directions.
  int cardinalDirection(float orientation) {
    assert(orientation>=-360.0);
    int angleIncrement = 90/RIGHT_ANGLE_INCREMENT; // difference in degrees between successive direction integers.
    int dir = (round(orientation)+360)/angleIncrement % DIRECTION_LIMIT;
    assert(dir>=0 && dir<DIRECTION_LIMIT);
    return dir;
  }


  // Return the cell if available to place
  // an object without disrupting anything
  Cell getCellIfAvailable(int i, int j) {
    Cell cj = g.tryGetCell(i, j);
    return (cj !=null && (cj.dObject == null || (cj.dObject instanceof Dot && !cj.visited))) ? cj : null;
  }


  // Add a laser that targets the specified text cell. Return true if the laser was
  // successfully added.
  Boolean addLaserToTarget(Cell textCell, int laserId) {
    ArrayList<Cell> candidateCells = new ArrayList<Cell>();
    ArrayList<Integer> candidateOrientations = new ArrayList<Integer>();

    for (int direction = 0; direction < DIRECTION_LIMIT; direction++) {
      if (SKIP_DIAGONALS && direction % 2 == 1) {
        continue;
      }
      int[]increments = NEXT_CELL[direction];
      int i = textCell.i + increments[0];
      int j = textCell.j + increments[1];
      Cell c = getCellIfAvailable(i, j);
      if (c!=null) {
        candidateCells.add(c);
        int orientation = ANGLES[REVERSE_DIRECTIONS[direction]];
        candidateOrientations.add(orientation); // pointing in the opposite direction.
      }
    }

    // Now add a laser in a random orientation among the available
    // orientations.
    if (candidateCells.size()>0) {
      int chosenIndex = (int) random(0, candidateCells.size());
      Cell chosenCell = candidateCells.get(chosenIndex);
      chosenCell.dObject = new Laser(laserId, gLaserParams, gLaserParams);
      chosenCell.orientation = candidateOrientations.get(chosenIndex);
      // YES println("ADDING LASER at [" + chosenCell.i + "," + chosenCell.j + "], dir: "  + cardinalDirection(chosenCell.orientation));
      return true;
    } else {
      return false;
    }
  }


  // Return a count of dot-cells that are hit if a hypothetical beam is traced from the start cell
  // heading in the specified direction. The current cell does not need to be a laser.
  // All hard (non-dot) cells visited are added (NOT including the first cell) to hardObjects. All
  // Dot cells hit are added to dotObjects. 
  // If the beam were to immediately leave the grid the first list would contain the just the start cell.
  // Either or both lists can be null. In all cases the correct count of dot cells is returned.
  int tracePath(Cell startCell, int direction, ArrayList<Cell> hardObjects, ArrayList<TraceCellInfo>dotInfo, Boolean mark) {
    int[] dotCounts = {0};
    Cell cNext = startCell;
    Boolean hitMirror=false;
    do {
      hitMirror=false;
      assert(direction>=0 && direction< DIRECTION_LIMIT);
      if (mark) {
        cNext.visited = true;
      }
      // println("Entering tracePath at " + startCell.coordsAsString() + " dir: " + direction);
      cNext = findNextTarget(startCell, cNext, direction, dotInfo, dotCounts, mark);
      if (cNext!= null) {
        assert(cNext.dObject!=null); // It CAN be a dot object if it was the last object before exiting the grid!
        if (hardObjects!=null) {
          hardObjects.add(cNext);
        }
        if (cNext.dObject instanceof TwowayMirror) {
          // We've hit a mirror. We have to check if this is a compatible mirror - if it can direct
          // the laser in a compatible direction.
          int mirrorDir = cardinalDirection(round(cNext.orientation)); // 7, 0, 1 or 2
          Boolean diagonalMirror = mirrorDir%2==1;
          Boolean diagonalBeam = direction%2==1; 
          Boolean compatible = diagonalMirror!=diagonalBeam;
          if (compatible) {
            // we hit a *compatible* mirror, so we can keep going...
            hitMirror=true;
            direction = getNextBeamDirection(direction, cNext.orientation);
            //dotCounts[0]+= tracePath(cNext, direction, hardObjects, dotInfo, mark);
          }
        }
      }
    } while (hitMirror);
    return dotCounts[0];
  }


  void markAllPaths() {
    g.clearVisited();
    Cell[] laserCells = getLasers();
    int i = 0;
    for (Cell c : laserCells) {
      Laser l = laserFromCell(c);
      computeLaserPath(c, true);
      i++;
    }
  }


  ArrayList<Cell> computeLaserPath(Cell c, Boolean mark) {
    ArrayList<Cell> path = new ArrayList<Cell>();
    LaserHelper lh = new LaserHelper(g);
    path.add(c);
    lh.tracePath(c, lh.cardinalDirection(c.orientation), path, null, mark);
    return path;
  }


  // Return the lasers in the order that they are found in the grid
  Cell[] getLasers() {
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


  // Return all cells with lasers, in order of
  // increasing laserIds.
  Cell[] getLasersOrderedById() {
    Cell[] ret = getLasers();
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


  // Return the list of lasers in random order.
  Cell[] pickRandomLaserOrder() {
    Cell[] lasers = getLasers();
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


  void addToPathComplexity() {
    markAllPaths();
    Cell[] lasers  = pickRandomLaserOrder();
    for (Cell c : lasers) {
      int laserDirection = cardinalDirection(c.orientation);
      int maxDots = 0;
      int maxDotsDir = -1;
      float mirrorOrientation = 0;
      TwowayMirror mirror = null;
      Laser laser = (Laser) c.dObject;
      // YES println("addComplexity: laser " + laser.id + " at location " + locationToString(c) + " direction: " + laserDirection);
      for (int i=0; i<3; i++) {
        int backtraceDir = (laserDirection+(i+1)*RIGHT_ANGLE_INCREMENT)%DIRECTION_LIMIT; // (if just 4 cardinal directions: +1, +2 or +3 %4. If 8: +2, +4, +6
        int nDots = tracePath(c, backtraceDir, null, null, false);
        //println("  BTdir:" +  backtraceDir + " nDots: " + nDots);
        if (nDots > maxDots) {
          maxDots = nDots;
          maxDotsDir = backtraceDir;
        }
      }
      //println("  maxDotsDir:" + maxDotsDir);
      if (maxDotsDir==-1) {
        //assert(false);
        assert(maxDots==0);
        continue; // **************** continue to next laser
      }
      assert (maxDots>=1);
      //OBSOLETE int incomingDir = (maxDotsDir + 2) % 4; // the direction of the beam coming *towards* cell c
      int incomingDir = REVERSE_DIRECTIONS[maxDotsDir];
      if (incomingDir==laserDirection) {
        // We will not insert a mirror - rather the laser will keep its direction
        // but move backwards
        // YES println("  Backing up...");
      } else {
        // Add a mirror.
        mirrorOrientation = computeMirrorOrientation(incomingDir, laserDirection);
        mirror = new TwowayMirror(gParams, gParams);
      }


      ArrayList<TraceCellInfo> dotInfo = new ArrayList<TraceCellInfo>();
      tracePath(c, maxDotsDir, null, dotInfo, false);
      setViabilityScore(dotInfo);
      TraceCellInfo cellInfo = pickRandomDot(dotInfo);
      if (cellInfo!=null) {
        assert(!cellInfo.c.visited);
        // We move laser here!
        Cell newLaserCell = moveLaser(c, cellInfo);

        // If we have a mirror, we put it under C.
        if (mirror!=null) {
          c.dObject = mirror;
          c.orientation = mirrorOrientation;
          // YES println("  ADDING MIRROR at " + c.coordsAsString() + " dir: " + cardinalDirection(mirrorOrientation));
        }

        // We mark all cells, starting with the newly-moved laser
        tracePath(newLaserCell, cardinalDirection(newLaserCell.orientation), null, null, true);
      }
    }
  }


  // Compute the orientation of a mirror that will bend a ray headed towards
  // incomingDir into one headed towards outgoingDir
  float computeMirrorOrientation(int incomingDir, int outgoingDir) {
    int change = (DIRECTION_LIMIT+outgoingDir-incomingDir) %DIRECTION_LIMIT;
    change /=  RIGHT_ANGLE_INCREMENT;
    assert(change==1 || change==3); // we should only be called when incoming is at rightangles to outgoing...
    // This is *relative* to incoming direction.
    // let's make it absolute...
    float orientation = (change ==1 ) ? CW90_MIRROR_ANGLE[incomingDir] : CCW90_MIRROR_ANGLE[incomingDir];
    //println("compute mirror direction - id:" + incomingDir + " od: " + outgoingDir + " CHANGE: " + change + " ORIENTATION: " + orientation);
    return orientation;
  }


  // Assuming a beam with orientation prevOrientation hits the mirror,
  // compute the new orientation
  int getNextBeamDirection(int direction, float mirrorOrientation)
  {
    assert(direction>=0 && direction<DIRECTION_LIMIT);
    int m = round(mirrorOrientation); // should be one of : 45, -45, 0, 90 - this is the NORMAL of the mirror, NOT the plane of the mirror.
    // TODO: add additional directions
    //                 0   1   2   3   4   5   6   7
    int[] m45 =      { 6, -1, 4, -1, 2, -1, 0, -1}; // 0<>6, 2<>4 - If it was 0 (going left) it would now be -90 (going down), etc.
    int[] mMinus45 = { 2, -1, 0, -1, 6, -1, 4, -1}; // 0<>2, 4<>6 - If it was 0 (going right) it will now be 90 (going up), etc.
    int[] m90 =      {-1, 7, -1, 5, -1, 3, -1, 1}; // 1<>7, 3<>5 - If it was 1 (going NE) it will now be -45 (going SE), etc.
    int[] m0 =       {-1, 3, -1, 1, -1, 7, -1, 5}; // 1<>3, 5<>7 - If it was 1 (going NE) it will now be 135 (going NW), etc.

    int[] deflection = null;
    if (m == 45) {
      deflection  = m45;
    } else if (m == -45) {
      deflection = mMinus45;
    } else if (m == 0) {
      deflection = m0;
    } else if (m == 90) {
      deflection = m90;
    } else {
      assert(false);
    }

    int newDir =  deflection[direction];
    // println("Next Beam Dir - inDir: " + direction + " mirrorOrientation: " + mirrorOrientation + " newDir: " + newDir);
    return newDir;
  }


  // Find the next target the laser would hit, starting from Cell c and going in direction specified by
  // orientation (in degrees). Return a boundary Dot cell if you hit a boundary. Return null if
  // Cell c is already at the boundary and the laser is leaving the boundary.
  // We use dotCount just to pass-by-reference the count of dots back. A bit of a hack.
  // NOTE: cStart is the start of the path - it is to detect cycles in the path, which
  // can happen.
  Cell findNextTarget(Cell cStart, Cell c, int direction, ArrayList<TraceCellInfo>dotInfoList, int[]dotCount, Boolean mark) {
    assert(direction>=0 && direction<DIRECTION_LIMIT);
    if (dotCount!=null) {
      assert( dotCount.length==1);
      dotCount[0]=0; // int count of dots.
    }
    int di = NEXT_CELL[direction][0];
    int dj = NEXT_CELL[direction][1];
    Cell cNext = null;
    int i=c.i + di;
    int j=c.j + dj;
    while (i>=0 && j>=0 && i<g.rows && j<g.cols) {
      cNext = g.cells[i][j];
      if (cNext == cStart) {
        // Oops, we've encountered a cycle!
        // YES println("CYCLE DETECTED AT " + locationToString(cNext)); // *************** EARLY RETURN **************
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
        // println("Hit object at " + locationToString(cNext));
        break;
      }
      i += di;
      j += dj;
    }
    return cNext;
  }


  // Sets the viability score for all cells in the list - indicating
  // how suitable that location is for (re)placement of lasers
  // and/or placement of mirrors.
  void setViabilityScore(ArrayList<TraceCellInfo> infoList) {
    for (TraceCellInfo info : infoList) {
      info.viabilityScore = computeViabiliyScore(info);
    }
  }


  int computeViabiliyScore(TraceCellInfo info) {
    Cell c = info.c;
    assert(c.dObject instanceof Dot);
    if (c.visited) {
      return 0;
    } 
    int leftDir = (info.direction+1*RIGHT_ANGLE_INCREMENT)%DIRECTION_LIMIT;
    int rightDir = (info.direction+3*RIGHT_ANGLE_INCREMENT)%DIRECTION_LIMIT;
    int leftDots = tracePath(c, leftDir, null, null, false);
    int rightDots = tracePath(c, rightDir, null, null, false);
    return 1+leftDots+rightDots;
  }


  // Given  a list of dots, pick a dot at random from
  // "among the more promising ones" - based on the viabilityScore
  // (already set) of each element.
  TraceCellInfo pickRandomDot(ArrayList<TraceCellInfo> dotInfo) {

    // Compute the max score
    int maxScore = 0;
    int maxStraightRunLength=3;
    TraceCellInfo prevInfo=null;
    int straightRunLength=0;
    for (TraceCellInfo info : dotInfo) {
      straightRunLength = adjacentDot(prevInfo, info) ? straightRunLength+1 : 0;
      // Check if we've got too long of a straight run...
      if (maxScore>0 && straightRunLength>maxStraightRunLength) {
        // Let's torpedoe this cell's viability score.
        info.viabilityScore=0;
      }
      if (info.viabilityScore>maxScore) {
        maxScore = info.viabilityScore;
      }
      prevInfo = info;
    }

    // Compute the number of items with this max score
    int maxCount = 0; // number of items with the max score.
    if (maxScore>0) {
      for (TraceCellInfo info : dotInfo) {
        if (info.viabilityScore==maxScore) {
          maxCount++;
        }
      }
    }
    assert(maxScore==0 || maxCount>0);
    if (maxCount>0) {
      // Pick a random one from this list...
      int chosenIndex = (int) random(0, maxCount);
      int i=0;
      for (TraceCellInfo info : dotInfo) {
        if (info.viabilityScore==maxScore) {
          if (i==chosenIndex) {
            //println("pickDot: maxScore: " + maxScore + " maxCount:" + maxCount + " at " + info.c.coordsAsString());
            return info; // ***************** EARLY RETURN
          }
          i++;
        }
      }
    }
    return null;
  }


  // returns true iff the two dots are adjacent in a straight path
  // with info1 preceeding info2.
  Boolean adjacentDot(TraceCellInfo info1, TraceCellInfo info2) {
    if (info1==null || info2==null) {
      return false;
    }
    Cell c1 = info1.c;
    Cell c2 = info2.c;

    int dir1 = info1.direction;
    int dir2 = info2.direction;

    if (dir1!=dir2) {
      return false;
    }

    // same directions...
    // Now let's check that info2 follows info1
    int[] increments = NEXT_CELL[dir1];
    if (c2.i!=c1.i+increments[0] && c2.j!=c1.j+increments[1]) {
      return false;
    }

    return true;
  }


  float orientationFromCardinalDirection_OBSOLETE(int direction) {
    assert(direction>=0 && direction<4);
    return (direction<3) ? direction * 90.0  : -90.0;
  }


  // Move laser to dotCellInfo. Returns the new cell containing
  // the laser (i.e., dotCellInf)
  Cell moveLaser(Cell laserCell, TraceCellInfo dotCellInfo) {
    Cell newC = dotCellInfo.c;
    assert(laserCell.dObject instanceof Laser);
    assert(newC.dObject instanceof Dot);
    assert(newC.visited==false);
    Drawable dTemp = newC.dObject;
    float orientationTemp = newC.orientation; 

    // Move laser to new location
    newC.dObject = laserCell.dObject;
    // OBSOLETE int newLaserDirection = (dotCellInfo.direction+2)%4; // opposite direction of trace.
    int newLaserDirection  = REVERSE_DIRECTIONS[dotCellInfo.direction]; // opposite direction of trace
    newC.orientation = ANGLES[newLaserDirection]; // OBSOLETE orientationFromCardinalDirection(newLaserDirection);

    // Old laser location becomes dot.
    laserCell.dObject = dTemp;
    laserCell.orientation = orientationTemp;
    return dotCellInfo.c;
  }


  PuzzleStats computePuzzleStats() {
    Cell[]laserCells =  getLasers();
    PuzzleStats pStats = new PuzzleStats();
    int[]mirrorCounts = new int[laserCells.length];
    int[]ssDistances  =  new int[laserCells.length];
    int[]maxSpan  =  new int[laserCells.length];

    for (int i=0; i<laserCells.length; i++) {
      Cell lc = laserCells[i];
      ArrayList<Cell> objects = new ArrayList<Cell>();
      tracePath(lc, cardinalDirection(lc.orientation), objects, null, false);
      mirrorCounts[i] = computeMirrorCount(objects);
      ssDistances[i] = computeManhattanDistance(lc, objects.size()>0 ? objects.get(objects.size()-1) : lc);
      maxSpan[i] = computeMaxSpan(objects);
    } 
    pStats.mirrorCount = computeStats(mirrorCounts);
    pStats.ssDistance = computeStats(ssDistances);
    pStats.maxSpan = computeStats(maxSpan);

    return pStats;
  }


  int computeMirrorCount(ArrayList<Cell> objects) {
    int count = 0;
    for (Cell c : objects) {
      if (c.dObject !=null && c.dObject instanceof TwowayMirror) {
        count++;
      }
    }
    return count;
  }


  // return manhattan distance between the two objects
  int computeManhattanDistance(Cell c1, Cell c2) {
    return (abs(c1.i-c2.i)+abs(c1.j-c2.j));
  }


  int computeMaxSpan(ArrayList<Cell> objects) {
    int maxSpan = 0;
    Cell cPrev=null;
    for (Cell c : objects) {
      if (cPrev!=null) {
        int span = computeManhattanDistance(cPrev, c);
        if (maxSpan < span) {
          maxSpan=span;
        }
      }
      cPrev = c;
    }
    return maxSpan;
  }


  Stats computeStats(int[] data) {
    int min=Integer.MAX_VALUE, max=Integer.MIN_VALUE;
    float avg=0;
    float sum=0;
    float sumSquared=0;
    Stats s = new Stats();
    s.n=data.length;
    if (data.length==0) {
      return s; // ** early return *******
    }
    for (int d : data) {
      if (min>d) {
        min=d;
      }
      if (max<d) {
        max=d;
      }
      sum+=d;
    }
    avg = sum/data.length;
    for (int d : data) {
      sumSquared += (d-avg)*(d-avg);
    }
    s.min = min;
    s.max = max;
    s.avg = avg;
    s.sd = sqrt(sumSquared/data.length);
    return s;
  }


  // Return the number of dots in the grid
  int dotCount() {
    int n=0;
    for (Cell[] row : g.cells) {
      for (Cell c : row) {
        if (c.dObject!=null && c.dObject instanceof Dot) {
          n++;
        }
      }
    }
    return n;
  }

  char escapeChar(char c) {
    int i = SPECIAL_CHARS.indexOf(c);
    return (i==-1) ? c : ESCAPE_CHARS.charAt(i);
  }

  char unescapeChar(char c) {
    int i = ESCAPE_CHARS.indexOf(c);
    return (i==-1) ? c : SPECIAL_CHARS.charAt(i);
  }


  // Draw the laser paths using appropriate styling
  // depending on whether there are discrepancies
  // with the expected puzzle text.
  void drawPaths(String expectedText) {
    Cell[] laserCells = getLasersOrderedById();
    int i = 0;
    for (Cell c : laserCells) {
      Laser l = laserFromCell(c);
      //println("Found laser " + l.id + " at (" + c.i + "," + c.j + ")");
      ArrayList<Cell> path = computeLaserPath(c, true);
      String s = i<expectedText.length() ? expectedText.substring(i, i+1) : "";
      drawLaserPath(path, s);
      //break;
      i++;
    }
    highlightUnvisitedObjects();
  }


  // Draw the laser paths for the specific ID using appropriate styling
  // depending on whether there are discrepancies
  // with the expected puzzle text.
  void drawLaserPath(int id, String expectedText) {
    Cell[] laserCells = getLasers();
    for (Cell c : laserCells) {
      Laser l = laserFromCell(c);
      if (l.id==id) {
        //println("Found laser " + l.id + " at (" + c.i + "," + c.j + ")");
        ArrayList<Cell> path = computeLaserPath(c, true);
        drawLaserPath(path, expectedText);
        break;
      }
    }
  }

  // Set exactly those cells that are touched by
  // beams to "visited" status.
  // ???


  // Hilight all non-DOT objects that have not
  // been visited
  void highlightUnvisitedObjects() {
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


  void drawLaserPath(ArrayList<Cell> path, String expectedText) {
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
  String[] specFromGrid() {
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


  // Return the text boxes in the order that they are found in the grid
  Cell[] getTextBoxes() {
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


  int[] getLaserIds () {
    Cell[] cells = getLasers();
    int[] ids = new int[cells.length];
    for (int i=0; i<cells.length; i++) {
      ids[i] = ((Laser) cells[i].dObject).id;
    }
    return ids;
  }


  String getText () {
    Cell[] cells = getTextBoxes();
    String text = "";
    for (int i=0; i<cells.length; i++) {
      text += ((TextBox) (cells[i].dObject)).label;
    }
    return text;
  }


  // If path is null output is to console.
  void printGrid(String path) {
    String[] spec = specFromGrid();
    int[] ids = getLaserIds();
    String output = "";
    String text = getText();
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
  Cell newOrExistingTextBox(String s) {
    Cell c = findViableExistingTextBox(s);
    if (c == null) {
      c = placeNewTextBox(s);
    }
    return c;
  }


  Cell findViableExistingTextBox(String s) {
    ArrayList<Cell> candidateCells = new ArrayList<Cell>();
    ArrayList<Integer> candidateScores = new ArrayList<Integer>();
    for (int i=0; i<g.rows; i++) {
      for (int j=0; j<g.cols; j++) {
        Cell c = g.cells[i][j];
        if (c.dObject!=null && c.dObject instanceof TextBox) {
          if (((TextBox)c.dObject).label.equals(s)) {
            int score = computeTextBoxViabilityScore(c);
            if (score>0) {
              candidateCells.add(c);
              candidateScores.add(score);
            }
          }
        }
      }
    }

    return pickRandomTopViableCellForTextBox(candidateCells, candidateScores);
  }


  // Given a list of candidate cells (all of which are assumed to be viable)
  // pick a random one amongst the very top scorers
  Cell pickRandomTopViableCellForTextBox(ArrayList<Cell> candidateCells, ArrayList<Integer> candidateScores) {
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
  int computeTextBoxViabilityScore(Cell c) {
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
        Cell cj = getCellIfAvailable(i, j);
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


  Cell placeNewTextBox(String s) {
    // Place the text box by computing viable locations and then picking
    // randomly among the top scorers.
    ArrayList<Cell> candidateCells = new ArrayList<Cell>();
    ArrayList<Integer> candidateScores = new ArrayList<Integer>();
    for (int i=0; i<g.rows; i++) {
      for (int j=0; j<g.cols; j++) {
        Cell c = getCellIfAvailable(i, j);
        if (c!=null) {
          int score = computeTextBoxViabilityScore(c);
          if (score > 0) {
            candidateCells.add(c);
            candidateScores.add(score);
          }
        }
      }
    }
    Cell chosenCell = pickRandomTopViableCellForTextBox(candidateCells, candidateScores);
    if (chosenCell!=null) {
      chosenCell.dObject = new TextBox(s, gParams, gParams);
    }
    return chosenCell;
  }


  // Add more lasers so that the supplied text
  // is *appended* to the existing answer text.
  // Laser Ids start with one more than the max Id
  // already in the system, (or 1 if none exists)
  Boolean addToGrid(String text) {
    int[] existingIds = getLaserIds();
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
      Cell textCell = newOrExistingTextBox(s);
      Boolean ok = false;
      if (textCell!=null) {
        ok = addLaserToTarget(textCell, startId + i);
      }
      if (!ok) {
        assert(false);
        return false; // *********** EARLY RETURN
      }
    }
    return true;
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
}