// Subset of GraphicsBase from the laser puzzle
//

class Point {
  float x, y;

  Point(float x, float y) {
    this.x = x; 
    this.y=y;
  }  

  String toString() {
    return "("+x+","+y+")";
  }
}

enum ShapeState {
  NORMAL, 
    HILIGHTED
}

enum LineType {
  UNCHANGED, 
    SOLID, 
    DASHED, 
    DOTTED
}

interface Drawable {
  void draw();
}

// outline weight and color
// background fill 
// cap stype
// text: font, emphasis, size, color

class GraphicsParams {
  public int borderColor=0; // -1 means don't set
  public int borderWeight=1; // -1 means don't set
  public LineType borderType = LineType.SOLID; // UNCHANGED means don't change;
  public float markPeriod = -1.0; // Period between dot or dash - -ve means don't change.
  public int backgroundFill=255; // -1 means don't set
  public PFont font=null; // null means don't set
  public PFont smallFont = null; // font for small text; null means don't set.
  public int textSize=-1; // -1 means don't set
  public int smallTextSize=-1; // -1 means don't set
  public int textColor=0; // -1 means don't set
  public int smallTextColor=-1; // -1 means don't set

  public GraphicsParams() {
  }

  public GraphicsParams(GraphicsParams gp) {
    borderColor = gp.borderColor;
    borderWeight = gp.borderWeight;
    backgroundFill = gp.backgroundFill;
    font = gp.font;
    smallFont = gp.smallFont;
    textSize = gp.textSize;
    smallTextSize = gp.smallTextSize;
    textColor = gp.textColor;
    smallTextColor = gp.smallTextColor;
  }
}

class Utils {
  void pushTransform(float x, float y, float orientation) {
    pushMatrix();
    translate(x, y);
    rotate(radians(-orientation));
  }

  void popTransform() {
    popMatrix();
  }

  void setShapeParams(GraphicsParams p) {
    if (p.borderColor==-1) {
      noStroke();
    } else {
      stroke(p.borderColor);
    }
    if (p.borderWeight<=0) {
      noStroke();
    } else {
      strokeWeight(p.borderWeight);
    }
    if (p.backgroundFill==-1) {
      noFill();
    } else {
      fill(p.backgroundFill);
    }
  }

  void setTextParams(GraphicsParams p) {
    if (p.font!=null) {
      textFont(p.font);
    }
    if (p.textSize!=-1) {
      textSize(p.textSize);
    }
    textAlign(CENTER, CENTER);
    if (p.textColor!=-1) {
      fill(p.textColor);
    }
  }

  void setSmallTextParams(GraphicsParams p) {
    if (p.smallFont!=null) {
      textFont(p.smallFont);
    }
    if (p.smallTextSize!=-1) {
      textSize(p.smallTextSize);
    }
    textAlign(CENTER, CENTER);
    if (p.smallTextColor!=-1) {
      fill(p.smallTextColor);
    }
  }

  // First dot is at (x1, y1). Subsequent dots are spaced "space" apart
  void dottedLine(float x1, float y1, float x2, float y2, float space) {
    //point(x1, y1);
    //point(x1, y1);
    double dx = x2-x1;
    double dy = y2-y1;
    double len = Math.sqrt(dx*dx+dy*dy);
    space = max(space, 0.1); // To avoid divide by zero. Units: pixels.
    int n = (int) (len/space); // Note truncation of fractional part.
    double len1 = Math.max(len, 0.1); // To avoid divide by zero.
    double ddx = space*dx/len1;
    double ddy = space*dy/len1;
    for (int i=0; i<n; i++) {
      float x = (float) (x1 + i*ddx);
      float y = (float) (y1 + i*ddy);
      point(x, y);
    }
  }

  // Dots start upper left
  void dottedRect(float x, float y, float w, float h, float space) {
    float x1, y1, x2, y2;
    assert(getGraphics().rectMode == CENTER); // Only kind we support for now.. later we can addmore.
    x1 = x-w/2;
    x2 = x1+w;
    y1 = y-h/2;
    y2 = y1+h;
    float sw = getGraphics().strokeWeight;
    // We have to draw a rectangle *without* borders first,
    // then add on the dotted lines after restoring stroke width...
    noStroke();
    rect(x, y, w, h);
    stroke(sw);
    dottedLine(x1, y1, x2, y1, space); // North
    dottedLine(x1, y2, x2, y2, space); // South
    dottedLine(x2, y1, x2, y2, space); // East
    dottedLine(x1, y1, x1, y2, space); // West
  }

  // Note - to make this predictable, 
  // set the random seed before calling, using randomSeed()
  public void randomPermutation(int[] arr) {
    if (arr.length<2) return;
    for (int i=0; i<arr.length-1; i++) {
      swap(arr, i, (int) random(i+1, arr.length));
    }
  }

