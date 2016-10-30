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

  // ****************   TO GENERATE MULTIPLE VERSIONS ***************
  int index=0; // Change this from 0-4 to generate multiple versions of puzzles
  boolean permute = false; // Set to true to generate the (scrambled) puzzle - else the answer.

  CellHelper helper = new CellHelper();
  int rows=30;
  int cols=30;

  Grid g = helper.createGrid(rows, cols);
  if (index==0) genPuzzle1(helper, g);
  else if (index==1) genPuzzle2(helper, g);
  else if (index==2) genPuzzle3(helper, g);
  else if (index==3) genPuzzle4(helper, g);
  else if (index==4) genPuzzle5(helper, g);
  else assert(false);
  int count = helper.countHighlightedCells(g);
  println("PUZZLE ID: " + (index+1));
  println("HILIGHTED CELL COUNT: " + count);
  println("SUM OF DIGITS: " + helper.sumDigits(count));
  g.draw();
  save("output/countCells"+(index+1)+ (permute? "" : "ans") + ".png");
}

void genPuzzle1(CellHelper helper, Grid g) {
  int smallW = 3;
  int smallH = 4;

  // Initial big yellow
  helper.highlightCells(g, 0, 0, g.rows, g.cols, true);

  // First big white with an internal yellow
  helper.highlightCells(g, 0, 5, 10, 13, false);
  helper.highlightCells(g, 0+3, 5+3, smallW, smallH, true);

  // Second big white with two internal yellows.
  helper.highlightCells(g, 15, 10, 12, 14, false);
  helper.highlightCells(g, 15+3, 10+5, smallW, smallH, true);
  helper.highlightCells(g, 15+9, 10+8, smallW, smallH, true);

  // Two isolated whites, 2nd one touching
  helper.highlightCells(g, 20, 5, smallW, smallH, false);
  helper.highlightCells(g, 5, 18, smallW, smallH, false);
}

void genPuzzle2(CellHelper helper, Grid g) {
  int smallW = 4;
  int smallH = 2;

  // Initial big yellow
  helper.highlightCells(g, 0, 0, g.rows, g.cols, true);

  // First big white an internall yellow
  helper.highlightCells(g, 2, 0, 12, 16, false);
  helper.highlightCells(g, 2+4, 0+4, smallW, smallH, true);

  // Second big white and internal yellow
  helper.highlightCells(g, 10, 18, 17, 10, false);
  helper.highlightCells(g, 10+3, 18+5, smallW, smallH, true);
  helper.highlightCells(g, 10+9, 18+8, smallW, smallH, true);

  // Two small isolated whites, second one touching a bigger white
  helper.highlightCells(g, 20, 5, smallW, smallH, false);
  helper.highlightCells(g, 14, 14, smallW, smallH, false);
}

void genPuzzle3(CellHelper helper, Grid g) {
  int smallW = 5;
  int smallH = 4;

  // Initial big yellow
  helper.highlightCells(g, 0, 0, g.rows, g.cols, true);

  // First big white an internall yellow
  helper.highlightCells(g, 12, 0, 12, 13, false);
  helper.highlightCells(g, 12+4, 0+4, smallW, smallH, true);

  // Second big white and two internal yellows, 2nd one touching
  helper.highlightCells(g, 5, 19, 17, 10, false);
  helper.highlightCells(g, 5+3, 19+5, smallW, smallH, true);
  helper.highlightCells(g, 5+12, 19+3, smallW, smallH, true);

  // Two small isolated whites, second one touching a bigger white
  helper.highlightCells(g, 7, 5, smallW, smallH, false);
  helper.highlightCells(g, 4, 10, smallW, smallH, false);
}

void genPuzzle4(CellHelper helper, Grid g) {
  int smallW = 3;
  int smallH = 5;

  // Initial big yellow
  helper.highlightCells(g, 0, 0, g.rows, g.cols, true);

  // First big white an internall yellow
  helper.highlightCells(g, 12, 3, 15, 12, false);
  helper.highlightCells(g, 12+4, 3+4, smallW, smallH, true);

  // Second big white and two internal yellows, 2nd one touching
  helper.highlightCells(g, 5, 20, 16, 13, false);
  helper.highlightCells(g, 5+3, 20+5, smallW, smallH, true);
  helper.highlightCells(g, 5+12, 20+3, smallW, smallH, true);

  // Two small isolated whites, second one touching a bigger white
  helper.highlightCells(g, 5, 7, smallW, smallH, false);
  helper.highlightCells(g, 23, 15, smallW, smallH, false);
}

void genPuzzle5(CellHelper helper, Grid g) {
  int smallW = 2;
  int smallH = 5;

  // Initial big yellow
  helper.highlightCells(g, 0, 0, g.rows, g.cols, true);

  // First big white an internall yellow
  helper.highlightCells(g, 2, 12, 10, 18, false);
  helper.highlightCells(g, 2+4, 12+4, smallW, smallH, true);

  // Second big white and two internal yellows, 2nd one touching
  helper.highlightCells(g, 13, 3, 15, 13, false);
  helper.highlightCells(g, 13+10, 3+6, smallW, smallH, true);
  helper.highlightCells(g, 13+0, 3+3, smallW, smallH, true);

  // Two small isolated whites, second one touching a bigger white
  helper.highlightCells(g, 16, 20, smallW, smallH, false);
  helper.highlightCells(g, 23, 16, smallW, smallH, false);
}