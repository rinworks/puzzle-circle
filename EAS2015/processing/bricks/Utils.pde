import java.util.Random; //<>//

Hashtable brailleMap = null;

enum MyColor {
  RED, GREEN, BLUE, YELLOW
};

  // Partitions chars in puzzleString into numPartition ordered partions,
// which it returns as an array of strings.
int[] randomPartition1(Random rand, String puzzleString, String[] partitions ) {
  //randomSeed(seed);
  int numPartitions = partitions.length;
  for (int i=0; i<partitions.length; i++) {
    partitions[i] = "";
  }
  int charCount = puzzleString.length();
  int[] ordering = new int[charCount];

  // Allocate the total count of characters among
  // the partitions. Note that the number of characters
  // may be greater/less than/equal to the number of
  // characters.
  ArrayList<Integer>counts = new ArrayList<Integer>(numPartitions);
  ArrayList<Integer>partitionIds = new ArrayList<Integer>(numPartitions);
  int factor = charCount/numPartitions; // could be 0;
  int remainder  = charCount % numPartitions;
  //println("factor:" + factor + " remainder: " + remainder);
  if (factor>0) {
    for (int i=0; i<numPartitions; i++) {
      counts.add(factor);
      partitionIds.add(i);
    }
    for (int i=0; i<remainder; i++) {
      counts.set(i, counts.get(i)+1);
    }
  } else {
    for (int i=0; i<remainder; i++) {
      counts.add(1);
      partitionIds.add(i);
    }
  }

  // Create random ordering by picking one of
  // the partitions at random to "host" each
  // successive puzzle string character. Once
  // a partition has exceeded it's allotted amount
  // of characters it is removed from the running...
  for (int i=0; i<ordering.length; i++) {
    assert(counts.size()>0);
    int k = rand.nextInt(counts.size());
    assert(k<numPartitions);
    int id = partitionIds.get(k);
    ordering[i]=id;
    partitions[id] += puzzleString.substring(i, i+1);
    int countK = counts.get(k);
    if (countK>1) {
      counts.set(k, countK-1);
    } else {
      assert(countK==1);
      counts.remove(k);
      partitionIds.remove(k);
    }
  }
  assert(counts.size()==0);

  // Finally, let's verify that we did partition things properly!
  // If there is a mismatch we throw an exception!
  {
    String testString = "";
    int[] partitionOffsets = new int[partitions.length];// initialized to zeros

    for (int i=0; i<ordering.length; i++) {
      int id = ordering[i];
      int offset = partitionOffsets[id];
      assert(offset<partitions[id].length());
      testString += partitions[id].substring(offset, offset+1);
      partitionOffsets[id]++;
    }
    if (!testString.equals(puzzleString)) {
      throw new RuntimeException("Fatal internal error!");
    }
  }
  return ordering;
}

// Partitions chars in puzzleString into numPartition ordered partions,
// which it returns as an array of strings.
// This version does NOT attempt to keep the lengths of individual partitions 
// as close to equal as possible.
int[] randomPartition2(int seed, String puzzleString, String[] partitions ) {
  randomSeed(seed);
  int numPartitions = partitions.length;
  ArrayList<Integer>ordering = new ArrayList<Integer>();

  for (int i=0; i<partitions.length; i++) {
    partitions[i] = "";
  }
  if (numPartitions>=0) {

    for (int i=0; i<puzzleString.length(); i++) {
      int v = (int) random(0, numPartitions);
      if (v==numPartitions) { // this can happen, rarely...
        v=0;
      }
      ordering.add(v);
      partitions[v] += puzzleString.substring(i, i+1);
    }
  }
  int[] ret = new int[puzzleString.length()];
  int j=0;
  for (int v : ordering) {
    ret[j] = v;
    j++;
  }
  return ret;
}


// Generates OpenSCAD code for a Braille brick that 
// represents each of the letters. One string per brick.
String[] genBricks(String text) {
  int len = text.length();
  text = text.toUpperCase();
  String[] bricks = new String[len];
  for (int i=0; i<len; i++) {
    char c = text.charAt(i);
    bricks[i] = genBrick(c);
  }
  return bricks;
}


