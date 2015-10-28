// 
// Braille Lego bricks - emits OpenSCAD method call to display a particular braille message.
//

import java.util.*;


void setup() {
  noLoop();  
  long seed = (long) random(100000);
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
  int[] order = makePuzzle(rand, "BOWMANBAY", "bricksPuzzle");
  //println(order);
}



int[] makePuzzle(Random rand, String puzzleText, String puzzleName) {
  String[] partitions = new String[3];
  int[] order = randomPartition1(rand, puzzleText, partitions);
  
  for (int i=0; i<partitions.length; i++) {
    println("row["+i+"]="+partitions[i]);
  }
  println("Order:");
  println(order);
  int DX = 30; // how much to translate each block.
  int DY = 50;
  String[] redBricks = wigglyColoredRow(partitions[0], MyColor.RED, DX);
  String[] blueBricks = wigglyColoredRow(partitions[1], MyColor.BLUE, DX);
  String[] greenBricks = wigglyColoredRow(partitions[2], MyColor.GREEN, DX);
  String[][] rows = {redBricks, blueBricks, greenBricks};
  String[] code = layoutBlockRows(rows, DY, partitions);
  writeOpenScadFile(code, puzzleName);
  return order;
}