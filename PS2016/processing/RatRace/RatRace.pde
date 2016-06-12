

color brown = color(205, 133, 63);
color black = color(32, 32, 32);
color white = color(250, 250, 250);
color gray = color(200, 200, 200);
color green = color(128, 250, 128);
color darkGreen = color(100, 200, 100);
color pink = color(255, 100, 100); // eyes
color yellow = color(255, 255, 0);
final int HEIGHT = 500;
final int WIDTH = 500;
boolean saveFrames = true; // will be set to false when all rats are done

Orchestrator o;
void setup() {
  size(500, 500);
  ellipseMode(CENTER);
  rectMode(CENTER);
  setupArena();
}

void draw() {
  o.draw();
  if (saveFrames) {
    saveFrame("output/frame######.png");
  }
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
  randomSeed(1);
  noiseSeed(1);
  Arena a = new Arena(3, 3, 100, 50, 300, 350);
  int[] pathW = {1, 4, 7, 5, 9, 5, 9, 3, 9, 5, 7, 5, 7, 4};
  int[] pathH = {1, 4, 7, 4, 5, 4, 6, 3, 9, 6, 4, 5, 4};
  int[] pathO = {1, 3, 9, 6, 9, 7, 4, 7};
  int[] pathM = {1, 7, 1, 4, 1, 5, 3, 9, 3, 5, 3, 5};
  int[] pathV = {1, 8, 3, 8, 3, 8, 1};
  int[] pathE = {1, 3, 1, 4, 5, 4, 7, 4, 7, 9, 7, 8, 7};
  int[] pathD = {1, 2, 6, 2, 6, 8, 7, };
  int[] pathY = {1, 5, 3, 5, 1, 5, 8, 5, 8, 5, 1, 5, 1};
  int[] pathC = {1, 3, 1, 2, 1, 7, 9, 7, 8, 7};
  int[] pathS = {1, 3, 1, 4, 1, 4, 6, 9, 6, 9, 7, 9, 6, 4};
  int[] pWait = {0, 0};
  int[] pStart = {0, 1};
  int[] pStop = {1, 0};
  int[] pT = {1, 0, 0};// T==transition. Trick: because it is length > 2, it will only complete when it is a full cycle, so it goes home(0) and comes back to 1.
  //int[][] rat1Paths = {pWait, pWait, pStart, pathW, pT, pathH, pT, pathO, pStop};
  //int[][] rat2Paths = {pWait, pStart, pathM, pT, pathO, pT, pathV, pT, pathE, pT, pathD, pStop};
  //int[][] rat3Paths = {pWait, pWait, pWait, pStart, pathM, pT, pathY, pStop};
  //int[][] rat4Paths = {pStart, pathC, pT, pathH, pT, pathE, pT, pathE, pT, pathS, pT, pathE, pStop};

  int[][] rat1Paths = {pWait, pStart, pathW, pT, pathH, pT, pathO, pStop};
  int[][] rat2Paths = {pWait, pStart, pathM, pT, pathO, pT, pathV, pT, pathE, pT, pathD, pStop};
  int[][] rat3Paths = {pWait, pStart, pathM, pT, pathY, pStop};
  int[][] rat4Paths = {pWait, pStart, pathC, pT, pathH, pT, pathE, pT, pathE, pT, pathS, pT, pathE, pStop};

  int[] pathVert = {1, 4, 7};
  int[] pathDiag = {1, 5, 9};
  int[][] rat1Test = {pathVert, pathDiag};


  Cheese[] cheeses = initializeCheeses(a);
  for (Cheese c : cheeses) {
    a.addCritter(c);
  }

  Rat r1 = new Rat(ratWidth, ratHeight, a.points, rat1Paths, black);
  a.addCritter(r1); 
  Rat r2 = new Rat(ratWidth, ratHeight, a.points, rat2Paths, white);
  a.addCritter(r2);
  Rat r3 = new Rat(ratWidth, ratHeight, a.points, rat3Paths, gray);
  a.addCritter(r3); 
  Rat r4 = new Rat(ratWidth, ratHeight, a.points, rat4Paths, brown);
  a.addCritter(r4);

  Rat[] rats = {r1, r2, r3, r4};
  //Rat[] rats = {r3};

  this.o = new Orchestrator(a, rats, cheeses);
  this.o.start();
}

// Initialize cheese to go on locations
// 3,5,6,7,8,9
Cheese[] initializeCheeses(Arena a) {
  int cheeseH = 35;
  int cheeseW = 35;
  Cheese[] cheeses = {
    new Cheese(cheeseH, cheeseW, a.points, 3), 
    new Cheese(cheeseH, cheeseW, a.points, 5), 
    new Cheese(cheeseH, cheeseW, a.points, 6), 
    new Cheese(cheeseH, cheeseW, a.points, 7), 
    new Cheese(cheeseH, cheeseW, a.points, 8), 
    new Cheese(cheeseH, cheeseW, a.points, 9)
  };

  return cheeses;
}