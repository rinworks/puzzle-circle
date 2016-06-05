Arena a;
color brown = color(205, 133, 63);
color black = color(32, 32, 32);
color white = color(250, 250, 250);
color gray = color(200, 200, 200);
color green = color(128, 250, 128);
color darkGreen = color(100, 200, 100);
color pink = color(255, 100, 100); // eyes


void setup() {
  size(500, 500);
  ellipseMode(CENTER);
  rectMode(CENTER);
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
  int ratHeight = 40;
  int ratWidth = 25;
  a = new Arena(3, 3, 100, 50, 300, 300);
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
  int[] pWait = {0,0,0,0,0};
  int[] pStart = {0,1};
  int[] pStop = {1,0};
  int[] pT = {1,0,0};// T==transition. Trick: because it is length > 2, it will only complete when it is a full cycle, so it goes home(0) and comes back to 1.
  int[][] rat1Paths = {pWait, pWait, pStart, pathW, pT, pathH, pT, pathO, pStop};
  int[][] rat2Paths = {pWait, pStart, pathM, pT, pathO, pT, pathV, pT, pathE, pT, pathD, pStop};
  int[][] rat3Paths = {pWait, pWait, pWait, pStart, pathM, pT, pathY, pStop};
  int[][] rat4Paths = {pStart, pathC, pT, pathH, pT, pathE, pT, pathE, pT, pathS, pT, pathE, pStop};

  int[] pathVert = {1,4,7};
  int[] pathDiag = {1,5,9};
  int[][] rat1Test = {pathVert, pathDiag};
  Rat r1 = new Rat(ratWidth, ratHeight, a.points, rat1Paths, black);
  a.addCritter(r1); 
  Rat r2 = new Rat(ratWidth, ratHeight, a.points, rat2Paths, white);
  a.addCritter(r2);
  Rat r3 = new Rat(ratWidth, ratHeight, a.points, rat3Paths, gray);
  a.addCritter(r3); 
  Rat r4 = new Rat(ratWidth, ratHeight, a.points, rat4Paths, brown);
  a.addCritter(r4);

  r1.start();
  r2.start();
  r3.start();
  r4.start();

}