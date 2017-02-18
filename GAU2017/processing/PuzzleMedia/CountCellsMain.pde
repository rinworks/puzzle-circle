// Module: CountCellsMain - code to generate  media needed for the CountCells  Puzzle //<>// //<>// //<>//
// History:
//  Feb 2017  - JMJ created, adapted from earlier code I wrote for EAS and Puzzle Safari puzzles
// //<>// //<>// //<>//
// Module: countCells.PDE
// Description: Main file for Count Cells puzzle generator.
//  CountCells is based on an Excel-based Count Cells puzzle JMJ created for Audubon Puzzle Circle
//
// History:
//  October 2016 - JMJ copied from TileWorld code (uses the GraphicsBase code)
//
// General notes:
//     Grid coordinates: (i, j) are like rows of an array/matrix. So i is vertical,
//     with increasing i going downwards.
//

class CountCellsMain {

  final String PUZZLE_TYPE = "countCells";
  final int[][] puzzleParams = {
    {9, 10, 8, 8, 5, 5}, // w1, h1, w2, h2, wOv, hOv
    {9, 10, 9, 8, 5, 4}, 
    {9, 9, 8, 8, 5, 4}, 
    {9, 9, 8, 8, 4, 4}, 
    {9, 10, 8, 8, 5, 4}, 
    {9, 9, 8, 8, 4, 3}, 
    {9, 8, 8, 7, 3, 3}, 
    {8, 8, 8, 7, 3, 3}, 
    {6, 7, 7, 8, 2, 2}, 
    {9, 7, 8, 8, 2, 3}, 

  };

  void genAllMedia() {
    Table infoTable = gUtils.newInfoTable();
    CellHelper helper = new CellHelper();
    for (int[] p : puzzleParams) {
      Grid g = genOverlappingRectsPuzzle(helper, p[0], p[1], p[2], p[3], p[4], p[5]);
      int count = helper.countHighlightedCells(g);
      String sol = "" + count; // solution
      String IN  = gSolutions.lookupIN(sol); // We expect the string version of the count to be a valid solution!
      //println("PUZZLE ID: " + IN);
      println("HILIGHTED CELL COUNT: " + count);
      //println("SUM OF DIGITS: " + helper.sumDigits(count));
      background(WHITE_BACKGROUND);
      g.draw();
      String fileStub = gUtils.genMediaFilenameStub(PUZZLE_TYPE, IN);
      save(fileStub +  ".png");
      gUtils.addInstanceToTable(infoTable, IN, sol);
    }
    gUtils.saveInfoTable(infoTable, PUZZLE_TYPE);
  }

  // A parametrized puzzle generator. It creates a pattern consiting of two overlapping rectangles. The rectangles
  // are only 1 cell wide. The overlapping area, however, is a solid rectangle:
  //    . . . . .
  //    .       .
  //    .   . . . . .
  //    .   . . .   .
  //    . . . . .   .
  //        .       .
  //        . . . . .
  //
  Grid genOverlappingRectsPuzzle(CellHelper helper, int w1, int h1, int w2, int h2, int wOv, int hOv) {
    // Validate params...
    {
      boolean  valid = true;
      if (w1<1 || h1<1) {
        System.err.println("rect1 too small (" + w1 + "," + h1 + ")");
        valid = false;
      }
      if (w2<1 || h2<1) {
        System.err.println("rect2 too small (" + w2 + "," + h2 + ")");
        valid = false;
      }
      if (wOv<0 || hOv<0) {
        System.err.println("Invalid overlap rect (" + wOv + "," + hOv + ")");
        valid = false;
      }
      if (wOv>min(w1, w2) || hOv>min(h1, h2)) {
        System.err.println("Overlap rect too small (" + wOv + "," + hOv + ")");
        valid = false;
      }
      if (!valid) {
        throw new IllegalArgumentException("Invalid regions specified");
      }
    }
    // Create a grid of just the right size
    int rows=h1 + h2 - hOv;
    int cols=w1 + w2 - wOv;
    Grid g = helper.createGrid(rows, cols);

    // First rectangle
    helper.highlightCells(g, 0, 0, w1, h1, true);
    // Punch a hole in it if there is space, leaving walls 1-thick
    if (w1>2 && h1>2) {
      helper.highlightCells(g, 1, 1, w1-2, h1-2, false); // hole
    }

    // Second rectangle
    int o2x = w1-wOv;
    int o2y = h1-hOv;
    helper.highlightCells(g, o2x, o2y, w2, h2, true);
    if (w2>2 && h2>2) {
      helper.highlightCells(g, o2x+1, o2y+1, w2-2, h2-2, false); // hole
    }

    // Fill in overlapped region
    helper.highlightCells(g, o2x, o2y, wOv, hOv, true);

    return g;
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
}