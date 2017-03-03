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

void settings()
{
    size(2000*8/11, 2000);
}

void setup()
{


  // ZXING4P ENCODE/DECODER INSTANCE
  zxing4p = new ZXING4P();

  // SHOW VERSION INFORMATION IN CONSOLE
  zxing4p.version();

  genCodes();
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