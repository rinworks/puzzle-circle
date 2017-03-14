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
final int TEXT_SIZE = 60;
final String FONT_NAME = "Segoe WP Black";
final int TEXT_BACKGROUND = 220;
Utils gUtils = new Utils();

void settings()
{
  // Use this one to just test a single generated page on screen
  //size(2000*8/11, 2000);
  
  // Use this to generate a multi-page PDF
  size(2000*8/11, 2000, PDF, "output/qr_animals_cards.pdf");
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
} 


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
  final int NROWS = 4;
  final int NCOLS = 4;
  final int MARGINX = 50;
  final int MARGINY = 0;
  final int CW = (width-2*MARGINX)/NCOLS;
  final int CH = (height-2*MARGINY)/NROWS;
  final int QRDIM = min(CW, CH); // -1 leaves a 1-pixel wide border.
  Animal[] arr = makeAnimals("data/animals.txt", "data/raw-names.txt", NROWS*NCOLS*7); // 7 pages
  saveEncodedText(arr, "output/qr_animals_key.txt");
  int animalIndex = 0;
  PFont font = createFont(FONT_NAME, TEXT_SIZE); 
  textFont(font);
  fill(0);
  final int QRYOFFSET = CH/3; // by trial-and-error
  int page = 1;
  PGraphicsPDF pdf  = (g instanceof PGraphicsPDF) ?  (PGraphicsPDF) g : null;  // Get the renderer - seem's it's called "g" !
  while (animalIndex < arr.length) {
    if (page > 1 && pdf != null) { // page is 1-based
      pdf.nextPage();
    }
    background(255);
    fill(TEXT_BACKGROUND);
    noStroke();
    rect(MARGINX, MARGINY, width-2*MARGINX-2, height-2*MARGINY);
    //background(TEXT_BACKGROUND);
    for (int col = 0; col < NCOLS; col++) {
      int ix = MARGINX + col*CW;
      // Draw an initial vertical white line on the boundary
      if (col>0) {
        stroke(255);
        line(ix, 0, ix, height);
      }
      for (int row = 0; row < NROWS; row++) {
        if (animalIndex>= arr.length) {
          break; /************** WE'RE ALL DONE ***************/
        }
        String qrText = arr[animalIndex].toString();
        PImage img = zxing4p.generateQRCode(qrText, QRDIM, QRDIM);
        animalIndex++;
        //String fname  = "output/qr"+ row + "-" + col + ".png";
        //img.save(fname);
        int iy = MARGINY + row*CH; //DIM;
        image(img, ix, iy+QRYOFFSET, QRDIM, QRDIM); //CW, CH);

        // Draw label - upside down because it'll be on the other side 
        // of the card.
        int tx = ix + CW/2;
        int ty = iy + CH/8;
        pushMatrix();
        translate(tx, ty);
        rotate(radians(180));
        String label = "" + animalIndex;
        translate(-textWidth(label)/2, TEXT_SIZE*0.1); // We have to move "down" as we're upside down.
        fill(0);
        textSize(TEXT_SIZE);
        text(label, 0, 0);
        popMatrix();

        // Debug only - to verify labels.
        if (pdf==null) {
          textSize(20);
          text(qrText, ix, iy+20);
        }

        // Uncomment for debugging layout - 
        // prints a rectangle around each cell.
        //noFill();
        //stroke(0);
        //rect(ix, iy, CW, CH);
      }
    }


    //save("output/animals-" + page + ".png");
    page++;
    if (pdf == null) {
      break; // we just break after rendering the first page - demo only
    }
  }

  if (pdf!= null) {
    println("***PDF GENERATION COMPLETE***");
    exit(); // Needed to finalize PDF, it seels.
  }
}


// Save the encoded text for each animal, prefixed by a 1-based
// index into the array (this index will match what is printed on the other
// side of the QR code).
void saveEncodedText(Animal[] arr, String fname) {
  String[] text = new String[arr.length];
  for (int i = 0; i < arr.length; i++) {
    text[i] = String.format("%3d: %s", i+1, arr[i].toString());
  }
  saveStrings(fname, text);
}