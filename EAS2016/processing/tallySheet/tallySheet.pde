// //<>// //<>// //<>//
// Module: tileWorld.PDE
// Description: Main file for Tile World puzzle generator.
//  TileWorld is based on Martyn Lowell's Tile World puzzle for the 2015 Microsoft Puzzle Safari
//
// History:
//	October 2016 - JMJ copied from laser code (uses the GraphicsBase code)
//
// General notes:
//     Grid coordinates: (i, j) are like rows of an array/matrix. So i is vertical,
//     with increasing i going downwards.
//
//import java.util.Comparator;
//import java.util.Arrays;
import processing.pdf.*;
Utils gUtils = new Utils();
public static final boolean GENERATE_PDF = false;

void setup() {
  // Pick 2nd one if GENERATE_PDF is true.
  size(2000, 1000);
  //size(2000, 1000, PDF, "output/out.pdf");


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

  boolean permute = true; // Set to true to generate the (scrambled) puzzle - else the answer.

  // ****************   TO GENERATE MULTIPLE VERSIONS ***************
  for (int index = 0; index < 1; index++) {
    //int index=1; // Change this from 0-4 to generate multiple versions of puzzles

    long seed = seeds[index];
    println("SEED: " + seed);
    randomSeed(seed);

    TextTableHelper helper = new TextTableHelper();


    //TESTING ONLY String[] wordPairs = genTestWordPairs(2*rows*cols);
    //String[] wordPairs = {}; 
    String[][] answers = {
      {"Voluminous", "Voluminous Ticket"}, 
      {"Quest 1", "Quest 1 Ticket"}, 
      {"Furniture Factory", "Furniture Factory Ticket"}, 
      {"Quest 2", "Quest 2 Ticket"}, 
      {"Quest 3", "Quest 3 Ticket"}, 
      {"Perspective", "Perspective Ticket"}, 
      {"Challenge foo", "Challenge foo Ticket"}, 
      {"Challenge bar", "Challenge bar Ticket"}
    };
    int originX = 100;
    int originY = 100;
    int rows=8;
    int cols=2;
    //Grid g = helper.createGrid(rows, cols, answers, originX, originY, 300, 50); 
    //g.draw();
    if (GENERATE_PDF) {
      PGraphicsPDF pdf = (PGraphicsPDF) g;  // Get the renderer
      testNestedGrid(helper, 1, 2);
      pdf.nextPage();
      testNestedGrid(helper, 2, 3);
      exit();
    } else {
      testNestedGrid(helper, 2, 3);
    }
    //save("output/tileWorld"+(index+1)+ (permute? "" : "ans") + ".png");
  }
}

void testNestedGrid(TextTableHelper helper, int rows, int cols) {
  //(int rows, int cols, float gridWidth, float gridHeight, float cellPadding, float originX, float originY)
  Grid pg = new Grid(rows, cols, width/2, height/2, 0, 20, 20);
  for (int i=0; i< pg.rows; i++) {
    Cell[] row = pg.cells[i];
    assert(row.length == pg.cols);
    for (int j=0; j< pg.cols; j++) {
      // Create test text for the nested grid at (i,j)...
      int nRows = i+1;
      int nCols = j+1;
      String[][]text = new String[nRows][nCols];
      for (int ni = 0; ni  < text.length; ni++) {
        String[] textRow = text[ni];
        for (int nj = 0; nj < textRow.length; nj++) {
          String prefix = "";
          int m = (ni+nj)%3;
          if (m==0) {
            prefix = ">>>";
          } else if (m==1) {
            prefix = "^^^";
          }
          textRow[nj] = prefix+"["+i+","+j+"] ("+ni+","+nj+")";
          //println("textRow[ni]: " + textRow[nj]);
          //println("text[ni][nj]: " + text[ni][nj]);
        }
      }
      Grid g = helper.createNestedGrid(pg, i, j, nRows, nCols, text);
      g.borderWeight(5);
      row[j].dObject = g;
      // g.draw();
    }
  }
  pg.borderWeight(10);
  pg.draw();
}

// Generates permutations of [startValue ... startValue+length-1]
int[] generatePermutation(int length, int startValue, boolean permute) {
  assert(length>=0);
  int[] p = new int[length];
  for (int i=0; i<length; i++) {
    p[i] = startValue+i;
  }
  if (permute) {
    gUtils.randomPermutation(p);
  }
  return p;
}