// Given an array of rows of blocks,
// lays them out, one below the other.
String[] layoutBlockRows(String[][]rows, int dY, String[] text) {
  ArrayList<String> code = new ArrayList<String>();
  for (int i=0; i<rows.length; i++) {
    //code.add("V_TRANSLATE("+i + "){ // Chars: " + text[i]);
    code.add(emitTranslate(0, i*dY, 0) + " { // Chars: " + text[i]);
    for (String s : rows[i]) {
      code.add("  " + s);
    }
    code.add("}");
  }
  String[] ret = new String[code.size()];
  code.toArray(ret);
  return ret;
}

// Generates OpenSCAD code that color the specified bricks (which are themselves openScad snippets)
// and lay them out in a row, slightly jiggling each one.
String[] wigglyColoredRow(String text, MyColor c, int dX) {
  int charCount = text.length();
  String[] bricks = genBricks(text);
  assert(charCount == bricks.length);
  String[] res = new String[charCount+2];// +2 for initial and final code
  String sColor = "";
  println("COLOR: " + c);
  switch(c) {
  case RED: 
    sColor = "[1.00, 0.25, 0.25]";
    break;
  case GREEN: 
    sColor = "[0.25, 1.00, 0.25]";
    break;
  case BLUE: 
    sColor = "[0.25, 0.25, 1.00]";
    break;
  case YELLOW: 
    sColor = "[1.00, 1.00, 0.00]";
    break;
  default:
    assert(false);
    break;
  }
  res[0] = "color("+sColor+") { // Color " + c.toString();
  float jiggle = 1/30.0;
  for (int i=0; i<charCount; i++) {
    float rZ = random(-5.0, 5.0);
    float ddX = random(-dX*jiggle, dX*jiggle);
    float ddY = random(-dX*jiggle, dX*jiggle);
    res[i+1] = "    " + emitTranslate(i*dX+ddX, ddY, 0) + " " + emitRotate(0, 0, rZ) + " " +  bricks[i] + "; // " + text.substring(i, i+1);
    //res[i] = "WIGGLE("+i+",H_TRANSLATE("+i+", COLOR("+sColor+","+bricks[i]+")))";
  }
  res[res.length-1] = "}";
  return res;
}

String emitTranslate(float dX, float dY, float dZ) {
  return "translate(["+dX+","+dY+","+dZ+"])";
}

String emitRotate(float rX, float rY, float rZ) {
  return "rotate(["+rX+","+rY+","+rZ+"])";
}


// Writes the code, presumed to be 
// Output is written to <sketchdir>\output\<name>.scad,
// potentially overwriting an existing file.
// It prepends init code
void writeOpenScadFile(String[] code, String name) {
  String[] output = addPreamble(code);
  String pathName = sketchPath() + "\\output\\" + name + ".scad";
  saveStrings(pathName, output);
}

String[] addPreamble(String[] code) {
  String[] preamble = {
    "include<bricks.scad>;"
  };
  String[] ret = new String[preamble.length+code.length];
  int i=0;
  for (String s : preamble) {
    ret[i++] = s;
  }

  for (String s : code) {
    ret[i++] = s;
  }
  return ret;
}
String genBrick(char c) {
  //return "BRICK(\""+c+")";
  return genBrick(braille(c), c);
}


String genBrick(int[] arr, char c) {
  if (arr==null) {
    int[] arr1 = {0, 0, 0, 0, 0, 0};
    arr = arr1;
  }

  String s = "brick([";
  for (int i=0; i<arr.length; i++) {
    s+=arr[i];
    if (i<arr.length-1) {
      s+=",";
    }
  }
  s+="])";
  return s;
}

int[] braille(char c) {

  if (brailleMap==null) {
    brailleMap = genBrailleMap();
  }
  /*int[] arr = {
   1, 1, 1, 1, 1, 1
   };*/

  return (int[]) brailleMap.get(c);
}

