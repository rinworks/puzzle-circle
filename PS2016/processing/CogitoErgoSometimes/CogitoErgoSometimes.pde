// JMJ Note: Gear code copied from my earlier code
// (written from scratch) to generate the RINWORKS logo.

import java.util.Arrays;
final  int imageHeight = 2000;
final  int imageWidth = 2000;
PGraphics pg;
Machine m;
PFont font;
String leftText = "RINW";
String rightText = "RKS";

float backgroundValue = 255.0;
//float backgroundOpacity = 0.0; // transparant

class Point {
  public double x;
  public double y;
  public Point(double x, double y) {
    this.x=x;
    this.y=y;
  }
  public String toString() {
    return "("+x+","+y+")";
  }

  public void rotate(double angle) {
    //angle = radians(60);
    double c = Math.cos(angle);
    double s = Math.sin(angle);
    double xn  = x*c - y*s;
    double yn  = y*c + x*s;
    x = xn;
    y = yn;
  }

  public double distance(double xx, double yy) {
    double dx = xx-x;
    double dy = yy-y;
    return Math.sqrt(dx*dx + dy*dy);
  }
  
  
}

void setup() {
  size(2000, 1500);
  pg = createGraphics(imageWidth, imageHeight);
  //String[] fontList = PFont.list();
  //println(fontList);
  //pg.fill(0);
  //font = createFont("Oswald Bold", 32);
  String fontNames[] = {
    "Oswald Bold", 
    "Segoe WP Bold"
  };
  int fontSize = 600; //48
  font = createFont(fontNames[1], fontSize);
  // pg.text(leftText, fudgeX+pg.width/2, fudgeY+pg.height/2);
  //   float r1Frac = 0.55; // was 0.65
  //  drawGear2(500, 500, 300, r1Frac);
  m = new Machine();

  pg.beginDraw();
  pg.background(backgroundValue);
  pg.textFont(font);
  pg.textAlign(CENTER, CENTER);
  pg.ellipseMode(RADIUS);

  m.drawGears();

  pg.endDraw();
  //pg.save("logo-out.png");
  image(pg, 0, 0, width, width*imageHeight/imageWidth);

  noLoop();
}

void draw() {
}

void showPoints(Point[] points) {
  //println(points);
  pg.fill(255, 0, 0);
  pg.ellipse(width/2, height/2, 10, 10);
  pg.fill(0);
  for (int i =0; i<points.length; i++) {
    float x = (float) points[i].x;
    float y = (float) points[i].y;
    float SCALE = 25;
    pg.ellipse(width/2 + SCALE*x, height/2 - SCALE*y, 5, 5); // - because of upside-down coords
  }
}

// returns n points along the involute curve with the following parameters:
// module m
// number of gear teeth Z
// pressure angle phi
// (see http://arc.id.au/GearDrawing.html  - this code is based on the formula explained there)
// Also: flip - if true it creates a curve below the x axis
// n == number of points in curve.
Point[] involuteCurve(double m, int Z, double phi, int n, boolean flipY) {
  Point [] ret = new Point[n];

  double D = m*Z;
  double Rb = (D/2)*Math.cos(phi);
  double Ra = D/2+m;
  double multFactor = flipY ? -1 : 1;

  for (int i=0; i<n; i++) {
    double t = ((n==1) ? 0 : ((double)i)/(n-1));
    t = Math.sqrt(t);
    t = multFactor*t * (2*PI/Math.sqrt(6*Z)); // 0 to 45 degrees...
    double x = Rb * Math.cos (t) + Rb * t * Math.sin(t);
    double y = Rb * Math.sin(t) - Rb * t * Math.cos(t);
    Point p = new Point(x, y);
    ret[i]=p;
  }
  return ret;
}

Point[] involuteTooth(double m, int Z, double phi, int n) {
  Point[] points = involuteCurve(m, Z, phi, n, true);
  Point[] points2 = involuteCurve(m, Z, phi, n, false);
  final double THICKNESS_ANGLE  = ((2*PI/Z)/2)*1.25;
  rotatePoints(points, THICKNESS_ANGLE);
  Point[] ret = new Point[2*n];
  for (int i=0; i<n; i++) {
    ret[i] = points[i];
    ret[n+points2.length-i-1] = points2[i];
  }

  return ret;
}

Point[] involuteGear(double m, int Z, double phi, int n) {

  Point[] ret = new Point[2*n*Z];
  int base = 0;
  for (int j = 0; j<Z; j++) {
    Point[] points = involuteTooth(m, Z, phi, n);
    //println(ret.length + ", " + points.length *Z);
    rotatePoints(points, -j*(2*PI/Z));
    for (int i=0; i<points.length; i++) {  
      //println("   " + (base+i));     
      ret[base] = points[i];
      base++;
    }
  }

  return ret;
}

void rotatePoints(Point[] points, double angle) {
  for (int i=0; i<points.length; i++) {
    points[i].rotate(angle);
  }
}


Point[] involuteRackTooth(double m, int Z, double phi) {
  double c = Math.cos(phi);
  double s = Math.sin(phi);
  double D = Z*m;
  double circ = PI*D;
  Point[] points = new Point[4];
  points[0] = new Point(0, 0);
  points[1] = new Point(m*s, 1.3*m*c);
  points[2] = new Point(m*s + 0.25*circ/Z, 1.3* m*c);
  points[3] = new Point(m*s + 0.25*circ/Z + m*s, 0);
  return points;
}
void  drawRack(double cx, double cy, double r, int nTeeth) {
  double D = 1;
  int Z = 10;
  double m = D/Z;
  double phi = radians(20); 
  double circ = PI*D;
  Point[] points = involuteRackTooth(m, Z, phi);
  pg.fill(0);
  double dB = 1.047; // 0.98;// Was 1.05;
  //nTeeth++;
  double baseInc = dB*r*circ/Z;
  double base = baseInc/3.3; //baseInc/2.0; //baseInc/3.0;
  pg.beginShape();
  for (int j=0; j<nTeeth; j++) {
    for (int i =0; i<points.length; i++) {
      float x = (float) points[i].x;
      float y = (float) points[i].y;
      //float SCALE = 100;
      //pg.ellipse(width/2 + SCALE*x, height/2 - SCALE*y, 5, 5); // - because of upside-down coords
      pg.vertex((float) (cx+base+r*x), (float) (cy-r*y));
    }
    base +=  baseInc;
  }
  // bottom ...
  base -= baseInc/3.0; // was *0.3;
  pg.vertex((float)(cx+base), (float)cy);
  pg.vertex((float)(cx+base), (float)(cy+r*0.2));
  pg.vertex((float)cx, (float)(cy+r*0.2));
  pg.vertex((float)cx, (float) cy);
  pg.endShape(CLOSE);
}