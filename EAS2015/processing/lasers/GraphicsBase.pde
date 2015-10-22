



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
  void draw(float x, float y, float orientation, ShapeState state);
}

// outline weight and color
// background fill 
// cap stype
// text: font, emphasis, size, color
public final String DEFAULT_FONT = "Segoe WP Black";
class GraphicsParams {
  public int borderColor=0; // -1 means don't set
  public int borderWeight=1; // -1 means don't set
  public int backgroundFill=-255; // -1 means don't set
  public PFont font= createFont(DEFAULT_FONT, 7); // null means don't set
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

class Laser implements  Drawable {
  int id;
  String label;
  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  Laser(int id, GraphicsParams params, GraphicsParams hilightedParams) {
    this.label = "L"+id;
    this.id = id;
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }

  void draw(float x, float y, float orientation, ShapeState state) {
    GraphicsParams params = (state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    int a = 30, b=10;
    pushMatrix();
    translate(x, y);
    rotate(radians(-orientation));
    gUtils.setShapeParams(params);
    beginShape();
    vertex(-a, -b);
    vertex(-a, b);
    vertex(2*a/3, b);
    vertex(a, 0);
    vertex(2*a/3, -b);
    vertex(-a, -b);
    endShape();
    gUtils.setTextParams(params);
    // Don't have upside-down text
    if (abs(orientation)>90) {
      rotate(radians(180));
    }
    text(label, -a/4, -a/10);
    popMatrix();
  }
}


class TextBox implements  Drawable {

  String label;
  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  TextBox(String label, GraphicsParams params, GraphicsParams hilightedParams) {
    this.label = label;
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }

  void draw(float x, float y, float orientation, ShapeState state) {
    GraphicsParams params = (state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    int a = 30, b=10;
    pushMatrix();
    translate(x, y);
    rotate(radians(-orientation));
    gUtils.setShapeParams(params);
    rectMode(CENTER);
    rect(0, 0, 30, 30);
    gUtils.setTextParams(params);
    text(label, 0, -b/4.0);
    popMatrix();
  }
}

class TwowayMirror implements  Drawable {

  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  TwowayMirror(GraphicsParams params, GraphicsParams hilightedParams) {
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }

  void draw(float x, float y, float orientation, ShapeState state) {
    GraphicsParams params = (state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    int a = 30, b=10;
    gUtils.pushTransform(x, y, orientation);
    //gUtils.setShapeParams(params);
    noStroke();
    fill(params.borderColor);
    rectMode(CENTER);
    rect(0, 0, 5, 30); // A vertical mirror - corresponding to it's NORMAL having an orientation of0
    gUtils.popTransform();
  }
}

class Dot implements  Drawable {

  GraphicsParams  graphicsParams;
  GraphicsParams  hilightedGraphicsParams;

  Dot(GraphicsParams params, GraphicsParams hilightedParams) {
    this.graphicsParams = params;
    this.hilightedGraphicsParams = hilightedParams;
  }

  void draw(float x, float y, float orientation, ShapeState state) {
    GraphicsParams params = (state==ShapeState.HILIGHTED)?hilightedGraphicsParams:graphicsParams;
    int a = 30, b=10;
    noStroke();
    fill(params.borderColor);
    ellipseMode(CENTER);
    ellipse(x, y, 2, 2);
  }
}

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

  public Cell(int i, int j) {
    this.i = i;
    this.j = j;
  }

  String getClassName() {
    String className = (dObject==null)  ? "" : dObject.getClass().getName();
    className = className.substring(className.indexOf("$")+1); // relise of indexOf returning -1 if not found.
    return className;
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
          cell.dObject.draw(cell.center.x, cell.center.y, cell.orientation, 
            cell.state);
        }
      }
    }
  }
}