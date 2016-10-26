// //<>// //<>// //<>//
// Module: countCells.PDE
// Description: Main file for Count Cells puzzle generator.
//  CountCells is based on an Excel-based Count Cells puzzle JMJ created for Audubon Puzzle Circle
//
// History:
//	October 2016 - JMJ copied from TileWorld code (uses the GraphicsBase code)
//
// General notes:
//     Grid coordinates: (i, j) are like rows of an array/matrix. So i is vertical,
//     with increasing i going downwards.
//
Utils gUtils = new Utils();

void setup() {
  size(1000, 1000);
  //println(PFont.list());
  //size(2000, 2000);

  // To recreate a specific puzzle, make a note of the printed seed value and 
  // set seed to that printed seed value (comment out the call to round(random(...))).
  long baseSeed = 156595968; // round(random(MAX_INT));
  //long baseSeed = round(random(MAX_INT));

  long[] seeds = {
    baseSeed, 
    baseSeed+1, 
    baseSeed+2, 
    baseSeed+3, 
    baseSeed+4
  };

  // ****************   TO GENERATE MULTIPLE VERSIONS ***************
  int index=1; // Change this from 0-4 to generate multiple versions of puzzles
  boolean permute = false; // Set to true to generate the (scrambled) puzzle - else the answer.

  long seed = seeds[index];
  println("SEED: " + seed);
  randomSeed(seed);

  CellHelper helper = new CellHelper();
  int rows=30;
  int cols=30;

  Grid g = helper.createGrid(rows, cols);
  if (index==1) genPuzzle1(helper, g);
  //else if (index==2) genPuzzle2(helper, g);
  //else if (index==3) genPuzzle3(helper, g);
  //else if (index==4) genPuzzle4(helper, g);
  else assert(false);
  int count = helper.countHighlightedCells(g);
  println("HILIGHTED CELL COUNT: " + count);
  println("SUM OF DIGITS: " + helper.sumDigits(count));
  g.draw();
  save("output/countCells"+(index+1)+ (permute? "" : "ans") + ".png");
}

void genPuzzle1(CellHelper helper, Grid g) {
  int smallW = 3;
  int smallH = 4;

  helper.highlightCells(g, 0, 0, g.rows, g.cols, true);
  helper.highlightCells(g, 0, 5, 10, 15, false);
  helper.highlightCells(g, 20, 5, smallW, smallH, false);
  helper.highlightCells(g, 15, 10, 12, 18, false);
  helper.highlightCells(g, 0+3, 5+3, smallW, smallH, true);
  helper.highlightCells(g, 15+3, 10+5, smallW, smallH, true);
  helper.highlightCells(g, 15+9, 10+8, smallW, smallH, true);
}