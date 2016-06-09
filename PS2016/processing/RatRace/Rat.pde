class Rat extends AnimatedObject {
  color c;
  int[][] paths;
  int curPath=-1;
  Cheese cheeseBeingEaten=null;
  int eatingCountdown=0;

  Rat(float w, float h, Point[] points, int[][] paths, color c) {
    super(w, h, points);
    this.c = c;
    this.paths = paths;
  }

  void draw() {
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
      line(-this.h, 0, 0,0);
      popMatrix();
    }
  }

  void pointCrossed(int point) {
    //println("point crossed: " + point);
    if (currentPathComplete(point)) { 
      stop();
      int[] nextPath = getNextPath();
      if (nextPath!=null) {
        super.start(nextPath);
      }
    }
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
}