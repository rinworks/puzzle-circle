/*****************************************************************************
 *
 *  QRGen - code to generate QR codes for Puzzle Circle puzzles.
 *
 *  Based on the sample from
 
 *
 *  history: 
 *   Y17M03D03 JMJ Created, based on a sample from http://cagewebdev.com/zxing4processing-processing-library/
 *
 *****************************************************************************/


// IMPORT THE ZXING4PROCESSING LIBRARY AND DECLARE A ZXING4P OBJECT
import com.cage.zxing4p3.*;
ZXING4P zxing4p;
import processing.pdf.*;

void settings()
{
  size(2000*8/11, 2000);
  //size(2000*8/11, 2000, PDF, "output/qr_tiles.pdf");
}

void setup()
{

  // ZXING4P ENCODE/DECODER INSTANCE
  zxing4p = new ZXING4P();

  // SHOW VERSION INFORMATION IN CONSOLE
  zxing4p.version();

  //genCodes();
  //testMakeAnimals();
  genAnimalTiles();
} // setup()


/*****************************************************************************
 *
 *  DRAW
 *
 *****************************************************************************/
void genCodes() {
  String[][] codes = {
    {"WHAT CITY ARE WE IN?", "WHAT LAKE IS WEST OF US?"}, 
    {"WHICH COUNTRY NORTH OF US?", "WHICH COUNTRY IS SOUTH OF US?"}, 
    {"IN WHICH CONTINENT IS EGYPT?", "IN WHICH CONTINENT IS JAPAN?"}
  };
  final int NROWS = codes.length;
  final int NCOLS = codes[0].length;
  final int MARGIN = 10;
  final int GAP = 5;
  final int CW = (width-2*MARGIN)/NCOLS;
  final int CH = (height-2*MARGIN)/NROWS;
  final int DIM = min(CW, CH);
  for (int row = 0; row < NROWS; row++) {
    for (int col = 0; col < NCOLS; col++) {
      PImage img = zxing4p.generateQRCode(codes[row][col], DIM, DIM);
      //String fname  = "output/qr"+ row + "-" + col + ".png";
      //img.save(fname);
      image(img, MARGIN + col*CW, MARGIN + row*DIM, CW, CH);
    }
  }
  save("output/qr-all.png");
}

void genAnimalTiles() {
  Animal[] arr = makeAnimals("data/animals.txt", "data/raw-names.txt");
  final int NROWS = 4;
  final int NCOLS = 4;
  final int MARGIN = 10;
  final int CW = (width-2*MARGIN)/NCOLS;
  final int CH = (height-2*MARGIN)/NROWS;
  final int QRDIM = min(CW, CH);
  int animalIndex = 0;
  textSize(40);
  fill(0);
  final int QRYOFFSET = CH/4;
  int page = 1;
  PGraphicsPDF pdf  = (g instanceof PGraphicsPDF) ?  (PGraphicsPDF) g : null;  // Get the renderer - seem's it's called "g" !
  while (animalIndex < arr.length) {
    if (page > 1 && pdf != null) { // page is 1-based
      pdf.nextPage();
    }
    background(200);
    for (int row = 0; row < NROWS; row++) {
      for (int col = 0; col < NCOLS; col++) {
        if (animalIndex>= arr.length) {
          break;
        }
        PImage img = zxing4p.generateQRCode(arr[animalIndex].toString(), QRDIM, QRDIM);
        animalIndex++;
        //String fname  = "output/qr"+ row + "-" + col + ".png";
        //img.save(fname);
        int ix = MARGIN + col*CW;
        int iy = MARGIN + row*CH; //DIM;
        image(img, ix, iy+QRYOFFSET, QRDIM, QRDIM); //CW, CH);
        int tx = ix + CW/2;
        int ty = iy + CH/8;
        text("" + animalIndex, tx, ty);
      }
    }
    //save("output/animals-" + page + ".png");
    page++;
  }

  if (pdf!= null) {
    println("***PDF GENERATION COMPLETE***");
    exit(); // Needed to finalize PDF, it seels.
  }
}