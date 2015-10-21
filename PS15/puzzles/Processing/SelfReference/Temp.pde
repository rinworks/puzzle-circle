/*
int gStep = 60;
//String gPhrase = "INVENTOR OF THIS SPACE FILLING CURVE (FULL NAME)";
String gPhrase0 = "      W       H       A      T     I   S     F"
+ "  I   V  "
+ "      E                      "
+ "      C  U     B      E     D     "
+ "          I     N               R         O        M    A     N          N   "
+ "   U     M   E     R   A   "
+ "  L     S            ";
;
String gPhrase1 = "      W      H      I     C    H        C"
+ "  O   M  "
+ "      P                      "
+ "      A  S     S           D     "
+ "          I     R              E         C        T    I     O          N   "
+ "   I     S    T  H  E     L   A   "
+ "  K     E            ";
String gPhrase = "      W       H       A      T     I   S     T"
+ "  H   E  "
+ "      F                      "
+ "      I  F     T      H           "
+ "                                P         R        I    M     E          N   "
+ "   U     M   B     E   R  ?"
+ "                     ";
int gNextChar = 0; // next char in the phrase to display.
int gStepCount = 0; // number of actual steps (lines) drawn so far.
boolean gDrawNodes = false;
PImage gScrambled=null;
PImage gOriginal= null;
PImage gImageToDisplay=null;

class PuzzleData {
  String imageFile;
  String phrase;
  String name;
    PuzzleData(String image, String phrase, String name) {
      this.imageFile = image;
      this.phrase = phrase;
      this.name = name;
  }
}

// Initially these were customized, but now
// these are exactly 1/3rd and 2/3rd, splitting the square into 9 equal square tiles.
// This is required in order for the shuffling of tiles to work out.
int[] xCuts = {
  330, 660
};
int [] yCuts = {
  330, 660
};

void setup() {
  noLoop(); // it is switchted to loop/noLoop() in mousePressed and draw.
  size(990, 990);
  //smooth();
  drawPuzzle();
  String originalFile = "selfReferenceAnswer.png";
  String scrambledFile = "G:\\KUMBH\\Projects\\fam\\Puzzle Safari\\PS15\\Processsing\\SelfReference\\output\\SelfReferenceOut.png";
  save(originalFile);
  PImage img = loadImage(originalFile);
  PImage scrambled = scrambleImage(img);
  scrambled.save(scrambledFile);
  gOriginal = img;
  gScrambled = scrambled;
  gImageToDisplay = img;
}

// Treats img as a  3x3 tile grid and shuffles it 
// - returns the shuffled image (original image is unchanged)
PImage scrambleImage(PImage img) {
  int [] permutation = 

  { 
    6, 2, 5, 1, 0, 3, 8, 7, 4
    //0, 1, 2, 3, 4, 5, 6, 7, 8
  };

  // 1-time only - to generate above array - however had to tweak the above arrray to eliminate ALL adjacent tiles.
  //randomPermutation(permutation, 0);
  println(permutation);

  PImage scrambled = img.get();
  final int TILE = 330;
  for (int i = 0; i<3; i++) {
    for (int j=0; j<3; j++) {
      int k = permutation[i*3+j];
      int pi = k/3;
      int pj = k%3;
      println(i+"," + j + "->" + pi+"," + pj);
      // xCuts, yCuts
      // pimg.copy(src, sx, sy, sw, sh, dx, dy, dw, dh)
      int sx = i*TILE;
      int sy = j*TILE;
      int sw = TILE;
      int sh = TILE;
      int dx = pi*TILE;
      int dy = pj*TILE;
      int dw = TILE;
      int dh = TILE;
      //scrambled.copy(img,
      scrambled.copy(img, sx, sy, sw, sh, dx, dy, dw, dh);
    }
  }

  return scrambled;
}

void randomPermutation(int[] arr, int seed) {
  if (arr.length<2) return;
  randomSeed(seed);
  for (int i=0; i<arr.length-1; i++) {
    swap(arr, i, (int) random(i+1, arr.length));
  }
}

void swap(int[] arr, int i, int j) {
  int t = arr[i];
  arr[i] = arr[j];
  arr[j] = t;
}

void resetPuzzle() {
  gNextChar = 0; // next char in the phrase to display.
  gStepCount = 0; // number of actual steps (lines) drawn so far.
  gDrawNodes = false;
}


// draw hilbert curve with letters.
void drawPuzzle() {
  resetPuzzle();
  // load image
  PImage img = loadImage("data\\Hilbert.jpg");
  image(img, 0, 0, width, height);
  drawCuts();
  fill(255.0, 70.0); 
  rect(0, 0, width, height);
  translate(47, 47); // these are set so that the curve is centered, but also that the cuts do not come too close to the curve running parallel to the cut.
  strokeWeight(8);
  stroke(0);
  pushMatrix();
  A(4); // draw the line pattern - no text bubbles
  popMatrix();
  gDrawNodes=true;
  textSize(20);
  A(4); // draw the text bubbles

}


void drawCuts() {
  stroke(255);
  strokeWeight(1);

  // draw vertical lines
  for (int x : xCuts) {
    line(x, 0, x, height);
  }

  // draw hoizontal lines
  for (int y : yCuts) {
    line(0, y, width, y);
  }
}
void A(int n) {
  // - B F + A F A + F B - (from wikipidia)
  if (n==0) {
    return;
  }
  minus(); 
  B(n-1); 
  F(); 
  plus(); 
  A(n-1); 
  F(); 
  A(n-1); 
  plus(); 
  F(); 
  B(n-1); 
  minus();
}

void B(int n) {
  // + A F − B F B − F A + (from wikipedia)
  if (n==0) {
    return;
  }
  plus(); 
  A(n-1); 
  F(); 
  minus(); 
  B(n-1); 
  F(); 
  B(n-1); 
  minus(); 
  F(); 
  A(n-1); 
  plus();
}

void plus() {
  rotate(-HALF_PI);
}

void minus() {
  rotate(HALF_PI);
}

void F() {
  if (!gDrawNodes) {
    line(0, 0, gStep, 0);
  } else {
    gStepCount++;
    if (gNextChar<gPhrase.length()) {
      String s = gPhrase.substring(gNextChar, gNextChar+1);
      if (!s.equals(" ")) {
        // display it.
        fill(255);
        ellipse(0, 0, 50, 50);
        textAlign(CENTER);
        //println(s);
        fill(0);
        text(s, 0, 8);
      }
      gNextChar++;
    }
  }
  translate(gStep, 0);
}

void mousePressed() {
  // toggle between displaying original and randomized tiling display
  println("Mousepressed");
  if (gImageToDisplay != gOriginal) {
    println("Displaying original" + gOriginal);
    gImageToDisplay = gOriginal;
  } else {
    gImageToDisplay = gScrambled;
    println("Displaying scrambled" + gScrambled);
  }
  loop(); // ensures that draw() is called. It doesn't work to attempt to call paint /rendering functions outside of the draw() function context.
}


void draw() {
  if (gImageToDisplay!=null) {
    println("displaying image afresh...");
    background(0);
    image(gImageToDisplay, 0, 0);
    noLoop(); // ensures that we only draw once - loop is enabled again in mousePressed.
  }
}
*/