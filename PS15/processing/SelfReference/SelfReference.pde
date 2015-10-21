
HilbertPuzzle gHP;

void setup() {
  String gPhrase0 = "      W       H       A      T     I   S     F"
    + "  I   V  "
    + "      E                      "
    + "      C  U     B      E     D     "
    + "          P     L     U         S         F        O    U     R          S   "
    + "   Q     U   A     R   E   "
    + "  D? ";
  ;
  String gPhrase1 = "      W      H      A     T    I        S"
    + "  T   H  "
    + "      E  S  E   V  E  N  T  H   "
    + "      P  R     I           M     "
    + "          E     T              I         M       E S    T     H          E   "
    + "   E     I    G  H  T     P   R   "
    + "  I     M  E ?";
  String gPhrase2 = "      W     H     A     T    I   S    O"
    + "  N   E  "
    + "      F      "
    + "      O  U     R      T           "
    + "         H         O        F    F     I          V   "
    + "   E     H   U     N   D  R"
    + "  E    D    A      N    D       T    W      E    L    V      E?";

  noLoop(); // it is switchted to loop/noLoop() in mousePressed and draw.
  size(990, 990);
  String basePath = "G:\\KUMBH\\Projects\\fam\\Puzzle Safari\\PS15\\Processsing\\SelfReference\\output";
  //gHP = new HilbertPuzzle(basePath, "Hilbert.jpg", gPhrase, "hilbert1");

  //gHP = new HilbertPuzzle(basePath, "eagle.jpg", gPhrase0, "eagle");
  // gHP = new HilbertPuzzle(basePath, "frog.jpg", gPhrase1, "frog");
    gHP = new HilbertPuzzle(basePath, "bee.jpg", gPhrase2, "bee");
  gHP.doPuzzle();
}

void mousePressed() {
  gHP.mousePressed();
  loop(); // ensures that draw() is called. It doesn't work to attempt to call paint /rendering functions outside of the draw() function context.
}


void draw() {
  gHP.draw();
  noLoop(); // ensures that we only draw once - loop is enabled again in mousePressed.
}