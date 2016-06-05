Arena a;
color brown = color(205, 133, 63);
color black = color(32, 32, 32);
color white = color(250, 250, 250);
color gray = color(200, 200, 200);
color green = color(128, 250, 128);

void setup() {
  size(500, 500);
  ellipseMode(CENTER);
  setupArena();
}

void draw() {
  a.draw();
}

// Point index:
//  0 <- "home"
//  1 2 3
//  4 5 6
//  7 8 9
// WHO MOVED MY CHEESE

void setupArena() {
  int ratHeight = 20;
  int ratWidth = 10;
  a = new Arena(3, 3, 20, 20, 300, 300);
  int[] pathW = {1, 7, 5, 9, 3, 9, 5, 7};
  int[] pathH = {1, 7, 4, 6, 3, 9, 6, 4};
  int[] pathO = {1, 3, 9, 7};
  int[] pathM = {1, 7, 1, 5, 3, 9, 3, 5};
  int[] pathV = {1, 8, 3, 8};
  int[] pathE = {1, 3, 1, 4, 5, 4, 7, 9, 7};
  int[] pathD = {1, 2, 6, 8, 7};
  int[] pathY = {1, 5, 8, 5, 3, 5};
  int[] pathC = {1, 3, 1, 7, 9, 7};
  int[] pathS = {1, 3, 1, 4, 6, 9, 7, 9, 6, 4};
  int[][] rat1Paths = {pathW, pathH, pathO};
  int[][] rat2Paths = {pathM, pathO, pathV, pathE, pathD};
  int[][] rat3Paths = {pathM, pathY};
  int[][] rat4Paths = {pathC, pathH, pathE, pathE, pathS, pathE};
  


  Rat r1 = new Rat(ratWidth, ratHeight, a.points, rat4Paths, gray);
  a.addCritter(r1); 
  //Rat r2 = new Rat(ratWidth, ratHeight, a.points, pathO, white);
  //a.addCritter(r2);

  r1.start();
  //r2.start(0, 0.0);
}