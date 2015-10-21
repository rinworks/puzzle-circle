class Point {
  int x;
  int y;
  Point(int xx, int yy) {
    x=xx;
    y=yy;
  }
  String toString() {
    return "("+x+","+y+")";
  }
}

class HideInfo {
  boolean hideStation;
  boolean hideSE;
  boolean hideSW;
}

static final int ROWS = 4;
static final int COLS = 5;
Point[][] points = new Point[ROWS][COLS];
HideInfo[][] hidden = new HideInfo[ROWS][COLS];



void setup() {
  size(1200, 500);
  rectMode(CENTER);
  //drawStation(new Point(100,200), "@\n#\n$");
  //drawLink(new Point(100,250), new Point(900,490));
  String[][] trains = {
    {
      "#", "-", "[#]", "#>\n<#", "<$\n<#"
    }
    , 
    {
      "$", "#>\n[+]", "[$]", "$>", "$>\n#>"
    }
    , 
    {
      "@", "@>", "$>\n@>", "<+", "[@]\n<+"
    }
    , 
    {
      "+", "+>", "+>", "+>", "+>"
    }
  }; 

  // Specify hidden stations and links.
  HideInfo hi = new HideInfo();
  hi.hideStation = true;  
  hidden[0][1] = hi;
  hi = new HideInfo();
  hi.hideSE = true;  
  hidden[0][2] = hi;
  hi = new HideInfo();
  hi.hideSW = true;  
  hi.hideSE = true;  
  hidden[2][2] = hi;


  // Init points...
  for (int i=0; i<ROWS; i++) {
    int y = 50 + i*80;
    int xBase = i%2==0 ? 70 : 170;
    for (int j=0; j<COLS; j++) {
      int x = xBase + j * 185; 
      points[i][j] = new Point(x, y);
    }
  }
  
  // Draw background
  background(255);

  // Draw   links...
  for (int i=0; i<ROWS; i++) {
    for (int j=0; j<COLS; j++) {
      if (j>0) {
        // horizontal links...
        drawLink(points[i][j-1], points[i][j]);
      }


      // cross links...
      if (i%2==0) {
        HideInfo hi2 = hidden[i][j];
        if (i<ROWS-1 && j<COLS-1) {      
          if (hi2==null || !hi2.hideSE) {
            //drawLink(myLerp(i, j, 0.52), myLerp(i+1, j, 0.48)); // SE
            drawLink(myLerp(i, j, 0.50), myLerp(i+1, j, 0.50)); // SE
          }

          if (j>0) {
            if (hi2==null || !hi2.hideSW) {
              //drawLink(myLerp(i+1, j-1, 0.52), myLerp(i, j, 0.48));
              drawLink(myLerp(i+1, j-1, 0.50), myLerp(i, j, 0.50)); // SW
            }
          }
        }

        if (i>0 && j<COLS-1) {
          //drawLink(myLerp(i, j, 0.35), myLerp(i-1, j, 0.35)); // NE
          drawLink(myLerp(i, j, 0.15), myLerp(i-1, j, 0.4)); // NE

          if (j>0) {
            drawLink(myLerp(i-1, j-1, 0.60), myLerp(i, j, 0.850)); // NW
            //drawLink(myLerp(i-1, j-1, 0.65), myLerp(i, j, 0.65)); // NW
          }
        }
      }
    }
  }
  
  // Add 2 end loops on the right hand side...
  drawRightCap(0,1);
  drawRightCap(2,3);
  
  // Draw bridges
  drawBridge(lerpPoint(myLerp(2,1, 0.5),points[1][1], 0.5), radians(-45));
  drawBridge(lerpPoint(myLerp(2,2, 0.5),points[1][2], 0.5), radians(-45));
  drawBridge(lerpPoint(myLerp(2,3, 0.5),points[1][3], 0.5), radians(-45));


  // Draw  stations...
  for (int i=0; i<ROWS; i++) {
    for (int j=0; j<COLS; j++) {
      HideInfo hi2 = hidden[i][j];
      if (hi2==null || !hi2.hideStation) {
        drawStation(points[i][j], trains[i][j]);
      }
    }
  }
}

Point myLerp(int i, int j, float frac) {
  return lerpPoint(points[i][j], points[i][j+1], frac);
}

// Draw a loop on the RHS end of the grid between the specified rows
void drawRightCap(int i, int j) {
  drawLoop(myLerp(i, COLS-2, 1.125), myLerp(j, COLS-2, 1.125));
}

