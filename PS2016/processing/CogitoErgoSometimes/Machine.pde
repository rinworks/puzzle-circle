// Contains the whole contraption, including all gears
class Machine {
  Gear[][] gears;

  Machine() {
    int[][] teethCounts  = {
      {15}, 
      {20}, 
      {30}, 
      {18}, 
      {16}
    };

    initializeGears(teethCounts);
    positionGears();
  }

  // Initialize the specifics (but not absolute position) of the gears.
  // The pitch radii is computed by multiplying the pitchRadii array element
  // by scale.
  void initializeGears(int[][] teeth) {
    gears = new Gear[teeth.length][];
    for (int col = 0; col < teeth.length; col++) {
      int[] colTeeth = teeth[col];
      Gear[] column = new Gear[colTeeth.length];
      for (int i = 0; i<colTeeth.length; i++) {
        column[i]  =new Gear(colTeeth[i]);
      }
      gears[col] = column;
    }
  }

  // Position the 2D gear layout
  void positionGears() {
    double V_OFFSET = 20; // Vertical space on top

    // First we position the center gear.
    int iCenter = gears.length/2;  //0 1 [2] 3 4 5
    Gear gCenter = gears[iCenter][0];
    gCenter.c.x = imageWidth/2;
    gCenter.c.y = gCenter.D/2 + V_OFFSET;

    // Next we position the tops of each column: the y value matches (for now) the center
    for (Gear[] col : gears) {
      Gear g  = col[0];
      if (g != gCenter) {
        g.c.y = gCenter.c.y;
      }
    }

    // Now position the x centers of the the tops...
    // Starting from the middle and radiating outwards...
    for (int i=0; i< gears.length/2; i++) {
      int left = iCenter-i;
      int right = iCenter+i;
      if (left>0) {
        fixHorizontalPosition(left, -1); // towards left;
      }
      if ((right+1)<gears.length) {
        fixHorizontalPosition(right, 1); // towards right;
      }
    }
  }
  boolean almostEqual(double a, double b) {
    return Math.abs(a-b)<0.001;
  }

  void fixHorizontalPosition(int prevIndex, int direction) {
    final int EXTRA_SPACE = 8; // Extra space between gears
    assert(Math.abs(direction)==1); // direction must be +/- 1
    Gear gPrev = gears[prevIndex][0];
    Gear gNew = gears[prevIndex+direction][0];

    // We expect the top gear at prevIndex to have its xValue already set (i.e., nozero)
    // While gNew/s x value should not be set (i.e., 0),
    // and both gPrev and gNew to have the same y value (for now)
    assert(!almostEqual(gPrev.c.x, 0));
    assert(almostEqual(gNew.c.x, 0));
    assert(almostEqual(gPrev.c.y, gNew.c.y));
    gNew.c.x = gPrev.c.x + (gNew.D+gPrev.D+EXTRA_SPACE)*direction*0.5; // left or right, depending on directon (0.5 to go from D to r)
  }

  void verticalLine(int x) {
    pg.stroke(1);
    pg.fill(0);
    pg.line(x, 0, x, imageHeight);
  }
  void horizontalLine(int y) {
    pg.stroke(1);
    pg.fill(0);
    pg.line(0, y, imageWidth, y);
  }


  void drawGears() {
    float[][] rotations = {
      {0}, 
      {2}, 
      {0}, // Center
      {2}, 
      {0} 
    };
    horizontalLine(imageHeight/2);
    verticalLine(imageWidth/2);
    //float angle =((float)frameCount/360)*2*PI;
    //println(angle);

    // For now we just draw the top layer...
    for (int i=0; i<gears.length; i++) {
      Gear g = gears[i][0];
      float rot = radians(rotations[i][0]);
      pg.stroke(128);
      pg.noFill();
      pg.ellipse((float)g.c.x, (float)g.c.y, (float)g.D/2, (float)g.D/2);
      //drawGear2(g.c.x, g.c.y, g.D/2*1.8, 0.2);
      g.draw2(rot);
    }
  }
}