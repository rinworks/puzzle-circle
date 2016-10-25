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
  int centerTeeth = 50;
  int[] outerTeeth = {10, 15, 10, 20, 15, 30};
  star = new StarMachine(centerTeeth, outerTeeth, gPg);

  gPg.beginDraw();
  gPg.background(backgroundValue);
  gPg.textFont(font);
  gPg.textAlign(CENTER, CENTER);
  gPg.ellipseMode(RADIUS);

  star.draw();
 
  gPg.endDraw();
  gPg.save("out/gears.png");
  image(gPg, 0, 0, width, width*imageHeight/imageWidth);

  noLoop();
}

void draw() {
}