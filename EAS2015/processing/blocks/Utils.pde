import java.util.Random;

Hashtable brailleMap = null;

enum MyColor {
  RED, GREEN, BLUE
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
  println("factor:" + factor + " remainder: " + remainder);
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
    partitions[id] += puzzleString.substring(i,i+1);
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

    for (int i=0;i<ordering.length;i++) {
      int id = ordering[i];
      int offset = partitionOffsets[id];
      assert(offset<partitions[id].length());
      testString += partitions[id].substring(offset, offset+1);
      partitionOffsets[id]++;
    }
    testString = "foo";
    if (!testString.equals(puzzleString)) {
      throw new RuntimeException("Fatal internal error!");
    } else {
      println("CORRECT! Regenerated string:["+testString+"]");
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
  String[] bricks = new String[len];
  for (int i=0; i<len; i++) {
    char c = text.charAt(i);
    bricks[i] = genBrick(c);
  }
  return bricks;
}


// Given an array of rows of blocks,
// lays them out, one below the other.
String[] layoutBlockRows(String[][]rows) {
  ArrayList<String> code = new ArrayList<String>();
  for (int i=0; i<rows.length; i++) {
    code.add("V_TRANSLATE("+i + "){");
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
String[] wigglyColoredRow(String[] bricks, MyColor c) {
  String[] res = new String[bricks.length];
  String sColor = "";
  switch(c) {
  case RED: 
    sColor = "RED";
    break;
  case BLUE: 
    sColor = "BLUE";
    break;
  case GREEN: 
    sColor = "GREEN";
    break;
  default:
    assert(false);
    break;
  }
  for (int i=0; i<res.length; i++) {
    res[i] = "WIGGLE("+i+",H_TRANSLATE("+i+", COLOR("+sColor+","+bricks[i]+")))";
  }
  return res;
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
  return "BRICK(\""+c+")";
  //return genBrick(braille(c), c);
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
  s+="]); // "+c;
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
  // yrtb zivjmneq
  // beijmnqrtvyz
  int [][] patterns  = {
    {
      1, 1, 0, 0, 0, 0 // b
    }
    , 
    {
      1, 0, 0, 0, 1, 0 // e
    }
    , 
    {
      0, 1, 0, 1, 0, 0 // i
    }
    , 
    {
      0, 1, 0, 1, 1, 0 // j
    }
    , 
    {
      1, 0, 1, 1, 0, 0 // m
    }
    , 
    {
      1, 0, 1, 1, 1, 0 // n
    }
    , 
    {
      1, 1, 1, 1, 1, 0 // q
    }
    , 
    {
      1, 1, 1, 0, 1, 0 // r
    }
    , 
    {
      0, 1, 1, 1, 1, 0 // t
    }
    , 
    {
      1, 1, 1, 0, 0, 1 // v
    }
    , 
    {
      1, 0, 1, 1, 1, 1 // y
    }
    , 
    {
      1, 0, 1, 0, 1, 1 // z
    }

  };
  char[] keys = {
    'b', 'e', 'i', 'j', 'm', 'n', 'q', 'r', 't', 'v', 'y', 'z'//beijmnqrtvyz
  };
  Hashtable ht =  new Hashtable();
  for (int i=0; i<keys.length; i++) {
    ht.put(keys[i], patterns[i]);
  }
  return ht;
}