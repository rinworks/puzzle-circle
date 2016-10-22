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

interface Drawable {
  //void draw(float x, float y, float orientation, ShapeState state);
  void draw(Cell c);
}

// outline weight and color
// background fill 
// cap stype
// text: font, emphasis, size, color

class GraphicsParams {
  public int borderColor=0; // -1 means don't set
  public int borderWeight=1; // -1 means don't set
  public int backgroundFill=-255; // -1 means don't set
  public PFont font=null; // null means don't set
  public int textSize=20; // -1 means don't set
  public int textColor=0; // -1 means don't set
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
}

Utils gUtils = new Utils();




class Cell {
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

  public Cell(int i, int j) {
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


class Grid {

  public Cell[][] cells;
  int rows;
  int cols;
  int gridWidth;
  int gridHeight;
  int cellPadding;  

  Grid(int rows, int cols, int gridWidth, int gridHeight, int cellPadding) {
    this.rows = rows;
    this.cols = cols;
    this.gridWidth = gridWidth;
    this.gridHeight = gridHeight;
    this.cellPadding = cellPadding;
    this.cells  = new Cell[rows][cols];

    // Calculate per-cell quantities
    float eW = (float)gridWidth/cols;
    float eH = (float)gridHeight/rows;
    float iW = max(eW-cellPadding, 0.0);
    float iH = max(eH-cellPadding, 0.0);


    for (int i=0; i<rows; i++) {
      for (int j=0; j<cols; j++) {
        Cell c = new Cell(i, j);
        c.eW  = eW;
        c.eH = eH;
        c.iW = iW;
        c.iH = iH;
        c.center = new Point(c.eW*(j+0.5), c.eH*(i+0.5));
        this.cells[i][j]  = c;
      }
    }
  }

  void draw() {
    for (int i=0; i<rows; i++) {
      for (int j=0; j<cols; j++) {
        Cell cell  = this.cells[i][j];
        if (cell.dObject!=null) {
          cell.dObject.draw(cell);
        }
      }
    }
  }

  // Return the cell at [i,j] if i and j
  // are within bounds, null otherwise.
  Cell tryGetCell(int i, int j) {
    return  (i>=0 && i<rows && j>=0 && j<cols) ? cells[i][j] : null;
  }

  // Clear the "visited" status of all cells
  void clearVisited() {
    for (Cell[] row : cells) {
      for (Cell c : row) {
        c.visited = false;
      }
    }
  }
}