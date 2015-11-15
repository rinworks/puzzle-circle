void setup() {
  int[][] guildPuzzles = {
    {0}
  };
  int[] oldIds = {860, 288, 683, 199, 138, 343, 456, 565, 381, 613, 705, 403, 788  };
  int[] puzzleIds = generateRandomIds(0, oldIds, 60);
   for (int i=0; i<puzzleIds.length; i++) {
    //println("["+(i+1)+"] "+puzzleIds[i]);
  }
  
  String[] oldTickets = {"AAA","BBB","CCC"};
  String[] puzzleTickets = generateRandomTickets(round(random(10000)), oldTickets, 10000);
   for (int i=0; i<puzzleTickets.length; i++) {
   // print("["+(i+1)+"] "+puzzleTickets[i]);
    if (i%10==9) {
      //println();
    }
  }
}

int[] generateRandomIds(int seed, int[] oldValues, int N) {
  int[] values = new int[N];

  for (int i=0; i<oldValues.length; i++) {
     values[i] = oldValues[i];
  }
  int start = oldValues.length;
  randomSeed(seed);
  for (int i=start; i<N; i++) {
    int j;
    Boolean unique;
    do {
      unique=true;
      j = floor(random(100, 900));
      if (j==666) {
        continue; // avoid this number :-)
      }
      for (int k=0; k<i; k++) {
        if (j==values[k]) {
          unique=false;
          println("dupe " + j);
          break;
        }
      }
    } while (!unique);    
    values[i]=j;
  }
  return values;
}

String randomLetters(int n) {
  String ret = "";
  for (int i=0;i<n;i++) {
    ret += (char) ('A'+floor(random(0, 26))%26);
  }
  return ret;
}

// Generate N tickets, including the supplied oldValues.
// Tickets are 3-letter unique strings.
String[] generateRandomTickets(int seed, String[] oldValues, int N) {
  String[] values = new String[N];
//  string LETTERS = "ABCDEFGHIJKL

  for (int i=0; i<oldValues.length; i++) {
     values[i] = oldValues[i];
  }
  int start = oldValues.length;
  randomSeed(seed);
  for (int i=start; i<N; i++) {
    String j;
    Boolean unique;
    do {
      unique=true;
      j = randomLetters(3);
      if (badWord(j)) {
        println("bad " + j);
        continue; // avoid this number :-)
      }
      for (int k=0; k<i; k++) {
        if (j.equals(values[k])) {
          unique=false;
          //println("dupe " + j);
          break;
        }
      }
    } while (!unique);    
    values[i]=j;
  }
  return values;
}

boolean badWord(String s) {
  String[] badWords = {
    "SEX", "TIT", "GUN", "BUM", "CUM", "FAG", "ASS", "DIE", "KOK", "DIK", "SUK", "BUT", "PEE", "FUK","POO", "PIS", "KKK"
  };
  for (String bw : badWords) {
    if (s.equals(bw)) {
      return true;
    }
  }
  return false;
}