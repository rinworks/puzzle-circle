class Point {
  float x;
  float y;
  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public String toString() {
    return "("+x+","+y+")";
  }
}

abstract class AnimatedObject {
  final float MOVEMENT_INCREMENT = 0.01; // Fractional amount to move between points each frame.
  float xC=0;
  float yC=0;
  float w=0;
  float h=0;
  float a=0; // angle in radians.
  Point[] points=null;
  int[] path=null; // indexes of points in path, can be repeats.
  boolean visible=false;
  int curIndex=0;
  boolean goForward=true; // increasing index if true, decreasing index if false.
  float fraction=0.0; // Fractional amount moved between curIndex and next index;

  AnimatedObject(float w, float h, Point[] points, int[] path) {
    //this.xC = xC;
    //his.yC = yC;
    this.w = w;
    this.h = h;
    this.points = points;
    this.path = path;
  }

  // Start at a particular point (index into points), oriented at a particular angle.
  void start(int point, float angle) {
    visible=true;
    curIndex = point;
    fraction = 0.0;
    goForward = true;
    Point p = this.points[point];
    this.xC = p.x;
    this.yC = p.y;
    this.a = angle;
  }

  // Attempt to move autonomously, taking the position of
  // other objects into account.
  void move() {

    if (path==null || path.length==0) {
      return;
    }

    //
    // Compute the next point to head towards, taking direction into account.
    //
    assert(path.length>0);
    int next =  nextIndex(curIndex);

    //
    // Update location
    //
    assert(MOVEMENT_INCREMENT>=0.0 && MOVEMENT_INCREMENT<1.0);
    assert(fraction>=0.0 && fraction<=1.0);
    this.fraction += MOVEMENT_INCREMENT;
    if (this.fraction > 1.0) {
      // We've over stepped, move to next index
      curIndex = next;
      next = nextIndex(curIndex);
      this.fraction -= 1.0;
      assert(fraction>=0.0 && fraction<=1.0);
    }

    //
    // Interpolate
    //
    Point p1 = points[path[curIndex]];
    Point p2 = points[path[next]];
    this.xC = lerp(p1.x, p2.x, fraction);
    this.yC = lerp(p1.y, p2.y, fraction);
  }


  // Compute the next point to head towards, taking direction into account.
  int nextIndex(int index) {
    assert(path.length>0);
    assert(index>=0 && index<path.length);
    int next =  this.goForward ? (index+1)%this.path.length : (index==0 ? this.path.length-1 : (index-1));
    assert(next>=0 && next<path.length);
    return next;
  }

  // Switch direction, keeping current position
  void switchDirection() {
    assert(MOVEMENT_INCREMENT>=0.0 && MOVEMENT_INCREMENT<1.0);
    assert(fraction>=0.0 && fraction<=1.0);
    curIndex = nextIndex(curIndex);
    fraction = 1.0-fraction;
    goForward = !goForward;
  }

  abstract void draw();
}