  void swap(int[] arr, int i, int j) {
    int t = arr[i];
    arr[i] = arr[j];
    arr[j] = t;
  }
}





class Cell {
  Grid g; // Grid that this cell is a part of.
  public int i; // location in grid
  public int j; // location in grid.
  public Point center = new Point(0, 0);
  public float eH=0; // external height
  public float eW=0; // external width
  public float iH=0; // internal height
  public float iW=0; // internal width
  public Drawable dObject=null;
  public float orientation=0;
  public ShapeState state = ShapeState.NORMAL;
  public Boolean visited=false; // Whether a path has visited this cell.

  public Cell(Grid g, int i, int j) {
    assert(i>=0 && i<g.cells.length);
    assert(j>=0 && g.cells.length>0 && j<g.cells[0].length);
    this.g = g;
    this.i = i;
    this.j = j;
  }

  String getClassName() {
    String className = (dObject==null)  ? "" : dObject.getClass().getName();
    className = className.substring(className.indexOf("$")+1); // relise of indexOf returning -1 if not found.
    return className;
  }

  public String coordsAsString() {
    return "["+i+","+j+"]";
  }
}


class Grid implements Drawable {

  public Cell[][] cells;
  int rows;
  int cols;
  Point origin;
  float gridWidth;
  float gridHeight;
  float cellPadding;  
  int borderWeight=0; // If nonzero, draw a (currently black) border of this weight around the whole grid. See borderWeight() method.

  // Construct a nested grid - within parent grid cell pc,
  Grid (Cell pc, int rows, int cols, int padding) {
    this(rows, cols, pc.eW, pc.eH, padding, pc.center.x-pc.eW/2.0, pc.center.y-pc.eH/2.0);
  }

  Grid(int rows, int cols, float gridWidth, float gridHeight, float cellPadding, float originX, float originY) {
    this.rows = rows;
    this.cols = cols;
    this.gridWidth = gridWidth;
    this.gridHeight = gridHeight;
    this.cellPadding = cellPadding;
    this.cells  = new Cell[rows][cols];
    this.origin = new Point(originX, originY);

    // Calculate per-cell quantities
    float eW = (float)gridWidth/cols;
    float eH = (float)gridHeight/rows;
    float iW = max(eW-cellPadding, 0.0);
    float iH = max(eH-cellPadding, 0.0);


    for (int i=0; i<rows; i++) {
      for (int j=0; j<cols; j++) {
        Cell c = new Cell(this, i, j);
        c.eW  = eW;
        c.eH = eH;
        c.iW = iW;
        c.iH = iH;
        c.center = new Point(origin.x+c.eW*(j+0.5), origin.y+c.eH*(i+0.5));
        this.cells[i][j]  = c;
      }
    }
  }

  void draw() {
    for (int i=0; i<rows; i++) {
      for (int j=0; j<cols; j++) {
        Cell cell  = this.cells[i][j];
        if (cell.dObject!=null) {
          cell.dObject.draw();
        }
      }
    }
    // If required, draw border.
    if (this.borderWeight>0) {
      stroke(0);
      strokeWeight(borderWeight);
      noFill();
      rectMode(CORNER);
      rect(origin.x, origin.y, gridWidth, gridHeight);
    }
  }

  // Return the cell at [i,j] if i and j
  // are within bounds, null otherwise.
  Cell tryGetCell(int i, int j) {
    return  (i>=0 && i<rows && j>=0 && j<cols) ? cells[i][j] : null;
  }

  // Set the border weight - if > 0 will result in a border being drawn.
  public Grid borderWeight(int weight) {
    assert(weight>=0);
    this.borderWeight = weight;
    return this;
  }

  // Clear the "visited" status of all cells
  void clearVisited() {
    for (Cell[] row : cells) {
      for (Cell c : row) {
        c.visited = false;
      }
    }
  }

  // Reposition the origin (top left corner) to the new location
  public void repositionOrigin(Point newOrigin) {
    float dx = newOrigin.x-origin.x;
    float dy = newOrigin.y-origin.y;
    this.moveBy(dx, dy);
  }

  // Move the entire grid by the specified amount
  // Recurse into child grids if necessary.
  public void moveBy(float dx, float dy) {
    for (Cell[] row : cells) {
      for (Cell c : row) {
        c.center.x += dx;
        c.center.y += dy;
        if (c.dObject instanceof Grid) {
          Grid cg = (Grid) c.dObject;
          cg.moveBy(dx, dy);
        }
      }
    }
  }
  
  // Horizontally center the grid
  public void horizontallyCenter() {
    Point newOrigin = new Point((width-gridWidth)/2, origin.y);
    repositionOrigin(newOrigin);
  }
}