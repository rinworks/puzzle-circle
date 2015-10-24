
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
    //println("Entering growLaserPath. #elements: " + path.size());
    Cell cNext = findNextTarget(g, startCell, direction, dotInfo, dotCounts, mark);
    if (cNext!= null) {
      assert(cNext.dObject!=null && !(cNext.dObject instanceof Dot));
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

      // We decide if we insert a new mirror or not. Then we shoot a a ray backwards and
      // pick a new location amongs available locations.
      Boolean newMirror = false; // random(1.0)<0.5;
      int laserDirection = cardinalDirection(c.orientation);
      int backtraceDirection = (laserDirection+2)%4; // opposite direction to laser.
      if (newMirror) {
        // do something, including updating backtraceDirection
      }

      ArrayList<TraceCellInfo> dotInfo = new ArrayList<TraceCellInfo>();
      tracePath(c, backtraceDirection, null, dotInfo, false);
      //Cell newCell = pickRandomDot(dotInfo);
      //if (newCell!=null) {
        // We move laser here!
        //moveLaser(c, newCell);
      //}



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
}