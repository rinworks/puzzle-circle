
// Various helper methods specific
// to the laser puzzle


// Keep track of a single cell in a chain
// of cells visited in a laser beam trace.
class TraceCellInfo {
  public final Cell c;
  public final int direction;
  public TraceCellInfo(Cell c, int direction) {
    this.c = c;
    this.direction=direction;
  }
}


class LaserHelper {
  int DIRECTION_LIMIT = 4; // 1 more than max allowed value.
  public Grid g;
  public  LaserHelper(Grid g) {
    this.g = g;
  }

  // Return a count of dot-cells that are hit if a hypothetical beam is traced from the start cell
  // heading in the specified direction. The current cell does not need to be a laser.
  // All hard (non-dot) cells visited are added (NOT including the first cell) to hardObjects. All
  // Dot cells hit are added to dotObjects. 
  // If the beam were to immediately leave the grid the first list would contain the just the start cell.
  // Either or both lists can be null. In all cases the correct count of dot cells is returned.
  int tracePath(Cell startCell, int direction, ArrayList<Cell> hardObjects, ArrayList<TraceCellInfo>dotInfo, Boolean mark) {
    int[] dotCounts = {0};
    assert(direction>=0 && direction< DIRECTION_LIMIT);
    if (mark) {
      startCell.visited = true;
    }
    //println("Entering growLaserPath. #elements: " + path.size());
    Cell cNext = findNextTarget(g, startCell, direction, dotInfo, dotCounts, mark);
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

  void addToPathComplexity() {
    markAllPaths(g);
    Cell[] lasers  = pickRandomLaserOrder(g);
    for (Cell c : lasers) {
      int laserDirection = cardinalDirection(c.orientation);
      int[] backtraceDirections = new int[3];
      int[] dotCounts = new int[3];
      int maxDots = 0;
      int maxDotsDir = -1;
      float mirrorOrientation = 0;
      TwowayMirror mirror = null;
      Laser laser = (Laser) c.dObject;
      println("addComplexity: laser " + laser.id + " at location " + locationToString(c) + " direction: " + laserDirection);
      for (int i=0; i<3; i++) {
        int backtraceDir = (laserDirection+i+1)%4; // +1, +2 or +3 %4.
        int nDots = tracePath(c, backtraceDir, null, null, false);
        println("  dir:" +  backtraceDir + "nDots: " + nDots);
        backtraceDirections[i] = backtraceDir;
        if (nDots > maxDots) {
          maxDots = nDots;
          maxDotsDir = backtraceDir;
        }
      }
      println("  maxDotsDir:" + maxDotsDir);
      if (maxDotsDir==-1) {
        //assert(false);
        assert(maxDots==0);
        continue; // **************** continue to next laser
      }
      assert (maxDots>=1);
      int incomingDir = (maxDotsDir + 2) % 4; // the direction of the beam coming *towards* cell c
      if (incomingDir==laserDirection) {
        // We will not insert a mirror - rather the laser will keep its direction
        // but move backwards
        println("  Backing up...");
      } else {
        // Add a mirror.
        mirrorOrientation = computeMirrorOrientation(incomingDir, laserDirection);
        println("  Adding mirror. Mirror orientation: " + mirrorOrientation);
        mirror = new TwowayMirror(gParams, gParams);
       }


      ArrayList<TraceCellInfo> dotInfo = new ArrayList<TraceCellInfo>();
      tracePath(c, maxDotsDir, null, dotInfo, false);
      TraceCellInfo cellInfo = pickRandomDot(dotInfo);
      if (cellInfo!=null) {
        // We move laser here!
        Cell newLaserCell = moveLaser(c, cellInfo);

        // If we have a mirror, we put it under C.
        if (mirror!=null) {
          c.dObject = mirror;
          c.orientation = mirrorOrientation;
        }
        
        // We mark all cells, starting with the newly-moved laser
        tracePath(cellInfo.c, cardinalDirection(newLaserCell.orientation), null, null, true);
      }
    }
  }

  // Compute the orientation of a mirror that will bend a ray headed towards
  // incomingDir into one headed towards outgoingDir
  float computeMirrorOrientation(int incomingDir, int outgoingDir) {
        int change = (4+outgoingDir-incomingDir) %4;
        assert(change==1 || change==3);
        int orientation = -45;
        if (change == 3) {
          orientation = 45;
        }
        // we're not quite done yet - this is *relative* to incoming direction.
        // let's make it absolute...
        int[] rotationAmount = {0,90,180,270};
        orientation = (orientation + rotationAmount[incomingDir]) % 360;
        // Now we normalize the rotation taking into account that this is a two-way mirror.
        if (orientation == (45+180)) {
          orientation = 45;
        } else if (orientation == (-45+180)) {
          orientation = -45;
        } else if (orientation == (360-45)) {
          orientation = -45;
        }
        return orientation;
  }
  
  
  // TODO
  TraceCellInfo pickRandomDot(ArrayList<TraceCellInfo> dotInfo) {
    // For now pick first available dot!
    for (TraceCellInfo info : dotInfo) {
      if (!info.c.visited) {
        return info;
      }
    }
    return null;
  }

  Cell moveLaser(Cell laserCell, TraceCellInfo dotCellInfo) {
    Cell newC = dotCellInfo.c;
    assert(laserCell.dObject instanceof Laser);
    assert(newC.dObject instanceof Dot);
    assert(newC.visited==false);
    Drawable dTemp = newC.dObject;
    float orientationTemp = newC.orientation; 

    // Move laser to new location
    newC.dObject = laserCell.dObject;
    int newLaserDirection = (dotCellInfo.direction+2)%4; // opposite direction of trace.
    newC.orientation = orientationFromCardinalDirection(newLaserDirection);

    // Old laser location becomes dot.
    laserCell.dObject = dTemp;
    laserCell.orientation = orientationTemp;
    return laserCell;
  }
}