// Module: MetaPuzzle  - program entrypoint
// History:
//  Feb 2017  - JMJ created.
import processing.pdf.*;

public static final boolean GENERATE_PDF = true;
final String[] FILE_STUBS = {
  "1bison", 
  "2fischer", 
  "3gorilla", 
  "4hippo"
};
final int index = 3; // 0,1,2,3

void settings() {
  final int WIDTH = 1000;
  final int HEIGHT = WIDTH*4/3; // We break image into three rows and two columns.
  if (GENERATE_PDF) {
    size(WIDTH, HEIGHT, PDF, "output/meta-" + FILE_STUBS[index] + ".pdf");
  } else {
    size(WIDTH, HEIGHT);
  }
}

void setup() {
  noLoop();

  generateMetapuzle();
}

void generateMetapuzle() {
  // Load image
  PImage source = loadImage("data/" + FILE_STUBS[index] + ".png");
  displayPart1(source);
  nextPdfPage();
  displayPart2(source);
  nextPdfPage();
  displayPart3(source);
  if (GENERATE_PDF) {
    exit();
  }
}

void nextPdfPage() {
  if (GENERATE_PDF) {
    PGraphicsPDF pdf = (PGraphicsPDF) g;  // Get the renderer
    pdf.nextPage();
  }
}

void   displayPart1(PImage source) {
  int sw = source.width/2;
  int sh = source.height*2/3;
  PImage part = source.get(0, 0, sw, sh);
  image(part, 0, 0, width, height);
}

void   displayPart2(PImage source) {
  int sw = source.width/2;
  int sh = source.height*2/3;
  PImage part = source.get(sw, 0, sw, sh); // Right column, rows 1 and 2
  image(part, 0, 0, width, height);
}

void   displayPart3(PImage source) {
  int sw = source.width/2;
  int sh = source.height/3;
  int y = source.height*2/3;
  PImage part1 = source.get(0, y, sw, sh);
  image(part1, 0, 0, width, height/2);
  PImage part2 = source.get(sw, y, sw, sh);
  image(part2, 0, height/2, width, height/2);
}