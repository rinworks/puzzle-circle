class Arena {
  int nx;
  int ny;
  int h;
  int w;
  Point points[];
  ArrayList<AnimatedObject> critters;
  
  // "Home" is a small region from which the critters emerge. It is located on the upper-left hand corner of the grid.
  final int HOME_HEIGHT = 30;
  final int HOME_WIDTH = 20;

  Arena(int nx, int ny, int cornerX, int cornerY, int w, int h) {
    this.nx = nx;
    this.ny = ny;
    this.w = w;
    this.h = h;
    critters = new ArrayList<AnimatedObject>();
    points = new Point[1+nx*ny]; // 1 for the initial "home" point;

    // Initialize "home" point.
    Point pHome = new Point(cornerX, cornerY-HOME_HEIGHT);
    int ii = 0;
    points[ii++]=pHome;
    
    // Initialize remaining points in row-major order...
    assert(nx>=2 && ny>=2);
    float dx = 1.0*w/(nx-1);
    float dy = 1.0*h/(ny-1);
    for (int j=0; j<ny; j++) {
      for (int i=0; i<nx; i++) {
        Point p = new Point(cornerX+i*dx, cornerY+j*dy);
        println(p);
        points[ii++] = p;
      }
    }
  }

  void addCritter(AnimatedObject critter) {
    critters.add(critter);
  }

  void draw() {
    background(green);
    for (AnimatedObject c : critters) {
      // TODO: collision avoidance...
      c.draw();
    }
  }
}