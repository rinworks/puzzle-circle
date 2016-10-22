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
Utils gUtils = new Utils();

void setup() {
  size(1300, 1300);
  //println(PFont.list());
  //size(2000, 2000);

  // To recreate a specific puzzle, make a note of the printed seed value and 
  // set seed to that printed seed value (comment out the call to round(random(...))).
  long seed = round(random(MAX_INT));
  println("SEED: " + seed);
  randomSeed(seed);

  TileHelper helper = new TileHelper();
  String letters;
  String[] borderText;
  int rows=5;
  int cols=5;
  int[] permutation = generatePermutation(rows*cols, 0, false);
  String[] wordPairs = getWordPairs(rows*cols);
  Grid g = helper.createGrid(rows, cols, "AARDVARKS ARE MY FRIENDS", wordPairs, permutation);
  g.draw();
  save("output/test.png");
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

String[] getWordPairs(int count) {
  String[]  words = new String[count];
  for (int i=0; i<count; i++) {
    words[i] = "i" + "A " + i + "B"; // Eg: 10A 10B
  }
  return words;
}