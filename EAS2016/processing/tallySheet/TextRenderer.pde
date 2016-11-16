import java.util.Hashtable;

class TextStyleInfo {
  public PFont font;
  public color col;
  public int size;

  public TextStyleInfo(PFont f, color c, int s) {
    font = f;
    col = c;
    size = s;
  }
}

class TextRenderer {
  Hashtable<String, TextStyleInfo> styleTable = new Hashtable<String, TextStyleInfo>();
  TextStyleInfo curStyle = null;
  Point origin; // Top left corner
  int wRegion;   // width
  int hRegion;  // height
  final String DEFAULT_FONT = "Segoe WP Black";
  final int DEFAULT_FONT_SIZE = 10;
  final color DEFAULT_COLOR = color(0);
  final int LINE_SPACING = 10;
  int curDY=2*DEFAULT_FONT_SIZE;

  public TextRenderer(Point origin, int wRegion, int hRegion) {
    this.origin = new Point(origin.x, origin.y);
    this.wRegion = wRegion;
    this.hRegion = hRegion;
    addStyle("DEFAULT", DEFAULT_FONT, DEFAULT_FONT_SIZE, DEFAULT_COLOR);
    setStyle("DEFAULT");
  }

  public void moveTo(int newX, int newY, int newWRegion, int newHRegion) {
    origin.x = newX;
    origin.y = newY;
    wRegion  = newWRegion;
    hRegion = newHRegion;
    curDY = 2*DEFAULT_FONT_SIZE;
  }

  void addStyle(String styleName, String fontName, int size, color c) {
    PFont font =  createFont(fontName, size);
    TextStyleInfo info = new TextStyleInfo(font, c, size);
    styleTable.put(styleName, info);
  }

  public void renderText(String text, String style) {
    setStyle(style);
    renderText(text);
  }

  public TextRenderer setStyle(String style) {
    curStyle = styleTable.get(style);
    return this;
  }

  public void renderText(String text) {
    textFont(curStyle.font);
    textSize(curStyle.size);
    //println("rendering text " + text + " dy: " + curDY);
    fill(curStyle.col);

    // Process special chars...
    float dX = 0.0;
    if (text.indexOf(">>") == 0) {
      // Push to rilign(RIGHT);
      dX = wRegion;
      textAlign(RIGHT);
      text = text.substring(2);
    } else if (text.indexOf("<<") == 0) {
      // Push to rilign(RIGHT);
      dX = 0;
      textAlign(LEFT);
      text = text.substring(2);
    } else {
      // Center - default
      dX = wRegion/2;
      textAlign(CENTER);
    }

    String[]lines = text.split("\n");
    for (String oneLine : lines) {
      text(oneLine, origin.x+dX, origin.y+curDY);
      moveDownBy(curStyle.size);
    }
    //ellipse(0, 0, 200, 200);
  }

  // Skip dy pixels and continue
  // Return new absolute y value.
  // use moveDown(0) to get current absolute value.
  public int moveDownBy(int dy) {
    curDY += dy;
    return (int) (origin.y+curDY);
  }

  // Repositon y position to new absolute value
  // Return new absolute y value.
  // use moveDown(0) to get current absolute value.
  public int moveDownTo(int y) {
    origin.y = y;
    curDY = 0;
    return (int) (origin.y+curDY);
  }
}