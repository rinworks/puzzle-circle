// 
// Braille Lego bricks - emits OpenSCAD method call to display a particular braille message.
//

import java.util.*;

String SPECIAL_CHAR_PATTERN  ="[^A-Z]"; // Chars that do NOT map to Braille


void setup() {
  size(1000,100);
  noLoop();  
  long seed = (long) random(100000);
  println("SEED: " + seed);
  Random rand = new Random(seed);
  /* Testing randomPartition
   String[] p = new String[3];
   
   println("Seed:"+seed);
   int[] order = randomPartition1(rand, "", p);
   for (int i=0;i<p.length;i++) {
   println("p["+i+"]="+p[i]);
   }
   println("Order:");
   println(order);
   */
  String puzzleName = "bricksPuzzle";
  String puzzleText = "DECLARATION OF INDEPENDENCE AUTHOR";
  String supportedText = puzzleText.replaceAll(SPECIAL_CHAR_PATTERN, "");
  MyColor[] colors = {MyColor.RED, MyColor.GREEN, MyColor.YELLOW }; // BLUE tends to be too dark, plus the pastel version looks too much like green
  int[] order = makePuzzle(rand, supportedText, colors, puzzleName);
  //println(order);

  
  renderHintPanel(order, colors, puzzleText, true, puzzleName + "HintPanel");
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