
HilbertPuzzle gHP;

void setup() {
  String gPhraseSalmon = "S A L M O N   S P A W N I N G  A R E A  O R  N  E   ST";
  String gPhraseBody = "C A R R I E S  M O R E  C A R B O N   D I O X I D E  :  A R T E R Y  ORVEIN?";
  String gPhraseMath = "P R O D U C T   O F   T H E  F I R ST   FIVE PRIMES";
  String gPhraseEagle = "P R I M A R Y  F O O D  O F  T H I S   N A T I O N  A L   S Y M B O L   O F   U S A";
  String gPhraseSeattle = "T A L L E S T  O B J E C T  V I S I B L E  I N  P I C T U R E";
  String gPhraseBee = "E C O S Y S T E M  S E R V I C E  P R O V I D E D  B Y  T H IS  I N S E   C T";
  String gPhraseHamilton = "R I C H A R D R O DG E R S T H E A T E R :  M A R 5TH 8PM";

  String gSOL1 = "LA MESA DE LA DIRECTORA EN LA DIRECCIÓN";
  String gSOL2 = "LA PRIMERA SILLA DEL AULA VIRTUAL";
  String gSOL3 = "LA PUERTA GRANDE DE LA ENTRADA DE LA ESCUELA";
  String gSOL4 = "LA PILA DE LA ESCUELA";

  noLoop(); // it is switchted to loop/noLoop() in mousePressed and draw.
  //size(990, 990);
  size(2000, 2000);

  String basePath = "C:\\Users\\josephj\\Documents\\git\\puzzle-circle\\GAU2017\\processing\\TileJumble\\output";

  //gHP = new HilbertPuzzle(basePath, "salmon-square.jpg", gPhraseSalmon, "salmon", 8);
  //gHP = new HilbertPuzzle(basePath, "body-square.png", gPhraseBody, "body", 5);
  //gHP = new HilbertPuzzle(basePath, "ammonite-square.jpg", gPhraseMath, "math", 8);
  //gHP = new HilbertPuzzle(basePath, "eagle-square.jpg", gPhraseEagle, "eagle", 5);
  //gHP = new HilbertPuzzle(basePath, "seattle-square.jpg", gPhraseSeattle, "seattle", 7);
  //gHP = new HilbertPuzzle(basePath, "bee-square.jpg", gPhraseBee, "bee", 5);
  String[] solutions = {
    "LA\tMESA\tDE\tLA\tDIRECTORA\tEN\tLA\tDIRECCIÓN", 
    "LA\tPRIMERA\tSILLA\tDEL\tAULA\tVIRTUAL", 
    "LA\t  PUERTA\t  GRANDE\tDE\tLA\t  ENTRADA\tDE\tLA\t  ESCUELA", 
    "LA\tPILA\tDE\tLA\tESCUELA"
  };
  String [] fstubs = {
    "1bison",
    "2fischer",
    "3gorilla",
    "4hippo"
  };
  
  int[] markIDs = {1, 2, 3, 4}; // Identify the puzzle instance - the image is watermarked with this
  int[] spaces = {6, 7, 5, 12}; // Spaces to insert between blansk
  int index = 3;
  String fstub = fstubs[index];
  gHP = new HilbertPuzzle(markIDs[index], basePath, fstub+ ".png", solutions[index], fstub, spaces[index]);



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