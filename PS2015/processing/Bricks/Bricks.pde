// 
// Braille Lego bricks - emits OpenSCAD method call to display a particular braille message.
//

import java.util.*;

Hashtable brailleMap = null;

void setup() {
  noLoop();  
  String s = "yrtb zbivr jvmneq";
  //System.out.println(removeDups(s));
  System.out.println("color([0.75, 0.75, 0.75]) {");
  for (int i=0; i<s.length (); i++) {
    System.out.println("    translate(["+i*30+", 0, 0]) " + genBrick(s.charAt(i)));
  }
  System.out.println("}");
}

String uniqueChars(String s) {
  String ret = "";
  for (int i=0;i<s.length();i++) {
    String c = s.substring(i,i+1);
    if (s.indexOf(c) == s.lastIndexOf(c)) {
      ret += c;
    }
  }
  return ret;
}

String removeDups(String s) {
  String ret = "";
  for (int i=0;i<s.length();i++) {
    String c = s.substring(i,i+1);
    if (s.indexOf(c) == i) {
      ret += c;
    }
  }
  return ret;
}

String genBrick(char c) {

  return genBrick(braille(c), c);
}

void printCards(ArrayList<int[][]> cards) {
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

void draw() {
  drawClock(
}
