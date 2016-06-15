
// Gear definitions and drawing based on http://arc.id.au/GearDrawing.html
class Gear {
  final double phi = radians(20);  // Pressure angle
  final float m = PI*5; // Module. D = m * Z, so with 10 teeth this is a diameter of 50
  double D; // Pitch circle diameter
  Point c=new Point(0, 0); // center
  int Z=0;  // number of teeth

  Gear(int nTeeth) {
    this.Z = nTeeth;
    this.D = m*Z;
  }


  void draw(float rot) {
    // void drawGear2(double cx, double cy, double r, double r1Frac) {   
    int n = 10; // Number of points in the actual involute curve on the side of each tooth
    //float r1Frac = 0.2; // fraction to draw inner dia.
    Point[] points = involuteGear(m, Z, phi, n);
    pg.pushMatrix();
    pg.translate((float)c.x, (float)c.y);
    pg.rotate(rot);
    pg.stroke(255);
    pg.strokeWeight(1);
    pg.fill(100);
    pg.beginShape();
    for (int i =0; i<points.length; i++) {
      float x = (float) points[i].x;
      float y = (float) points[i].y;
      //pg.vertex((float)(c.x + D/2*x), (float)(c.y - D/2*y));
      pg.vertex((float)(x), (float)(- y));
    }
    pg.endShape(CLOSE);
    pg.popMatrix();

    // Draw central hole.
    pg.fill(75);
    //pg.ellipse((float)c.x, (float)c.y, (float)(D/2*r1Frac), (float)(D/2*r1Frac));
    pg.ellipse((float)c.x, (float)c.y, 20, 20);
  }
}