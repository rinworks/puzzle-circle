// Contains the whole contraption, including all gears
class Machine {
  Gear[][] gears;

  int[][] teethCounts  = {
    {22, 10, 22}, // 16
    {20, 15, 20}, // 18
    {38, 11, 16}, // 6, Center
    {15, 12, 18}, // 2
    {25, 13, 14}  // 10
  };

  // Dimensions should match teethCounts
  float[][] rotations = {
    {-6, 5, -6}, 
    {-3, -6, 6}, 
    {0, -4, -1}, // Center
    {6, -4, 0}, 
    {-2, -3, -9} 
  };

  int[][] teethCountsX  = {
    {20, 18}, 
    {37, 16}, // Center
    {18, 14}
  };

  // Dimensions should match teethCounts
  float[][] rotationsX = {
    {2, 0}, 
    {0, 0}, // Center
    {2, 0} 
  };



  Machine() {

    // Verify that the dimensions of rotations are the same 
    assert(teethCounts.length == rotations.length);
    for (int i=0; i<teethCounts.length; i++) {
      assert(teethCounts[i].length == rotations[i].length);
    }
    initializeGears(teethCounts);
    positionGears();
    levelBottomBases();
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

    // Now go down each column, positioning the y's
    for (int i=0; i< gears.length; i++) {
      Gear[] col = gears[i];
      for (int j=0; (j+1)< col.length; j++) {
        Gear gPrev = col[j];
        Gear gNew = col[j+1];
        gNew.c.x = gPrev.c.x;
        fixVerticalPosition(gPrev, gNew);
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

  void fixHorizontalPosition2(int prevIndex, int direction, double maxBotY) {
    assert(Math.abs(direction)==1); // direction must be +/- 1
    Gear gPrev = gears[prevIndex][0];
    Gear[] gNewCol = gears[prevIndex+direction];
    Gear gNew = gNewCol[0];

    // We expect the top gear at prevIndex to have its xValue already set (i.e., nozero)
    // While gNew/s x value should not be set (i.e., 0),
    // and both gPrev and gNew to have the same y value (for now)
    //assert(!almostEqual(gPrev.c.x, 0));
    //assert(almostEqual(gNew.c.x, 0));
    //assert(almostEqual(gPrev.c.y, gNew.c.y));
    //gNew.c.x = gPrev.c.x + (gNew.D+gPrev.D+EXTRA_SPACE)*direction*0.5; // left or right, depending on directon (0.5 to go from D to r)
    Gear gBot = gNewCol[gNewCol.length-1];
    double deltaY = maxBotY-(gBot.c.y+gBot.D/2);
    println("deltaY: " + deltaY);
    touchGear(gPrev, gNew, gPrev.c.x +(gNew.D+gPrev.D)*direction*0.5, gNew.c.y+deltaY);
    //touchGear(gPrev, gNew, gNew.c.x, gNew.c.y);
  }

  void fixVerticalPosition(Gear gPrev, Gear gNew) {
    final int EXTRA_SPACE = 8; // Extra space between gears

    // We expect the top gear at prevIndex to have its yValue already set (i.e., nozero)
    // While gNew/s y value should not be set (i.e., 0),
    // and both gPrev and gNew to have the same x value (for now)
    assert(!almostEqual(gPrev.c.y, 0));
    assert(almostEqual(gNew.c.y, 0));
    assert(almostEqual(gPrev.c.x, gNew.c.x));
    gNew.c.y = gPrev.c.y + (gNew.D+gPrev.D+EXTRA_SPACE)*0.5; // (0.5 to go from D to r)
  }

  // Assuming the top gear in col is in position, determine the position
  // of the gears below, offseting center x values so that the last gear has
  // a position of targetBaseX (or as close to it as possible, given that gears have to touch)
  void fixColumn(Gear[] col, double targetBaseX) {
    double startX = col[0].c.x;
    double deltaX = targetBaseX-startX;
    for (int i=0; (i+1)< col.length; i++) {
      Gear gPrev = col[i];
      Gear gNew = col[i+1];
      double x = startX + deltaX * (i+1) / (col.length-1);
      touchGear(gPrev, gNew, x, gPrev.c.y + (gNew.D+gPrev.D)*0.5); // (0.5 to go from D to r)
    }
  }

  // Attempt to nudge all the gears so that the *bottom* of the bottom gears are horizontally aligned.
  // The gears are assumed to be viable (touching) and they remain viable.
  void levelBottomBases() {

    // Find the y value of the base of the bottommost gear...
    double maxBotY = 0;
    for (Gear[] col : gears) {
      Gear g = col[col.length-1];
      double bot = g.c.y+g.D/2;
      maxBotY = Math.max(maxBotY, bot);
    }
    println("maxBotY: " + maxBotY);
    int iCenter = gears.length/2;  //0 1 [2] 3 4 5
    Gear gCenter = gears[iCenter][0];

    //
    // Starting from the middle and radiating outwards...
    for (int i=0; i< gears.length/2; i++) {
      int left = iCenter-i;
      int right = iCenter+i;
      if (left>0) {
        fixHorizontalPosition2(left, -1, maxBotY); // towards left;
      }
      if ((right+1)<gears.length) {
        fixHorizontalPosition2(right, 1, maxBotY); // towards right;
      }
    }
    
    // Now fix each column...
    // Now go down each column, positioning the y's and tweaking the xs.
    int nCols = gears.length;
    double xSpan = gears[nCols-1][0].c.x - gears[0][0].c.x;
    double xSeparation  = (nCols<2) ? 0 : xSpan/(nCols-1);
    double targetX0 = gCenter.c.x - xSeparation*iCenter;
    for (int i=0; i< gears.length; i++) {
      Gear[] col = gears[i];
      fixColumn(col, targetX0 + xSeparation*i);
    }
  }

  // Move gNew to touch gCur with gNew's center as close as possible to (x,y)
  public void touchGear(Gear gCur, Gear gNew, double x, double y) {
    double space = extraGearSpacing(gCur, gNew);
    double d = (gCur.D+gNew.D)/2+space;
    double d1  = gCur.c.distance(x, y);
    gNew.c.x = gCur.c.x + (x-gCur.c.x)*d/d1;
    gNew.c.y = gCur.c.y + (y-gCur.c.y)*d/d1;
  }

  // Return extra spacing (if any) between gears so that they don't bump
  double extraGearSpacing(Gear g1, Gear g2) {
    double dist = g1.c.distance(g2.c.x, g2.c.y);
    double offset = 350;
    double base = 2;
    double scale = 0.040;
    double delta = base + (offset-dist)*scale;
    println("delta: " + delta);
    return delta; // TODO
    
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
    // Rotations by which to tweak each gear - in degrees, *clockwise*.

    //horizontalLine(imageHeight/2);
    //verticalLine(imageWidth/2);
    //float angle =((float)frameCount/360)*2*PI;
    //println(angle);

    for (int i=0; i<gears.length; i++) {
      Gear[] col = gears[i];
      for (int j=0; j<col.length; j++) {
        Gear g = col[j];
        float rot = radians(rotations[i][j]);
        //pg.stroke(128);
        //pg.noFill();
        //pg.ellipse((float)g.c.x, (float)g.c.y, (float)g.D/2, (float)g.D/2);
        g.draw(rot);
      }
    }
  }
}