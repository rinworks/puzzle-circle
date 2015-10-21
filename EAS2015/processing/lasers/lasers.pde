import java.util.Comparator;
import java.util.Arrays;

void setup() {
  size(750, 1080);


  // ;==v and :==/
  String[] positions = {
    ".............", 
    ".../.....:...", 
    ".....>...::..", 
    ".....;>..:::.", 
    "..>/E:.. ....", 
    "./.:......:I.", 
    "..>./...J....", 
    "...T.../...<.", 
    "...P...OD....", 
    "...:....:..<.", 
    "...U../X^....", 
    ".^//.::..//<.", 
    ".>./.N..:^...", 
    "..:.:..<:./..", 
    "....^.^......", 
    "............."
  };

  int[] laserIds = {11, 5, 7, 13, 6, 14, 10, 8, 12, 15, 3, 9, 1, 2, 4};

  Grid g = genObjects(positions, laserIds);
  g.draw();
  g.drawPaths();
  //println(PFont.list());
}

Grid genObjects(String[] spec, int[] laserIds) {
  GraphicsParams params = new GraphicsParams();
  params.textColor = 0;
  params.backgroundFill = 255;
  GraphicsParams laserParams = new GraphicsParams();
  laserParams.textColor = 255;
  laserParams.backgroundFill = color(255, 0, 0);
  laserParams.borderColor = -1;
  int rows = spec.length;
  int cols = (rows>0)? spec[0].length():0;
  int laserCount = 0;
  int GRID_WIDTH = width;
  int GRID_HEIGHT = height;
  int GRID_PADDING = 10;
  Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING);
  for (int i=0; i<rows; i++) {
    String row = spec[i];
    for (int j=0; j<cols; j++) {
      Drawable d = null;
      float orientation = 0;
      char c = row.charAt(j);
      if (c=='.') {
        d = new Dot(params, params);
      } else if (c=='<'||c=='>'||c=='^'||c==';') {
        d = new Laser(laserIds[laserCount], laserParams, laserParams);
        laserCount++;
      } else if  (c=='|'||c=='-'||c=='/'||c==':') {
        d = new TwowayMirror(params, params);
      } else {
        d = new TextBox(""+c, params, params);
      }

      if (c=='<') {
        orientation = 180; // left facing
      } else if (c=='^'||c=='-') {
        orientation = 90; // upwards facing
      } else if (c==';') {
        orientation = -90; // downwards facing
      } else if (c=='/') {
        orientation = -45;
      } else if (c==':') { // equivalent to backslash
        orientation = 45;
      }
      if (d!=null) {
        Cell cl = g.cells[i][j];
        cl.dObject = d;
        cl.orientation = orientation;
        println(d + " at ["+i+","+j+"] orientation "+orientation + cl.center);
      }
    }
  }
  return g;
}


// Draw the laser paths and return a string containing
// any letters hit, in order of laserIds.
String drawPaths(Grid g) {
  Cell[] laserCells = findLasers(g);
  for (Cell c in laserCells) {
    Laser l = laserFromCell(c);
    println("Found laser " + l.id + "at (" + c.i + "," + c.j + ")");
  }
  return "";
}

// Return all cells with lasers, in order of
// increasing laserIds.
Cell[] findLasers(Grid g) {
  ArrayList<Cell> list = new ArrayList<Cell>();
  for (int i=0; i<g.rows; i++) {
    for (int j=0; j<g.cols; j++) {
      Cell c = g.cells[i][j];
      //Drawable
      if (c.dObject instanceof Laser) {
        list.add(c);
      }
    }
  }  
  Comparator<Cell> comp 
      = new Comparator<Cell>() {
      public int compare(Cell c1, Cell c2) {
        return laserFromCell(c1).id-laserFromCell(l20.id;
      }
    };
  Cell[] ret = list.toArray(new Cell[list.size()]);
  Arrays.sort(ret, comp);
  return ret;
}

Laser laserFromCell(Cell c) {
  return (Laser) c.dObject;
}