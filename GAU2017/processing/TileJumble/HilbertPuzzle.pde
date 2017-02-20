enum  DrawMode { //<>//
  DRAW_BASE_PATH, // Base white lines
    DRAW_NARROW_PATH, // Narrower black overlay line
    DRAW_NODES // Text nodes
};

class HilbertPuzzle {
  final int markID;
  String path;
  String imageFile;
  String phrase;
  String name;

  HilbertPuzzle(int markID, String path, String image, String phrase, String name, int space) {
    this.markID = markID;
    this.path = path;
    this.imageFile = image;
    this.phrase = insertBlanks(phrase, space);
    this.name = name;
  }



  // These two parameters below are carefully set so that text circles do not intersect the cut lines
  // (and nor do the black space-filling curve go anywhere close to the cut lines.
  final int SCALE = 2; // How much to scale puzzle by
  final int PICTURE_FRAME_WIDTH = SCALE*20;
  int gStep = SCALE*55;//58; //60; // size of each step
  int gStart = SCALE*83; // Start of drawing is (gStart, gStart);

  int gNextChar = 0; // next char in the phrase to display.
  int gStepCount = 0; // number of actual steps (lines) drawn so far.
  DrawMode gDrawMode = DrawMode.DRAW_BASE_PATH; // A white thicker line
  PImage gScrambled=null;
  PImage gOriginal= null;
  PImage gImageToDisplay=null;

  // Initially these were customized, but now
  // these are exactly 1/3rd and 2/3rd, splitting the square into 9 equal square tiles.
  // This is required in order for the shuffling of tiles to work out.
  int[] xCuts = {
    width/2 // width/3, width*2/3//SCALE*330, SCALE*660
  };
  int [] yCuts = {
    width/3, width*2/3//SCALE*330, SCALE*660
  };


  // Inserts blanks between characters so that it occupies the entire space.
  // Also inserts blanks before first char and after last char.
  String insertBlanks(String in, int numBlanks) {
    String ret = " ";
    String blanks = "                           ";
    String b1 = blanks, b2=b1;
    int len = blanks.length();
    if (len > numBlanks) {
      b1 = blanks.substring(len-numBlanks);
      if (numBlanks>0) {
        b2 = blanks.substring(len-(numBlanks-1));
      }
    }

    for (int i = 0; i<in.length(); i++) {
      char c = in.charAt(i);
      ret += ((i>0 && c!= ' ')? (i%2==0?b1:b2) : "") + c;
    }
    println("["+ret+"]");
    return ret;
  }

  void doPuzzle() {

    drawPuzzle();
    String originalFile = this.path + "\\" + this.name + "Answer.png";
    String scrambledFile = this.path + "\\" + this.name + ".png";
    ;
    save(originalFile);
    PImage img;
    do {
      delay (500);
      img = loadImage(originalFile);
    } while (img == null);
    PImage scrambled = scrambleImage(img);
    scrambled.save(scrambledFile);
    gOriginal = img;
    gScrambled = scrambled;
    gImageToDisplay = img;
  }

  // Treats img as a  3x3 tile grid and shuffles it 
  // - returns the shuffled image (original image is unchanged)
  PImage scrambleImage(PImage img) {

    PImage scrambled = img.get();

    if (xCuts.length!= 2 || yCuts.length!= 2) {
      System.err.println("CANNOT PERMUTE UNLESS IT IS A 3x3 GRID!");
      scrambled.copy(); //sx, sy, sw, sh, dx, dy, dw, dh);
      return scrambled; // ************ EARLY RETURN
    }

    int [] permutation = 
      { 
      6, 2, 5, 1, 0, 3, 8, 7, 4
      //0, 1, 2, 3, 4, 5, 6, 7, 8
    };

    // 1-time only - to generate above array - however had to tweak the above arrray to eliminate ALL adjacent tiles.
    //randomPermutation(permutation, 0);
    println(permutation);

    final int TILE = SCALE*330;
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
  }


