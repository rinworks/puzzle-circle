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

  boolean permute = true; // Set to true to generate the (scrambled) puzzle - else the answer.

  // ****************   TO GENERATE MULTIPLE VERSIONS ***************
  for (int index = 0; index < 5; index++) {
    //int index=1; // Change this from 0-4 to generate multiple versions of puzzles

    long seed = seeds[index];
    println("SEED: " + seed);
    randomSeed(seed);

    TileHelper helper = new TileHelper();
    int rows=4;
    int cols=4;

    //TESTING ONLY String[] wordPairs = genTestWordPairs(2*rows*cols);
    String[] wordPairs = getWordPairs();
    String[] answers = {
      "T H E S E V E N T H P L A N E T", 
      "H A R D E S T M A T E R I A L", 
      "F R O Z E N F O R M O F W A T ER", 
      "M A S S P E R U N I T V O L U ME", 
      "C O L D E S T C O N T I N E N T"
    };
    int[] tilePermutation = generatePermutation(rows*cols, 0, permute);
    int[] borderPermutation = generatePermutation(wordPairs.length, 0, true); // We always permute the border pairs...
    Grid g = helper.createGrid(rows, cols, answers[index], wordPairs, tilePermutation, borderPermutation);
    g.draw();
    save("output/tileWorld"+(index+1)+ (permute? "" : "ans") + ".png");
  }
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


// TESTING ONLY
String[] genTestWordPairs(int count) {
  String[]  words = new String[count];
  for (int i=0; i<count; i++) {
    words[i] =i + "A " + i + "B"; // Eg: 10A 10B
  }
  return words;
}

// Return pairs of words used to mark boundaries.
// We need (rows-1)*cols + rows*(cols-1) pairs.
// For a 5x5 grid, that's 40 pairs!
String[] getWordPairs() {
  String[]  words = {

    "Snow Flake", 
    "Lewis &Clark", 
    "Solar System", 
    "Olympic Peninsula", 
    "Darth Vader", 

    "Mobile Phone", 
    "Street Crossing", 
    "Tent Pole", 
    "Sleeping Bag", 
    "Winter Break", 

    "Apple Pie", 
    "Gold Coin", 
    "White Board", 
    "Paper Bag", 
    "Leap Year", 

    "White House", 
    "Civil War", 
    "X-ray Machine", 
    "Video Game", 
    "Asteroid Belt", 

    "Founding Fathers", 
    "Lunch Break", 
    "Water Source", 
    "Loud Voice"

  };
  return words;
}