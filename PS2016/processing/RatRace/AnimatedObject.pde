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
  final float MOVEMENT_INCREMENT = 0.03; // Fractional amount to move between points each frame.
  final float TURN_SPEED = 0.1;
  float xC=0;
  float yC=0;
  float w=0;
  float h=0;
  float a=0; // angle in radians.
  float aPrev=0; // angle from previous frame.
  Point[] points=null;
  int[] path=null; // indexes of points in path, can be repeats.
  boolean visible=false;
  int curIndex=0; // Index into current path, not into (global) points.
  boolean goForward=true; // increasing index if true, decreasing index if false.
  float fraction=0.0; // Fractional amount moved between curIndex and next index;
  boolean moving=false;
  float curDx=0.0; // incremental delta x
  float curDy=0.0; // incremental delta y. Current slope is (curDy/curDx), but note that either curDx or curDy can be 0.

  // These may be directly set by anyone, and will have immediate effect.
  boolean holdPosition=false; // Prevents progress along path, but still does random flucations in position.
  boolean freeze=false; // Completely halts motion of any kind. Superceeds holdPosition if true.

  public final float POSITION_PERTURBATION_AMPLITUDE = 40.0; // pixels // TODO: make it 2xwidth of object
  public final float POSITION_PERTURBATION_OFFSET = 0.0; // pixels
  public final float POSITION_PERTURBATION_SCALE = 0.02; // pixels

  public final float SPEED_PERTURBATION_AMPLITUDE = 0.85; // pixels
  public final float SPEED_PERTURBATION_OFFSET = 0.849; // pixels
  public final float SPEED_PERTURBATION_SCALE = 0.05; // pixels

  RandomPerturbation pX = new RandomPerturbation(POSITION_PERTURBATION_AMPLITUDE, POSITION_PERTURBATION_OFFSET, POSITION_PERTURBATION_SCALE);
  RandomPerturbation pY = new RandomPerturbation(POSITION_PERTURBATION_AMPLITUDE, POSITION_PERTURBATION_OFFSET, POSITION_PERTURBATION_SCALE);
  RandomPerturbation pSpeed = new RandomPerturbation(SPEED_PERTURBATION_AMPLITUDE, SPEED_PERTURBATION_OFFSET, SPEED_PERTURBATION_SCALE);

  AnimatedObject(float w, float h, Point[] points) {
    //this.xC = xC;
    //his.yC = yC;
    this.w = w;
    this.h = h;
    this.points = points;
  }

  // Start at a particular point (index into points), oriented at a particular angle.
  // Note: Old holdPosition and freeze values are preserved.
  void start(int[] path) {
    this.path = path;
    this.visible=true;
    this.curIndex = 0;
    this.fraction = 0.0;
    this.goForward = true;
    Point p = this.points[path[this.curIndex]];
    this.xC = p.x + pX.nextValue();
    this.yC = p.y + pY.nextValue();
    this.moving = true;
    this.curDx = this.curDy = 0.0; // Slope is Dx/Dy, so is undefined at this stage.
  }

  // Note: holdPosition and freeze values are preserved.
  void stop() {
    this.moving = false;
    this.visible = false;
  }

  // Attempt to move autonomously, taking the position of
  // other objects into account.
  void move() {

    if (!moving || freeze || path==null || path.length==0) {
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
    if (!this.holdPosition) {
      assert(MOVEMENT_INCREMENT>=0.0 && MOVEMENT_INCREMENT<1.0);
      assert(fraction>=0.0 && fraction<=1.0);
      float speed  = pSpeed.nextValue();
      float deltaFrac = MOVEMENT_INCREMENT*speed*speed*speed*speed;

      // Special case - cur and next indices are same - in this case we 
      // speed up the progess so that we don't pause too long at the point.
      if (path[curIndex] == path[next]) {
        deltaFrac = 0.5; // in 4 frames(?) we should move to next point.
      }

      this.fraction += deltaFrac;
    }
    if (this.fraction > 1.0) {
      // We've over stepped, move to next index
      curIndex = next;
      next = nextIndex(curIndex);
      this.fraction -= 1.0;
      assert(fraction>=0.0 && fraction<=1.0);
      this.pointCrossed(curIndex);
    }

    //
    // Interpolate position and estimated current slope (represented by curDx and curDy)
    //
    Point p1 = points[path[curIndex]];
    Point p2 = points[path[next]];
    float next_xC = lerp(p1.x, p2.x, fraction) + pX.nextValue();
    float next_yC = lerp(p1.y, p2.y, fraction) + pY.nextValue();
    this.curDx = next_xC - this.xC;
    this.curDy = next_yC - this.yC;
    this.xC = next_xC;
    this.yC = next_yC;

    //
    // Update orientiation angle, making it tend towards the slope...
    //
    float hyp = sqrt(this.curDx*this.curDx + this.curDy*this.curDy);
    if (hyp>0.01) {
      float angle = acos(this.curDx/hyp); // this is between 0 and PI
      float aFrom = this.a;
      //println("PRE:aFrom,a " + aFrom + "," + angle);
      String xx = ":: " + aFrom + ":" + angle;
      assert(angle>=0 && angle <=PI);
      assert(aFrom>=-PI && aFrom<=PI);
      if (this.curDy<-0.01) {
        angle = -angle;
      }
      if (abs(a-angle)>PI) {
        if (angle<0.0) {
          angle = 2*PI+angle;
          assert(aFrom>=0);
        } else {
          assert(aFrom<0);
          aFrom = 2*PI+aFrom;
          assert(aFrom>=0);
        }
      }
      //if (abs(a-angle)>PI) {
      // println("a,angle:" + a + "," + angle + xx);
      // assert(false);
      //}
      this.aPrev = a;
      this.a = normalizeAngle(lerp(aFrom, angle, TURN_SPEED));
    }
  }

  // Return a value between +/- PI 
  float normalizeAngle(float a) {
    if (a>0) {
      a = a % (2*PI);
      if (a>PI) {
        a = -(2*PI-a);
      }
    } else {
      a = - ((-a) % (2 * PI));
      if (a < -PI) {
        a = 2*PI+a;
      }
    }
    assert(a>=-PI && a<=PI);
    return a;
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
  abstract void pointCrossed(int point);
}