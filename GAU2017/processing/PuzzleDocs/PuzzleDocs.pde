// Module: PuzzleDocs  - program entrypoint
// History:
//  Feb 2017  - JMJ created.

public static final boolean GENERATE_PDF = true;
public static final String DOC_ID = "10";
public static final String LANG_VER = "EN";

void settings() {
  if (GENERATE_PDF) {
    size(800, 1024, PDF, "output/" + LANG_VER + "/puzzleStack" + DOC_ID + ".pdf");
  } else {
    size(800, 1024);
  }
}

void setup() {
  //size(800, 1024, PDF, "output/out.pdf");
  //size(800, 1024);
  //runAllTests();
  generateAllPuzzles();
  //String[] puzzleIDs = {"101", "202", "303", "404"};
  //renderScoringSheet(puzzleIDs);
}

void renderScoringSheet(String[] puzzleIDs) {
  TextTableHelper tth = new TextTableHelper();
  tth.renderGAUScoreSheet(puzzleIDs);
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

  // Generate multiple Puzzle Packets!
  final int PUZZLES_PER_DOC = 10;
  for (int pkt = 0; pkt < PUZZLES_PER_DOC; pkt++) {
    String packetID = ((pkt % 9) + 1) + ""; // Cycles through 1...9

    // Select the IN values for each puzzle type, more or less at random. We DO have to be sure not to repeat
    // IN values so we don't get the same solution to
    // multiple puzzles!
    String[] selectedINVals = selectRandomPuzzles(INValues, PUZZLE_TYPES);//  new String[PUZZLE_TYPES.length];

    // Render scoring sheet;
    String[] puzzleIDs = generatePuzzleIDs(packetID, selectedINVals);
    renderScoringSheet(puzzleIDs);

    for (int i = 0; i< PUZZLE_TYPES.length; i++) {
      if (pdf!=null) {
        pdf.nextPage();
      }
      String INVal = selectedINVals[i];
      assert(INVal!=null);
      String PNVal = puzzleIDs[i];
      String IRVal = ""; // Suppress Roman numerals in title.
      renderOnePuzzle(templates[i], PNVal, INVal, IRVal);
    }
    if ((pkt+1) < PUZZLES_PER_DOC) {
      // More puzzles to go...
      if (pdf!=null) {
        pdf.nextPage();
      }
    }
  }
  exit();
  println("***PDF GENERATION COMPLETE***");
}


// Generate 3-digit puzzle IDs from the Instance IDs
String[] generatePuzzleIDs(String pre, String[] selectedINVals) {
  String[] puzzleIDs = new String[selectedINVals.length];
  for (int i=0; i<puzzleIDs.length; i++) {
    puzzleIDs[i] = pre + selectedINVals[i];
  }
  return puzzleIDs;
}

// Return IN vals of selected puzzles
String[] selectRandomPuzzles(String[][] AllINValues, String[] puzzleTypes) {
  String[] selectedValues = new String[puzzleTypes.length] ;
  for (int i = 0; i< puzzleTypes.length; i++) {
    String[] INVals = AllINValues[i];
    boolean foundOne = false;
    // Select an IN val at random, but check that we haven't 
    // already selected it.
    String INVal = null;
    do {
      int selected = (int) (Math.random()*INVals.length);
      INVal = INVals[selected];
      foundOne = true;
      for (int k = 0; k < i; k++) {
        if (selectedValues[k].equals(INVal)) {
          foundOne = false; // Ugh, already got this one
          break;
        }
      }
    } while (!foundOne);
    assert(INVal!=null);
    selectedValues[i]=INVal;
  }
  return selectedValues;
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
    String fName = "data/" + LANG_VER + "/" + puzzleTypes[i] + ".md";
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
    String fName = "data/" + LANG_VER + "/" + pType + "/" + pType + "-info.csv";
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