class Point {
  float x;
  float y;
  public Point(float x, float y) {
    this.x=x;
    this.y=y;
  }
}

void setup() {
  size(1000, 1000);
  drawPuzzle();
}

void drawPuzzle() {

  
  // Set this to specific values to create repeatable
  // puzzles.
  long randomSeed = floor(random(0,1000));
  randomSeed(randomSeed);
  
  // Create four locations that are roughly
  // North, East, South West.
  // We do this by creating for precice locations and then
  // picking random points that are within a disk of radius
  // DISK_RADIOUS of those points.
  float Ny = height*0.2;
  float Sy = height*0.8;
  float Ex = width*0.2;
  float Wx = width*0.8;
  Point[] diskCenters = {
    new Point(width/2, Ny), // North
    new Point(Ex, height/2), // East
    new Point(width/2, Sy), // South
    new Point(Wx, height/2)  // West
  };
  float DISK_RADIUS  = min(width, height)/10.0;
  Point [] polygon = new Point[diskCenters.length];
  for (int i=0; i<polygon.length; i++) {
    polygon[i] = pickRandomPointInDisk(diskCenters[i], DISK_RADIUS);
  }
  
  // Actually draw the criscross pattern
  // (black on white background)
  background(255);
  stroke(0);
  drawCrisscross(polygon);

  // Pick index of x, the exterior angle that must be computed.
  // and draw annnotation "X"
  int xIndex = floor(random(0, polygon.length));
  assert(xIndex<polygon.length);
  drawAnnotation(polygon, xIndex, 0, "X"); // 0 == "interior"

  // Pick index of y, the interior angle that must be computerd.
  // x and y should not be the same point!
  int yIndex = (xIndex + 1 + floor(random(0, polygon.length-1))) % polygon.length;
  assert(yIndex!=xIndex);
  drawAnnotation(polygon, yIndex, 2, "Y"); // 2 == "exterior"

  // Pick complementary angles for all but xIndex.
  for (int i=0; i<polygon.length-1; i++) {
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
float computeInteriorAngle(Point[] polygon, int index) {
  if (polygon.length < 3) {
    throw new IllegalArgumentException("polygon has less than 3 points");
  }
  return 0.0;
}

// Draw a crisscross pattern linking together successive points in the
// array. There must be at least 2 points in the array and successive
// points must be spatially separated.
void drawCrisscross(Point[] points) {
  strokeWeight(4);
  assert(points.length > 1);
  for (int i=0; i<points.length; i++) {
    int nextIndex = (i + 1) % points.length;
    Point p1 = points[i];
    Point p2 = points[nextIndex];
    float x1=p1.x;
    float x2=p2.x;
    float y1=p1.y;
    float y2=p2.y;
    line(x1, y1, x2, y2);
  }
}

// Draw a label indicating the degrees (or simply the supplied label) at the specified 
// a "quadrant" at specified point. (null == label drawn is actual degrees.)
//  directionIndex: 
//      0==interior
//      1== 1st CW from interior
//      2==exterior
//      3==1st CW from exterior (or 1st CCW from interior)
void drawAnnotation(Point[] points, int pointIndex, int directionIndex, String label) {
  float interiorAngle = computeInteriorAngle(points, pointIndex);
}