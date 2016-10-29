// JMJ Note: Gear puzzle basedo on my CogitoErgoSometimes puzzle from Puzzle Safari 2016.

import java.util.Arrays;
final  int imageHeight = 2000;
final  int imageWidth = 2000;
PGraphics gPg;
StarMachine star;
PFont font;
float backgroundValue = 255.0;
GearUtils gGearUtils = new GearUtils();
boolean g_drawPitchCircle= false; //true; // If true a fine circle is drawn to illustrate the pitch circle

void setup() {
  size(2000, 1500);
  gPg = createGraphics(imageWidth, imageHeight);
  String fontNames[] = {
    "Oswald Bold", 
    "Segoe WP Bold"
  };
  int fontSize = 48;
  font = createFont(fontNames[1], fontSize);

  int index = 3; // Vary this between 0 and 4 to generate the 5 puzzles.

  int centerTeeth = 60;
  int[] centerRotationsA = {
    9, 
    9, 
    8, 
    11,
    11
  };
  int[][] outerTeethA = {
    {10, 15, 10, 20, 30}, 
    {30, 10, 15, 20, 15}, 
    {20, 15, 12, 30, 12}, 
    {15, 12, 15, 30, 20}, 
    {12, 30, 15, 20, 10}
  };

  int centerRotations = centerRotationsA[index];
  int[] outerTeeth = outerTeethA[index];

  // Print stuff for puzzle answer
  println("PUZZLE ID: " + (index+1));// 1 based
  println("CENTER TEETH: " + centerTeeth);
  println("CENTER ROTATIONS: " + centerRotations);
  int totalOuterRotations = 0;
  String partialRotations = "";
  String teethString = "";
  for (int t : outerTeeth) {
    int outerRotations = centerRotations * centerTeeth/t;
    if (outerRotations*t != centerRotations*centerTeeth) {
      println("WARNING: teeth " + t + " not integral rotations!");
    }
    teethString += " " + t;
    partialRotations += (partialRotations.length()>0 ? " + " : "") + outerRotations;
    totalOuterRotations += outerRotations;
  }
  println("OUTER GEAR TEETH: " + teethString);
  println ("SUM OF OUTER ROTATIONS: " + partialRotations + " = " + totalOuterRotations);



  star = new StarMachine(centerTeeth, outerTeeth, gPg);

  gPg.beginDraw();
  gPg.background(backgroundValue);
  gPg.textFont(font);
  gPg.textAlign(CENTER, CENTER);
  gPg.ellipseMode(RADIUS);

  star.draw();

  gPg.endDraw();
  gPg.save("output/gears"+(index+1)+".png");
  image(gPg, 0, 0, width, width*imageHeight/imageWidth);

  noLoop();
}

void draw() {
}