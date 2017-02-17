// Module: PuzzleDocs  - program entrypoint
// History:
//  Feb 2017  - JMJ created.

public static final boolean GENERATE_PDF = true;

void settings() {
  if (GENERATE_PDF) {
    size(800, 1024, PDF, "output/puzzles.pdf");
  } else {
    size(800, 1024);
  }
}

void setup() {
  //size(800, 1024, PDF, "output/out.pdf");
  //size(800, 1024);
  //runAllTests();
  generateAllPuzzles();
}

void generateAllPuzzles() {
  final String[] PUZZLE_TYPES = {
    "clocks", 
    "lasers",
    "countCells",
    "bricks"
  };
  String[][] templates = loadMdTemplates(PUZZLE_TYPES);
  String[][] INValues = loadINValues(PUZZLE_TYPES);
  PGraphicsPDF pdf  = null;
  if (GENERATE_PDF) {
    pdf = (PGraphicsPDF) g;  // Get the renderer - seem's it's called "g" !?
  }

  // Render one random puzzle per type.
  for (int i = 0; i< PUZZLE_TYPES.length; i++) {
    if (pdf!=null && i>0) {
      pdf.nextPage();
    }
    String[] mdTemp = templates[i];
    String[] INVals = INValues[i];
    int selected = (int) (Math.random()*INVals.length);
    String INVal = INVals[selected];
    String PNVal = "" + (i+1) + INVal;
    String IRVal = ""; // Suppress Roman numerals in title.
    renderOnePuzzle(templates[i], PNVal, INVal, IRVal);
  }
  exit();
  println("***PDF GENERATION COMPLETE***");
}

void runAllTests() {
  String s = "blah{{IN}}blah";
  String t = s.replaceAll("\\{\\{IN}}", "01");
  println("s: " + s + ", t: " + t);
  //runMarkdownTests();
}

void runMarkdownTests() {
  String[] mdText = {
    "#<<502: Relojes IV", 
    "![](data/lasers/lasers-41.png)", 
    "<<Estos relojes esconden un mensaje. El mensaje es una" +
    " frase corta que lo dirige a usted a calcular un número." +
    " El número es la solución de este rompecabezas. Pista: " +
    " utilice la gráfica del semáforo.", 
    "vvv", 
    ">>©2015 Joseph Joy (Rinworks, LLC)"
  };
  int hMargin = 50;
  int vMargin = 50;
  int w = width-2*hMargin;
  int h = height-2*vMargin;
  TextRenderer r = new TextRenderer(new Point(hMargin, vMargin), w, h);
  r.runTests();
  background(255);
  r.renderMarkdown(mdText);
}

// Renders one puzzle.
// mdTemplate - Markdown text with optioanl {{x}} variables
// PNVal - value to replace {{PN}} (puzzle number)
// INVal - value to replace {{IN}} (solution instance number}}
// RNVal - value to replce {{IR}} (solution instance in roman numerals)
void renderOnePuzzle(String[]mdTemplate, String PNVal, String INVal, String IRVal) {
  final int hMargin = 50;
  final int vMargin = 50;

  String[] mdText = new String[mdTemplate.length];
  // Replace template variables.
  for (int i=0; i<mdText.length; i++) {
    String s;
    s = mdTemplate[i].replaceAll("\\{\\{PN\\}\\}", PNVal);
    s = s.replaceAll("\\{\\{IN}}", INVal);
    s = s.replaceAll("\\{\\{IR\\}\\}", IRVal);
    mdText[i] = s;
  }
  int w = width-2*hMargin;
  int h = height-2*vMargin;
  TextRenderer r = new TextRenderer(new Point(hMargin, vMargin), w, h);
  background(255);
  r.renderMarkdown(mdText);
}

// Loads the templates associated with an array of puzzle types.
// return - array of templates.
// Template files are expected to be of the form
// data/<type>.md, for example: data/bricks.md
String[][] loadMdTemplates(String[] puzzleTypes) {
  String[][] templates  = new String[puzzleTypes.length][];
  for (int i = 0; i < templates.length; i++) {
    String fName = "data/" + puzzleTypes[i] + ".md";
    templates[i] = loadStrings(fName);
  }
  return templates;
}

// Loads the list of available solution instance IDs assocaited
// an array of puzzle types
// return - array of (array of instanceIDs).
// Each (array instanceIDs) corresponds to one puzzle type.
// THe IN values for type <type> is expected to be in a CSV file
// data/<type>/<type>-info.csv, in the "IN" column.
// Example: data/lasers/lasers-info.csv:
String[][] loadINValues(String[] puzzleTypes) {
  String[][] INValues = new String[puzzleTypes.length][];
  for (int i = 0; i < INValues.length; i++) {
    String pType = puzzleTypes[i];
    String fName = "data/" + pType + "/" + pType + "-info.csv";
    Table tab = loadTable(fName, "header");
    int count = tab.getRowCount();
    String[]  INVals = new String[count];
    int j = 0;
    for (TableRow row : tab.rows()) {
      String INVal = row.getString("IN");
      INVals[j] = INVal;
      j++;
    }
    INValues[i] = INVals;
  }
  return INValues;
}