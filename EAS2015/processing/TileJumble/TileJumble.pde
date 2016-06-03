
HilbertPuzzle gHP;

void setup() {
  String gPhraseSalmon = "S A L M O N   S P A W N I N G  A R E A  O R  N  E   ST";
  String gPhraseBody = "C A R R I E S  M O R E  C A R B O N   D I O X I D E  :  A R T E R Y  ORVEIN?";
  String gPhraseMath = "P R O D U C T   O F   T H E  F I R ST   FIVE PRIMES";
  String gPhraseEagle = "P R I M A R Y  F O O D  O F  T H I S   N A T I O N  A L   S Y M B O L   O F   U S A";
  String gPhraseSeattle = "T A L L E S T  O B J E C T  V I S I B L E  I N  P I C T U R E";
  String gPhraseBee = "E C O S Y S T E M  S E R V I C E  P R O V I D E D  B Y  T H IS  I N S E   C T";
  String gPhraseHamilton = "R I C H A R D R O DG E R S T H E A T E R :  M A R 5TH 8PM";



  noLoop(); // it is switchted to loop/noLoop() in mousePressed and draw.
  size(990, 990);
  String basePath = "C:\\Users\\josephj\\Documents\\git\\puzzle-circle\\EAS2015\\processing\\TileJumble\\output";

  //gHP = new HilbertPuzzle(basePath, "salmon-square.jpg", gPhraseSalmon, "salmon", 8);
  //gHP = new HilbertPuzzle(basePath, "body-square.png", gPhraseBody, "body", 5);
  //gHP = new HilbertPuzzle(basePath, "ammonite-square.jpg", gPhraseMath, "math", 8);
  //gHP = new HilbertPuzzle(basePath, "eagle-square.jpg", gPhraseEagle, "eagle", 5);
  //gHP = new HilbertPuzzle(basePath, "seattle-square.jpg", gPhraseSeattle, "seattle", 7);
  //gHP = new HilbertPuzzle(basePath, "bee-square.jpg", gPhraseBee, "bee", 5);
 gHP = new HilbertPuzzle(basePath, "hamilton-square.jpg", gPhraseHamilton, "hamilton", 7);



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