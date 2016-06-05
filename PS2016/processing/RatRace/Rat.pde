class Rat extends AnimatedObject {
  color c;
  int[][] paths;
  int curPath=-1;

  Rat(float w, float h, Point[] points, int[][] paths, color c) {
    super(w, h, points);
    this.c = c;
    this.paths = paths;
  }

  void draw() {
    if (this.visible) {
      this.move();
      //println(this.w + ", " + this.h);
      stroke(c);
      fill(c);
      ellipse(this.xC, this.yC, this.w, this.h);
    }
  }

  void pointCrossed(int point) {
    println("point crossed: " + point);
    if (currentPathComplete(point)) { 
      stop();
      int[] nextPath = getNextPath();
      if (nextPath!=null) {
        super.start(nextPath, 0.0);
      }
    }
  }

  void start() {
    int[] nextPath = getNextPath();
    if (nextPath!=null) {
      super.start(nextPath, 0.0);
    }
  }

  boolean currentPathComplete(int lastPointCrossed) {
    // TODO: replace by more sophisticated version once we start switching 
    // path direction.
    return (lastPointCrossed==0); // completed the circle.
  }

  int[] getNextPath() {
    int[] nextPath = null;
    if (paths.length > (curPath+1)) {
      nextPath = paths[++curPath];
    }
    return nextPath;
  }
}