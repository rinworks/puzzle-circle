class Rat extends AnimatedObject {
  final int HOME_POINT = 0; // Index of the hole aming the global Point array of points.
  color c;
  int[][] paths;
  int curPath=-1;
  Cheese cheeseBeingEaten=null;
  int eatingCountdown=0;
  int dormantStartMS=0; // Millis() at the point the moust started dormant mode.
  Rat(float w, float h, Point[] points, int[][] paths, color c) {
    super(w, h, points);
    this.c = c;
    this.paths = paths;
  }

  void draw() {

    // Stop eating of neecessary.
    if (this.cheeseBeingEaten!=null) {
      if (this.eatingCountdown-- <= 0) {
        this.endEatingCheese();
      }
    }

    if (this.visible) {
      this.move();
      //println(this.w + ", " + this.h);

      pushMatrix();
      translate(this.xC, this.yC);
      rotate(a);
      //println(degrees(a));

      // Eyes
      stroke(pink);
      fill(pink);
      ellipse(this.h/2, 0, this.w/1.75, this.w/1.75);

      //  Body and head
      stroke(c);
      fill(c);
      ellipse(0, 0, this.h, this.w); // Note the rat is wide PERPENDICULAR to the direction of travel
      triangle(this.h/3, -this.w/4, 
        this.h, 0, 
        this.h/3, this.w/4);     

      // tail
      strokeWeight(2);
      pushMatrix();
      rotate(3*(aPrev-a)); // Tail silghtly follows the angle of turn
      line(-this.h, 0, -this.w/2, 0);
      popMatrix();
      popMatrix();
    }
  }

  void pointCrossed(int point) {
    //println("point crossed: " + point);

    if (this.path[point] == HOME_POINT) {
      // We're crossing into the home point. Let's freeze the rat for starters...
      this.freeze = true;
      this.dormantStartMS= millis();
    }
    if (currentPathComplete(point)) { 
      // We're done with the current path, start the next one...
      stop();
      int[] nextPath = getNextPath();
      if (nextPath!=null) {
        super.start(nextPath);
      }
    } else if (this.cheeseBeingEaten == null) {
      // Check if we should eat cheese...
      Cheese c = o.tryGetCheeseAtPoint(this.path[point]);
      if (c!=null && c.visible && !c.beingEaten) {
        // Got one! Let's start eating it.
        beginEatingCheese(c);
      }
    }
  }

  // Private; sets up cheese and rat for eating the cheese.
  void beginEatingCheese(Cheese c) {
    final int MIN_EATING_COUNTDOWN = 25;
    final int MAX_EATING_COUNTDOWN = 50;
    assert(this.cheeseBeingEaten == null && !c.beingEaten);
    this.cheeseBeingEaten = c;
    this.eatingCountdown = (int) random(MIN_EATING_COUNTDOWN, MAX_EATING_COUNTDOWN);
    this.holdPosition = true; // makes it stay on location with a little bit of jiggling around.
    c.beingEaten = true;
    c.freeze = false; // makes it move around.
  }

  // Private; Cleans up afte cheese eating is complete.
  void endEatingCheese() {
    Cheese c = this.cheeseBeingEaten;
    assert(c != null && c.beingEaten && c.visible);
    this.cheeseBeingEaten = null;
    this.eatingCountdown = 0;
    this.holdPosition = false; // Begin moving again...
    c.beingEaten = false;
    c.visible = false;
    c.freeze = true;
  }

  void start() {
    int[] nextPath = getNextPath();
    if (nextPath!=null) {
      super.start(nextPath);
    }
  }

  boolean currentPathComplete(int lastPointCrossed) {
    // TODO: replace by more sophisticated version once we start switching 
    // path direction.
    // If length is two we pick the 2nd (last) point, otherwise we assume
    // circle-detection and pick the first point
    return lastPointCrossed == ((path.length==2)? 1 : 0);
  }

  int[] getNextPath() {
    int[] nextPath = null;
    if (paths.length > (curPath+1)) {
      nextPath = paths[++curPath];
    }
    return nextPath;
  }

  // Am I in the hole/home but still have points to visit?
  boolean isDormant() {
    return (this.path[this.curIndex]==HOME_POINT) && ((curPath+1) < paths.length );
  }

  // Am I on the field?
  boolean onField() {
    return this.path[this.curIndex]!=HOME_POINT;
  }

  int remainingPointCount() {
    int pointsLeft = 0;
    // Add points from current path...
    if (this.curIndex < this.path.length) {
      pointsLeft += this.path.length-this.curIndex;
    }
    // Add points from remaining paths...
    for (int i=this.curPath+1; i<paths.length; i++) {
      pointsLeft += this.paths[i].length;
    }
    return pointsLeft;
  }
}