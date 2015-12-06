 //<>// //<>// //<>// //<>// //<>// //<>// //<>//
// Various helper methods specific
// to the laser puzzle


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

class LaserHelper {
  int[] DIRECTIONS = {0, 1, 2, 3};
  int[] REVERSE_DIRECTIONS = {2, 3, 0, 1};
  int DIRECTION_LIMIT = DIRECTIONS.length; // 1 more than max allowed value
  int RIGHT_ANGLE_INCREMENT = 1; // how much to increment a direction to get one that is 90 degrees rotratded.
  int[] ANGLES = {0, 90, 180, 270}; // CW from 0 in 45 degree increments, within range of +/180.
  int[][] NEXT_CELL = { // By how much to increment i(row) and j(col) to get to the next cell
    {0, 1}, // Going E
    {-1, 0}, // Going N
    {0, -1}, // Going W
    {1, 0}   // Going S
  };
  int[] CW90_MIRROR_ANGLE = {-45, 45, -45, 45}; // mirror angle to turn each incoming dir clockwise (CW) by 90 degrees.
  int[] CCW90_MIRROR_ANGLE = {45, -45, 45, -45}; // mirror angle to turn each incoming dir COUNTER-clockwise (CCW) by 90 degrees.


  public Grid g;
  public Boolean hasError=false; // If there was an internal error while computing puzzle patterns.
  public  LaserHelper(Grid g) {
    this.g = g;
  }

