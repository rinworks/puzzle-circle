class Arena {
  int nx;
  int ny;
  int h;
  int w;
  Point points[];
  ArrayList<AnimatedObject> critters;

  Arena(int nx, int ny, int w, int h) {
    this.nx = nx;
    this.ny = ny;
    this.w = w;
    this.h = h;
    critters = new ArrayList<AnimatedObject>();
    points = new Point[nx*ny];
    assert(nx>=2 && ny>=2);
    // Initialize points in row-major order...
    float dx = 1.0*w/(nx-1);
    float dy = 1.0*h/(ny-1);
    float cornerX = dx;
    float cornerY = dy;
    int ii = 0;
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
    background(128);
    for (AnimatedObject c : critters) {
      // TODO: collision avoidance...
      c.draw();
    }
  }
}