// Chese extends AnimatedObject, though it doesn't really move, just becomes visible/unvisible.
class Cheese extends AnimatedObject {
  int point; // index into Points - location of this cheese
  int [] path; // not really path - just one point.
  Point[] holeCenters;
  float[] holeRadii;
  final int DISPLACEMENT = 10;

  Cheese(float w, float h, Point[] points, int point) {
    super(w, h, points);
    this.point = point;
    this.path = new int[1];
    this.path[0] = point;
    setupHoles();
  }

  void draw() {
     if (this.visible) {
      this.move();
      //println(this.w + ", " + this.h);

      pushMatrix();
      translate(this.xC, this.yC+DISPLACEMENT);
      //rotate(a);
      //println(degrees(a));
      noStroke();
      fill(yellow);
      //rect(this.xC, this.yC, this.w, this.h);
      rect(0, 0, this.w, this.h);

      drawHoles();
      
      popMatrix();
    }
  }

  // Add cheese holes. Assumes origin is center of cheese.
  void setupHoles() {
    int numHoles =  (int) random(5,8);
    holeCenters = new Point[numHoles];
    holeRadii = new float[numHoles];
    assert(holeCenters.length == holeRadii.length);
    for (int i=0; i<holeCenters.length; i++) {
      holeCenters[i] = new Point(random(-this.w/2, this.w/2),  random(-this.h/2, this.h/2-DISPLACEMENT));
      holeRadii[i] = random(this.w/5,this.w/3);
    }
  }
  
    // Add cheese holes. Assumes origin is center of cheese.
  void drawHoles() {
    fill(green);
    for (int i=0; i<holeCenters.length; i++) {
      ellipse(holeCenters[i].x, holeCenters[i].y, holeRadii[i], holeRadii[i]);
    }
  }

  void pointCrossed(int point) {
  }

  void start() {   
    super.start(this.path);
  }
}