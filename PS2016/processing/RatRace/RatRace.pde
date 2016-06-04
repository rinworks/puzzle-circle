Arena a;


void setup() {
  size(400,400);
  ellipseMode(CENTER);
  setupArena();
}

void draw() {
  a.draw();
}


void setupArena() {
  a = new Arena(2, 2, 100, 100);
  int[] path1 = {0,1, 0, 1};
  Rat r1 = new Rat(10, 10, a.points, path1);
  a.addCritter(r1);
  r1.start(0,0.0);
}