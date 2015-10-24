
// Various helper methods specific
// to the laser puzzle
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
  int tracePath(Cell startCell, int direction, ArrayList<Cell> hardObjects, ArrayList<Cell>dotObjects, Boolean mark) {
    int[] dotCounts = {0};
    assert(direction>=0 && direction< DIRECTION_LIMIT);
    //println("Entering growLaserPath. #elements: " + path.size());
    Cell cNext = findNextTarget(g, startCell, direction, dotObjects, dotCounts, mark);
    if (cNext!= null) {
      assert(cNext.dObject!=null && !(cNext.dObject instanceof Dot));
      if (hardObjects!=null) {
        hardObjects.add(cNext);
      }
      if (cNext.dObject instanceof TwowayMirror) {
        // we hit a mirror, so we can keep going...
        //println("RECURSIVE CALL to growLaserPath");
        int newDirection = getNextBeamDirection(direction, cNext.orientation);
        dotCounts[0]+= tracePath(cNext, newDirection, hardObjects, dotObjects, mark);
      }
    }
    return dotCounts[0];
  }
}