class Arena {
  int nx;
  int ny;
  int h;
  int w;
  Point points[];
  ArrayList<AnimatedObject> critters;
  int cornerX;
  int cornerY;

  // "Home" is a small region from which the critters emerge. It is located on the upper-left hand corner of the grid.
  final int HOME_HEIGHT = 300; // Off screen
  final int HOME_WIDTH = 20;
  final int HOLE_DISPLACEMENT = 35;

  Arena(int nx, int ny, int cornerX, int cornerY, int w, int h) {
    this.nx = nx;
    this.ny = ny;
    this.w = w;
    this.h = h;
    this.cornerX = cornerX;
    this.cornerY = cornerY;
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
        //println(p);
        points[ii++] = p;
      }
    }
  }

  void addCritter(AnimatedObject critter) {
    critters.add(critter);
  }

  void draw() {
    background(green);
    drawBankPre();
    for (AnimatedObject c : critters) {
      // TODO: collision avoidance...
      c.draw();
    }
    drawBankPost();
  }

  void drawBankPre() {
    //Point pHome = points[0];
    noStroke();
    fill(darkGreen);
    rect(width/2, this.cornerY-HOLE_DISPLACEMENT-5, width, this.cornerY);
    fill(0);
    ellipse(this.cornerX, this.cornerY-HOLE_DISPLACEMENT, 50, 30);
  }

  void drawBankPost() {
    noStroke();
    //fill(0,128);
    //ellipse(this.cornerX, this.cornerY-HOLE_DISPLACEMENT-5, 40, 20);
    fill(darkGreen);
    rect(this.cornerX, this.cornerY-HOLE_DISPLACEMENT-10-50, 100, 100);
  }

  // Display status message at position i.
  void displayStatus(int i, String s) {
    //text(s, 10+(i*WIDTH/2), HEIGHT-50);
  }
}