class Point {
  float x;
  float y;
  public Point(float x, float y) {
    this.x=x;
    this.y=y;
  }
}

void setup() {
  size(1300, 1300);
  drawPuzzle();
}

void drawPuzzle() {


  // Set this to specific values to create repeatable
  // puzzles.
  long randomSeed = floor(random(0, 1000));
  randomSeed(randomSeed);

  // Create four locations that are roughly
  // North, East, South West.
  // We do this by creating for precice locations and then
  // picking random points that are within a disk of radius
  // DISK_RADIOUS of those points.
  float Ny = height*0.2;
  float Sy = height*0.8;
  float Ex = width*0.8;
  float Wx = width*0.2;
  Point[] diskCenters = {
    new Point(width/2, Ny), // North
    new Point(Ex, height/2), // East
    new Point(width/2, Sy), // South
    new Point(Wx, height/2)  // West
  };
  float DISK_RADIUS  = min(width, height)/8.0;
  Point [] polygon = new Point[diskCenters.length];
  for (int i=0; i<polygon.length; i++) {
    polygon[i] = pickRandomPointInDisk(diskCenters[i], DISK_RADIUS);
  }


  // Text fill color and size.
  textSize(20);
  fill(0);

  // Actually draw the criscross pattern
  // (black on white background)
  background(255);
  stroke(0);
  drawCrisscross(polygon);



  // Pick index of x, the exterior angle that must be computed.
  // and draw annnotation "X"
  int xIndex = floor(random(0, polygon.length));
  assert(xIndex<polygon.length);
  int xAngle = drawAnnotation(polygon, xIndex, 0, "X"); // 0 == "exterior"

  // Pick index of y, the interior angle that must be computerd.
  // x and y should not be the same point!
  int yIndex = (xIndex + 1 + floor(random(0, polygon.length-1))) % polygon.length;
  assert(yIndex!=xIndex);
  int yAngle = drawAnnotation(polygon, yIndex, 2, "Y"); // 2 == "interior"

  // Pick complementary angles for all but xIndex.
  int compAngleSum = 0;
  for (int i=0; i<polygon.length-1; i++) {
    int cIndex = (xIndex+1+i) % polygon.length;
    assert(cIndex!=xIndex);
    int direction = (random(1.0)<0.5)? 1 : 3; // specify one of two possible complementary directions (0== interior, 2==exterior).
    compAngleSum +=drawAnnotation(polygon, cIndex, direction, null); // null == draw label as actual degrees.
    // drawAnnotation(Point[] points, int pointIndex, int directionIndex, String label); (null == label is actual degrees.)
  }
  save("output\\output.png");
  int xEst = compAngleSum-180;
  println("seed=" + randomSeed + " X=" + xAngle  + " Y=" + yAngle + " xEst" + xEst +  " X+Y=" + (xAngle+yAngle) + "   ANSWER(XEst+Y)=" + (xEst+yAngle));
}

// Return a random point within the specified disk
Point pickRandomPointInDisk(Point center, float radius) {
  float dX = random(-radius, radius);
  float dY = random(-radius, radius);
  return new Point(center.x+dX, center.y+dY);
}

// Compute the absolute angle (in degrees) of point p2 relative to 
// point p1
float computeAngle(Point p1, Point p2) {
  float dX = p2.x-p1.x;
  float dY = p2.y-p1.y;
  float hyp = sqrt(dX*dX+dY*dY);
  float angle;
  if (abs(dX/hyp)<0.5) {
    angle =  acos(dX/hyp);
    if (dY<0) {
      angle = -angle; // flip actoss the x axis
    }
  } else {
    angle = asin(dY/hyp);
    if (dX<0) {
      angle = PI-angle; // flip across the y axis, equivalent to
      // rotating 90, flipping across x and rotating back 90,
      // which is: 90-(angle-90).
    }
  }
  float deg =  degrees(angle);
  return (360+deg)%360.0;
}

// Draw a crisscross pattern linking together successive points in the
// array. There must be at least 2 points in the array and successive
// points must be spatially separated.
void drawCrisscross(Point[] points) {
  strokeWeight(4);
  assert(points.length > 1);
  for (int i=0; i<points.length; i++) {
    int nextIndex = (i + 1) % points.length;
    Point p0 = points[i];
    Point p2 = points[nextIndex];
    Point p1 = extendPoint(p0, p2, -100.0);
    p2 = extendPoint(p0, p2, 100.0);
    float x1=p1.x;
    float x2=p2.x;
    float y1=p1.y;
    float y2=p2.y;
    line(x1, y1, x2, y2);
    //labelPoint(p0, i);
  }
}

void labelPoint(Point p, int i) {
  String s = ""+i + ":("+round(p.x) + "," + round(p.y) + ")";
  text(s, p.x+10, p.y);
}

// Extend point by reaching "amount" amount.
Point extendPoint(Point p1, Point p2, float amount) {
  float x = p1.x + amount * (p2.x-p1.x);
  float y = p1.y + amount * (p2.y-p1.y);
  return new Point(x, y);
}

// Draw a label indicating the degrees (or simply the supplied label) at the specified 
// a "quadrant" at specified point. (null == label drawn is actual degrees.)
//  directionIndex: 
//      0==exterior
//      1== 1st CW from interior
//      2==interior
//      3==1st CW from exterior (or 1st CCW from interior)
// RETURN: the angle of the specified "quadrant"
int drawAnnotation( Point[] points, int pointIndex, int directionIndex, String label) {
  Point p = points[pointIndex];
  Point pPrev = points[(points.length + pointIndex-1) % points.length];
  Point pNext  = points[(points.length + pointIndex+1) % points.length];
  float angle1 = computeAngle(p, pPrev); //<>//
  float angle2 = computeAngle(p, pNext);
  float avg = (angle1+angle2)/2;
  float diff = abs(angle1-angle2);
  if (diff>180.0) {
    diff = 360-diff; // compute the acute-angle difference.
    avg  -=  180; // flip it around because want the acute angle direction.
  }
  assert(diff<179.0); // Polygon is expected to be sufficiently convex at the point. 
  float midAngle=0.0;
  switch(directionIndex) {
    case 0: midAngle = avg+180; // exterior angle. diff stays the same.
    break;
    case 1: midAngle = 90+avg;
            diff  =180-diff; // complementary angle
    break;
    case 2: midAngle = avg;
    break;
    case 3: midAngle = 270+avg;
            diff = 180-diff; // complimentary angle
    break;
    default:
    assert(false);
  }
  pushMatrix();
  translate(p.x, p.y);

  rotate(radians(midAngle));
  //translate(10.0,0.0); // depends on point size.
  translate(40,0);
  rotate(-radians(midAngle));
  textAlign(CENTER, CENTER);
  int iDiff = round(diff); // we just want to display and return integer values.
  text((label==null?""+iDiff:label)+"°", 0, 0); // Watch out for that little degree unicode character!

  popMatrix();
  //arc(0,0);
  return iDiff;
}