// 
// Braille Lego bricks - emits OpenSCAD method call to display a particular braille message.
//

import java.util.*;


void setup() {
  noLoop();  
  
   String[] p = new String[3];
   long seed = (long) random(100000);
   Random rand = new Random(seed);
   println("Seed:"+seed);
   int[] order = randomPartition1(rand, "BOWMANBAY", p);
   for (int i=0;i<p.length;i++) {
     println("p["+i+"]="+p[i]);
   }
   println("Order:");
   println(order);
  //int[] order = makePuzzle(0, "ABC", "bricks");
  //println(order);
    
}



int[] makePuzzle(Random rand, String puzzleText, String puzzleName) {
  String[] partitions = new String[3];
  int[] order = randomPartition1(rand, puzzleText, partitions);
  String[] redBricks = wigglyColoredRow(genBricks(partitions[0]), MyColor.RED);
  String[] blueBricks = wigglyColoredRow(genBricks(partitions[0]), MyColor.BLUE);
  String[] greenBricks = wigglyColoredRow(genBricks(partitions[0]), MyColor.GREEN);
  String[][] rows = {redBricks, blueBricks, greenBricks};
  String[] code = layoutBlockRows(rows);
  writeOpenScadFile(code, puzzleName);
  return order;
}