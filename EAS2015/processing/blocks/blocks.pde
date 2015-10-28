// 
// Braille Lego bricks - emits OpenSCAD method call to display a particular braille message.
//

import java.util.*;


void setup() {
  noLoop();  
     long seed = 0; //(long) random(100000);
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
  int[] order = makePuzzle(rand, "ABC", "bricks");
  println(order);
    
}



int[] makePuzzle(Random rand, String puzzleText, String puzzleName) {
  String[] partitions = new String[3];
  int[] order = randomPartition1(rand, puzzleText, partitions);
  String[] redBricks = wigglyColoredRow(genBricks(partitions[0]), MyColor.RED);
  String[] blueBricks = wigglyColoredRow(genBricks(partitions[1]), MyColor.BLUE);
  String[] greenBricks = wigglyColoredRow(genBricks(partitions[2]), MyColor.GREEN);
  String[][] rows = {redBricks, blueBricks, greenBricks};
  String[] code = layoutBlockRows(rows);
  writeOpenScadFile(code, puzzleName);
  return order;
}