  // Add a laser that targets the specified text cell. Return true if the laser was
  // successfully added.
  Boolean addLaserToTarget(Cell textCell, int laserId) {
    ArrayList<Cell> candidateCells = new ArrayList<Cell>();
    ArrayList<Integer> candidateOrientations = new ArrayList<Integer>();

    for (int direction = 0; direction < DIRECTION_LIMIT; direction++) {
      int[]increments = NEXT_CELL[direction];
      int i = textCell.i + increments[0];
      int j = textCell.j + increments[1];
      Cell c = getCellIfAvailable(g, i, j);
      if (c!=null) {
        candidateCells.add(c);
        int orientation = ANGLES[REVERSE_DIRECTIONS[direction]];
        //println("ADD LASER: dir="+direction+"; angle="+orientation);
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
      //println("Entering growLaserPath. #elements: " + path.size());
      cNext = findNextTarget(startCell, cNext, direction, dotInfo, dotCounts, mark);
      if (cNext!= null) {
        assert(cNext.dObject!=null); // It CAN be a dot object if it was the last object before exiting the grid!
        if (hardObjects!=null) {
          hardObjects.add(cNext);
        }
        if (cNext.dObject instanceof TwowayMirror) {
          // we hit a mirror, so we can keep going...
          hitMirror=true;
          direction = getNextBeamDirection(direction, cNext.orientation);
          //dotCounts[0]+= tracePath(cNext, direction, hardObjects, dotInfo, mark);
        }
      }
    } while (hitMirror);
    return dotCounts[0];
  }

  /*
  int tracePathRecursiveObsolete(Cell startCell, int direction, ArrayList<Cell> hardObjects, ArrayList<TraceCellInfo>dotInfo, Boolean mark) {
   int[] dotCounts = {0};
   assert(direction>=0 && direction< DIRECTION_LIMIT);
   if (mark) {
   startCell.visited = true;
   }
   //println("Entering growLaserPath. #elements: " + path.size());
   Cell cNext = findNextTarget(g, startCell, startCell, direction, dotInfo, dotCounts, mark);
   if (cNext!= null) {
   assert(cNext.dObject!=null); // It CAN be a dot object if it was the last object before exiting the grid!
   if (hardObjects!=null) {
   hardObjects.add(cNext);
   }
   if (cNext.dObject instanceof TwowayMirror) {
   // we hit a mirror, so we can keep going...
   //println("RECURSIVE CALL to growLaserPath");
   int newDirection = getNextBeamDirection(direction, cNext.orientation);
   dotCounts[0]+= tracePath(cNext, newDirection, hardObjects, dotInfo, mark);
   }
   }
   return dotCounts[0];
   }
   */

  void addToPathComplexity() {
    markAllPaths(g);
    Cell[] lasers  = pickRandomLaserOrder(g);
    for (Cell c : lasers) {
      int laserDirection = cardinalDirection(c.orientation);
      int maxDots = 0;
      int maxDotsDir = -1;
      float mirrorOrientation = 0;
      TwowayMirror mirror = null;
      Laser laser = (Laser) c.dObject;
      //println("addComplexity: laser " + laser.id + " at location " + locationToString(c) + " direction: " + laserDirection);
      for (int i=0; i<3; i++) {
        int backtraceDir = (laserDirection+i+RIGHT_ANGLE_INCREMENT)%DIRECTION_LIMIT; // (if just 4 cardinal directions: +1, +2 or +3 %4. If 8: +2, +4, +6
        int nDots = tracePath(c, backtraceDir, null, null, false);
        //println("  dir:" +  backtraceDir + "nDots: " + nDots);
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
        //println("  Backing up...");
      } else {
        // Add a mirror.
        mirrorOrientation = computeMirrorOrientation(incomingDir, laserDirection);
        //println("  Adding mirror. Mirror orientation: " + mirrorOrientation);
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
    return orientation;
  }

  // Assuming a beam with orientation prevOrientation hits the mirror,
  // compute the new orientation
  int getNextBeamDirection(int direction, float mirrorOrientation)
  {
    assert(direction>=0 && direction<DIRECTION_LIMIT);
    int m = round(mirrorOrientation); // should be either 45 or -45 - this is the NORMAL of the mirror, NOT the plane of the mirror.
    // TODO: add additional directions
    int[] m45 = {3, 2, 1, 0}; // If it was 0 (going left) it would now be -90 (going down), etc.
    int[] mMinus45 = {1, 0, 3, 2}; // If it was 0 (going right) it will now be 90 (going up), etc.
    int[] m0 = {1, 0, 3, 2}; // If it was 0 (going right) it will now be 90 (going up), etc.
    int[] m90 = {1, 0, 3, 2}; // If it was 0 (going right) it will now be 90 (going up), etc.

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

    return deflection[direction];
  }


  // Find the next target the laser would hit, starting from Cell c and going in direction specified by
  // orientation (in degrees). Return a boundary Dot cell if you hit a boundary. Return null if
  // Cell c is already at the boundary and the laser is leaving the boundary.
  // We use dotCount just to pass-by-reference the count of dots back. A bit of a hack.
  // NOTE: cStart is the start of the path - it is to detect cycles in the path, which
  // can happen.
  Cell findNextTarget(Cell cStart, Cell c, int direction, ArrayList<TraceCellInfo>dotInfoList, int[]dotCount, Boolean mark) {
    assert(direction>=0 && direction<4);
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
    int leftDir = (info.direction+1)%4;
    int rightDir = (info.direction+3)%4;
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
    //println("pickDot: maxScore: " + maxScore + " maxCount:" + maxCount);
    if (maxCount>0) {
      // Pick a random one from this list...
      int chosenIndex = (int) random(0, maxCount);
      int i=0;
      for (TraceCellInfo info : dotInfo) {
        if (info.viabilityScore==maxScore) {
          if (i==chosenIndex) {
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
    newC.orientation = orientationFromCardinalDirection(newLaserDirection);

    // Old laser location becomes dot.
    laserCell.dObject = dTemp;
    laserCell.orientation = orientationTemp;
    return dotCellInfo.c;
  }

  // public Stats mirrorCount; // Number of mirrors in path.
  //public Stats ssDistance;  // Manhattan distance between source and sink.
  //public Stats maxSpan; // Max distance between adjacent mirrors.

  PuzzleStats computePuzzleStats() {
    Cell[]laserCells =  getLasers(g);
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
}