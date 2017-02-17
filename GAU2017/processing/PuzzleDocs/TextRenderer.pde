// Module: TextRender
// History:
//  Feb 2017  - JMJ created, adapted from an older version, adding simplistic markdown support.

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

  // Styles controlling look of various MD text types
  public final String MD_H1_STYLE = "MD_H1_STYLE";
  public final String MD_PARA_STYLE = "MD_PARA_STYLE";
  public final String MD_FOOTER_STYLE = "MD_FOOTER_STYE";

  Hashtable<String, TextStyleInfo> styleTable = new Hashtable<String, TextStyleInfo>();
  TextStyleInfo curStyle = null;
  Point origin; // Top left corner
  int wRegion;   // width
  int hRegion;  // height
  final String DEFAULT_FONT = "Segoe WP Black";
  final int DEFAULT_FONT_SIZE = 10;
  final color DEFAULT_COLOR = color(0);
  //final int LINE_SPACING = 10;
  int curDY=0; // WAS 2*DEFAULT_FONT_SIZE;

  public TextRenderer(Point origin, int wRegion, int hRegion) {
    this.origin = new Point(origin.x, origin.y);
    this.wRegion = wRegion;
    this.hRegion = hRegion;
    addStyle("DEFAULT", DEFAULT_FONT, DEFAULT_FONT_SIZE, DEFAULT_COLOR);
    setStyle("DEFAULT");
    initDefaultMdStyles();
  }

  // Initialize default style values for various Markdown
  // text types.
  private void initDefaultMdStyles() {
    addStyle(MD_H1_STYLE, "Segoe", 40, color(0));
    addStyle(MD_PARA_STYLE, "Segoe", 15, color(0));
    addStyle(MD_FOOTER_STYLE, "Segoe", 12, color(0));
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

  // Render text with no line breaking.
  public void renderText(String text) {
    renderText(text, false);
  }
  // linebreak  - if true, linebreaks are inserted at WORD
  // boundaries to prevent text from extending past the right
  // boundary.
  public void renderText(String text, boolean linebreak) {
    textFont(curStyle.font);
    textSize(curStyle.size);
    //println("rendering text " + text + " dy: " + curDY);
    fill(curStyle.col);

    // Process special chars...
    float dX = 0.0;
    if (text.indexOf(">>") == 0) {
      // Push to rilign(RIGHT);
      dX = wRegion;
      textAlign(RIGHT, TOP);
      text = text.substring(2);
    } else if (text.indexOf("<<") == 0) {
      // Push to rilign(RIGHT);
      dX = 0;
      textAlign(LEFT, TOP);
      text = text.substring(2);
    } else {
      // Center - default
      dX = wRegion/2;
      textAlign(CENTER);
    }

    if (linebreak) {
      text = insertLinebreaks(text);
    }
    String[]lines = text.split("\n");
    for (String oneLine : lines) {
      text(oneLine, origin.x+dX, origin.y+curDY);
      moveDownBy(curStyle.size);
    }
  }

  // Render markdown text per styles that have already been set.
  public void renderMarkdown(String[] text) {
    setStyle(MD_PARA_STYLE);
    for (String line : text) {
      line = line.trim();
      if (line.startsWith("#")) {
        // Render header
        setStyle(MD_H1_STYLE);
        renderText(line.substring(1), false); // Skip first char
        moveDownBy((int)(0.5*curStyle.size));
        setStyle(MD_PARA_STYLE);
      } else if (line.startsWith("![](")) {
        // Render image
        renderMdImage(line);
      } else if (line.startsWith("vvv")) {
        // Remaining text is in footer. Jump to
        // footer area.
        setStyle(MD_FOOTER_STYLE);
        curDY = (int) (origin.y + hRegion - 2*curStyle.size);
      } else {
        renderText(line, true);
      }
    }
  }


  private void renderMdImage(String text) {
    // We expect text to be of the form: ![](file).
    String fname = text.replaceAll(".*[(]", "");
    fname = fname.replaceAll("\\)(.*)","");
    println("Img name: " + fname);
    PImage img = loadImage(fname);
    image(img, origin.x, curDY);
  }

  // Insert newlines to prevent text from
  // exceeding the right boundary. Uses the *current*
  // font size. Does not hyphenate.
  private String insertLinebreaks(String input) {
    ArrayList<Integer>inserts = new ArrayList<Integer>();
    final float MARGIN = textWidth('H');
    // Find places where we must insert newlines...
    int curLineStart = 0;
    for (int i=0; i< input.length(); i++) {
      if (input.charAt(i) == '\n') {
        curLineStart = i+1;
      } else {
        // Recalculate with.
        String lineSoFar = input.substring(curLineStart, i+1);
        float curWidth = textWidth(lineSoFar);
        if ((curWidth+MARGIN) >= wRegion) {
          // Need to linebreak! We will go back to to the previous
          // word break. Break should happen AFTER the index.
          int br = lineBreakPoint(lineSoFar);
          if (br>0) {
            curLineStart  += br + 1;
          } else {
            // Hmm, we couldn't break the line. We'll do a
            // FORCE break.
            curLineStart = i;
          }
          assert(curLineStart<input.length());
          inserts.add(curLineStart);
        }
      }
    }
    return insertNewlines(input, inserts);
  }

  // Return a string that has newlines inserted at the insert points.
  String insertNewlines(String input, ArrayList<Integer> inserts) {
    if (inserts.size()==0) {
      return input; // *** EARLY RETURN ***
    }

    StringBuilder sb = new StringBuilder();
    int prevOffset = 0;
    for (Integer offset : inserts) {
      int end = offset;
      if (input.charAt(offset) == ' ') {
        end--; // Trim final space if there is one.
        // There will be one if the space broke the line.
      }
      sb.append(input.substring(prevOffset, end));
      sb.append('\n');
      prevOffset = offset;
    }
    sb.append(input.substring(prevOffset)); // last bit.
    return sb.toString();
  }

  // Find the last place we can break the line.
  // Break on spaces and hyphens. Note that other punctuation
  // are expected to have spaces after them.
  // Line should be broken AFTER the char.
  int lineBreakPoint(String line) {
    if (line.length()==0) {
      return 0;
    }
    // Start at end, go backwards...
    for (int i = line.length()-1; i>=0; i--) {
      char c = line.charAt(i);
      if (c == ' ' || c == '-') {
        return i;
      }
    }
    return 0;
  }

  // Skip dy pixels and continue
  // Return new absolute y value.
  // use moveDownBy(0) to get current absolute value.
  public int moveDownBy(int dy) {
    curDY += dy;
    return (int) (origin.y+curDY);
  }

  // Repositon y position to new absolute value
  // Return new absolute y value.
  // use moveDownBy(0) to get current absolute value.
  public int moveDownTo(int y) {
    origin.y = y;
    curDY = 0;
    return y;
  }


  // Run internal tests
  void runTests() {
  }
}