  // draw hilbert curve with letters.
  void drawPuzzle() {
    resetPuzzle();
    // load image
    PImage img = loadImage("data\\" + this.imageFile);
    int D = PICTURE_FRAME_WIDTH;
    image(img, 0+D, 0+D, width-2*D, height-2*D);

    // Mark puzzle with unique ID.
    markPuzzle();
    drawCuts();

    // This desaturates the image by overlaying with a partially opaque white rectangle
    fill(255.0, 50.0); // Was 70.0
    rect(0, 0, width, height);
    drawPictureFrame();

    translate(gStart, gStart); // these are set so that the curve is centered, but also that the cuts do not come too close to the curve running parallel to the cut
    textSize(max(SCALE*0.75, 1)*20);
    drawCurve(DrawMode.DRAW_BASE_PATH); // Stage 0 - thick white line
    drawCurve(DrawMode.DRAW_NARROW_PATH); // Stage 1 - narrow black line
    drawCurve(DrawMode.DRAW_NODES); // Stage 2 - circle nodes
  }


  void drawPictureFrame() {
    noFill();
    final float D = PICTURE_FRAME_WIDTH;
    strokeWeight(D);
    stroke(0);
    rect(D/2, D/2, width-D, height-D);
    strokeWeight(D/2);
    stroke(255);
    rect(D/2, D/2, width-D, height-D);
  }

  // Adds the same identifying mark on all puzzles so
  // that they can be disambiguated from other puzzles.
  // markID - a small positive integer, typically between 1 and 6
  void markPuzzle() {
    assert(markID>=1 && markID<=6);
    if (xCuts.length != 1) {
      println("***WARNING: CANNOT MARK ID ON INTERNAL TILES!***");
    }
    final int NROWS = yCuts.length+1;
    final int ROW_HEIGHT = height/NROWS;
    for (int row = 0; row < NROWS; row++) {
      float y  = row * ROW_HEIGHT + 0.5 * ROW_HEIGHT;
      float x1 = 1.5*PICTURE_FRAME_WIDTH;
      float x2 = width - 2*PICTURE_FRAME_WIDTH;
      drawDots(x1, y, markID);
      drawDots(x2, y, markID);
    }
  }

  // Draw {count} little marker dots with upper-left corner at the specified
  // x and y positions. These are to add a kind of marker to the tile.
  // To avoid adding an orientiation cue, don't start dots on upper-left
  // corner.
  void drawDots(float x, float y, int count) {
    final int N = max(ceil(sqrt(count-0.99)), 2); // roughly square N x N grid
    final int R = SCALE*5;
    noStroke();
    int START = (int) random(N*N);
    for (int k=0; k<count; k++) {
      int k1 = (k + START) % (N*N);
      float dx = R * (k1 % N);
      float dy = R * (k1 / N);
      fill(255);
      ellipse(x+dx, y+dy, R, R);
      fill(0);
      ellipse(x+dx, y+dy, R*0.75, R*0.75);
    }
  }

  void drawCurve(DrawMode stage) {
    gDrawMode = stage;
    pushMatrix();
    A(4); // draw the line pattern - no text bubbles
    popMatrix();
  }


  void drawCuts() {
    stroke(255);
    strokeWeight(2*SCALE);

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
    if (gDrawMode == DrawMode.DRAW_NODES) {
      gStepCount++;
      if (gNextChar<phrase.length()) {
        String s = phrase.substring(gNextChar, gNextChar+1);
        if (!s.equals(" ")) {
          // display it.
          drawNode(s);
        }
        gNextChar++;
      }
    } else {
      drawPathSegment(gStep);
    } 

    translate(gStep, 0);
  }

  void drawPathSegment(float len) {
    if (gDrawMode == DrawMode.DRAW_BASE_PATH) {
      stroke(255);
      strokeWeight(12);
    } else {
      stroke(0);
      strokeWeight(8);
    }
    line(0, 0, len, 0);
  }

  // Draw a node with the specified text
  void drawNode(String s) {
    fill(255);
    float r = max(SCALE*0.75, 1)*50;
    ellipse(0, 0, r, r);
    textAlign(CENTER);
    //println(s);
    fill(0);
    text(s, 0, 8);
    if ("CMNUWZ:".indexOf(s)!=-1) {
      text("_", 0, 10);
    }
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
}