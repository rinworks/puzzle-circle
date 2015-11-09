class Point {
  float x;
  float y;
  public Point(float x, float y) {
    this.x=x;
    this.y=y;
  }
}

void setup() {
  size(1200,1200);
  drawPuzzle();
}

void drawPuzzle() {
  long randomSeed = 0;
  randomSeed(randomSeed);
  Point[] diskCenters = {
    new Point(0,0),
    new Point(0,0),
    new Point(0,0),
    new Point(0,0)
  };
  
  float DISK_RADIUS  = min(width,height)/4.0;
  
  Point [] polygon = new Point[diskCenters.length];
  for (int i=0;i<polygon.length;i++) {
    polygon[i] = pickRandomPointInDisk(diskCenters[0], DISK_RADIUS);
  }
  float[] interiorAngles = computeInteriorAngles(polygon);
 
  drawCrisscross(polygon);
  
  // Pick index of x, the exterior angle that must be computed.
  // and draw annnotation "X"
  int xIndex = floor(random(0,polygon.length));
  assert(xIndex<polygon.length);
  drawAnnotation(polygon, xIndex, 0, "X"); // 0 == "interior"
  
  // Pick index of y, the interior angle that must be computerd.
  // x and y should not be the same point!
  int yIndex = (xIndex + 1 + floor(random(0,polygon.length-1))) % polygon.length;
  assert(yIndex!=xIndex);
  drawAnnotation(polygon, yIndex, 2, "Y"); // 2 == "exterior"
  
  // Pick complementary angles for all but xIndex.
  for (int i=0;i<polygon.length-1;i++) {
    int cIndex = (xIndex+1+i) % polygon.length;
    assert(cIndex!=xIndex);
    int direction = (random(1.0)<0.5)? 1 : 3; // specify one of two possible complementary directions (0== interior, 2==exterior).
    drawAnnotation(polygon, cIndex, direction, null); // null == draw label as actual degrees.
    // drawAnnotation(Point[] points, int pointIndex, int directionIndex, String label); (null == label is actual degrees.)
  } 
}

// Return a random point within the specified disk
Point pickRandomPointInDisk(Point center, float radius) {
  float dX = random(-radius, radius);
  float dY = random(-radius, radius);
  return new Point(center.x+dX, center.y+dY);
}

// Given a polygon compute and return the interior angles at each point.
float[] computeInteriorAngles(Point[] polygon) {
  if (polygon.length < 3) {
    throw new IllegalArgumentException("polygon has less than 3 points");
  }
  return null;
}

// Draw a crisscross pattern linking together successive points in the
// array
void drawCrisscross(Point[] points) {
}

// Draw a label indicating the degrees (or simply the supplied label) at the specified 
// a "quadrant" at specified point. (null == label drawn is actual degrees.)
//  directionIndex: 
//      0==interior
//      1== 1st CW from interior
//      2==exterior
//      3==1st CW from exterior (or 1st CCW from interior)
void drawAnnotation(Point[] points, int pointIndex, int directionIndex, String label) {
}