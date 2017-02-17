// Module: BrickMain - code to generate  media needed for the Brick Puzzle
// History:
//  Feb 2017  - JMJ created, adapted from earlier code I wrote for EAS and Puzzle Safari puzzles
// 
// Braille Lego bricks - emits OpenSCAD method call to display a particular braille message.
//
final String SPECIAL_CHAR_PATTERN  ="[^A-Z]"; // Chars that do NOT map to Braille


//import java.util.*;
class BricksMain {

  final String PUZZLE_TYPE = "bricks";
  final String[] puzzleTexts = {
    "CUARTO PLANETA", 
    "QUINTO PLANETA", 
    "AGUA CONGELADA", 
    "# RUEDAS EN UN COCHE", 
    "# RUEDAS EN UNA BICICLETA", 
    "1KG EN GRAMOS",
    "SIETE PIES EN PULGADAS", 
    "CINCO PIES EN PULGADAS", 
    "SEIS PIES EN PULGADAS", 
  };


  void genAllMedia() {

    Table infoTable = gUtils.newInfoTable();

    // Write out the bricks.scad file. This is common code used by all the bricks files.
    writeBricksSCADFile("output/" + PUZZLE_TYPE + "/");
    //size(1000, 100);
    //noLoop();  
    long seed = 0; //(long) random(100000);
    println("SEED: " + seed);
    Random rand = new Random(seed);

    for (String puzzleText : puzzleTexts) {
      String IN  = gSolutions.lookupIN(puzzleText);
      String fileStub = gUtils.genMediaFilenameStub(PUZZLE_TYPE, IN);
      String supportedText = puzzleText.replaceAll(SPECIAL_CHAR_PATTERN, "");
      MyColor[] colors = {MyColor.RED, MyColor.GREEN, MyColor.YELLOW }; // BLUE tends to be too dark, plus the pastel version looks too much like green
      int[] order = makePuzzle(rand, supportedText, colors, fileStub + "a");
      //println(order);
      renderHintPanel(order, colors, puzzleText, false, fileStub + "b");
      renderHintPanel(order, colors, puzzleText, true, fileStub + "-answer");
      gUtils.addInstanceToTable(infoTable, IN, puzzleText);
    }
    gUtils.saveInfoTable(infoTable, PUZZLE_TYPE);
  }



  int[] makePuzzle(Random rand, String puzzleText, MyColor[] colors, String puzzleName) {
    String[] partitions = new String[colors.length];
    int[] order = randomPartition1(rand, puzzleText, partitions);

    for (int i=0; i<partitions.length; i++) {
      println("row["+i+"]="+partitions[i]);
    }
    println("Order:");
    println(order);
    int DX = 20; // how much to translate each brick.
    int DY = 50;
    String[][] rows = new String[colors.length][];
    for (int i=0; i<colors.length; i++) {
      rows[i] = wigglyColoredRow(partitions[i], colors[i], DX);
    }
    String[] code = layoutBrickRows(rows, DY, partitions);
    writeOpenScadFile(code, puzzleName);
    return order;
  }
}