Hashtable genBrailleMap() {

  int [][] alphaPatterns  = {
    {
      1, 0, 0, 0, 0, 0 // A
    }, 
    {
      1, 1, 0, 0, 0, 0 // B
    }, 
    {
      1, 0, 0, 1, 0, 0 // C
    }, 
    {
      1, 0, 0, 1, 1, 0 // D
    }, 
    {
      1, 0, 0, 0, 1, 0 // E
    }, 
    {
      1, 1, 0, 1, 0, 0 // F
    }, 
    {
      1, 1, 0, 1, 1, 0 // G
    }, 
    {
      1, 1, 0, 0, 1, 0 // H
    }, 
    {
      0, 1, 0, 1, 0, 0 // I
    }, 
    {
      0, 1, 0, 1, 1, 0 // J
    }, 
    {
      1, 0, 1, 0, 0, 0 // K
    }, 
    {
      1, 1, 1, 0, 0, 0 // L
    }, 
    {
      1, 0, 1, 1, 0, 0 // M
    }, 
    {
      1, 0, 1, 1, 1, 0 // N
    }, 
    {
      1, 0, 1, 0, 1, 0 // O
    }, 
    {
      1, 1, 1, 1, 0, 0 // P
    }, 
    {
      1, 1, 1, 1, 1, 0 // Q
    }, 
    {
      1, 1, 1, 0, 1, 0 // R
    }, 
    {
      0, 1, 1, 1, 0, 0 // S
    }, 
    {
      0, 1, 1, 1, 1, 0 // T
    }, 
    {
      1, 0, 1, 0, 0, 1 // U
    }, 
    {
      1, 1, 1, 0, 0, 1 // V
    }, 
    {
      0, 1, 0, 1, 1, 1 // W
    }, 
    {
      1, 0, 1, 1, 0, 1 // X
    }, 
    {
      1, 0, 1, 1, 1, 1 // Y
    }, 
    {
      1, 0, 1, 0, 1, 1 // Z
    }

  };

  Hashtable ht =  new Hashtable();
  assert(alphaPatterns.length==26); // better be exactly # alphabets!
  for (int i=0; i<alphaPatterns.length; i++) {
    char k = (char) ('A'+i);
    ht.put(k, alphaPatterns[i]);
  }
  return ht;
}


void renderHintPanel(int[] order, MyColor[] colors, int[] blankPositions, String panelName) {
  int cW = 20; // width of letter cell
  int cH = 30; // height of letter cell
  int gap = 5;
  int imgW = (order.length+blankPositions.length)*(cW + gap) + gap;
  int imgH = 2*gap + cH;
  PGraphics pg = createGraphics(imgW, imgH);
  pg.beginDraw();
  pg.background(255);

  int blankIndex = 0;
  int baseIntensity = 175; // to generate pastel colors.
  int y = gap;
  int x = gap;
  pg.rectMode(CORNER);
  for (int i=0; i<order.length; i++) {
    // Render current cell
    int partition = order[i];

    if (blankIndex<blankPositions.length) {
      int nextBlank = blankPositions[blankIndex];
      if (i==nextBlank) {
        // Add a blank.
        x += (cW+gap);
        blankIndex++;
      }
    }
    int c = mapColor(colors[partition], baseIntensity);
    pg.fill(c);
    pg.noStroke();
    pg.rect(x, y, cW, cH);
    pg.strokeWeight(2);
    pg.stroke(0);
    pg.line(x, y+cH, x+cW, y+cH);
    x += cW+gap;
  }

  pg.endDraw();
  pg.save(sketchPath() + "\\output\\"  + panelName + ".png");
  image(pg, 10, 10);
}

int mapColor(MyColor c, int base) {
  int ret=0;
  switch(c) {
  case RED: 
    ret = color(255, base, base);
    break;
  case GREEN: 
    ret = color(base, 255, base);
    break;
  case BLUE: 
    ret = color(base, base, 255);
    break;
  case YELLOW: 
    ret = color(255, 255, base/4); // we ignore base as yellow is pretty pale
    break;
  default:
    assert(false);
    break;
  }
  return ret;
}

// Return an array containing the offsets to where to *insert* all
// blanks in the string, were the blanks removed.
int[] findBlankPositions(String text) {

  int nBlanks= text.length() - text.replace(" ", "").length(); // from stackOverflow
  int positions[] = new int[nBlanks];
  int pos=-1;
  for (int i=0; i < positions.length; i++) {
    pos = text.indexOf(' ', pos+1); // ok to call indexOf(-1,string);
    positions[i] = pos-i; // subtract the number of blanks we've seen before.
    assert( positions[i]>=0);
  }
  return positions;
}