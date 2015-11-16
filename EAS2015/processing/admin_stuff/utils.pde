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
  for (int i=0; i<n; i++) {
    ret += (char) ('A'+floor(random(0, 26))%26);
  }
  return ret;
}

// Generate N tickets, including the supplied oldValues.
// Tickets are 3-letter unique strings.
String[] generateRandomTickets(int seed, String[] oldValues, int N) {
  String[] values = new String[N];
  //  string LETTERS = "ABCDEFGHIJKL
  println("SEED: " + seed);
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
        unique = false;
        continue; // avoid this number :-)
      }
      for (int k=0; k<i; k++) {
        if (j.equals(values[k])) {
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

boolean badWord(String s) {
  String[] badWords = {
    "SEX", "TIT", "GUN", "BUM", "CUM", "FAG", "ASS", "DIE", "DED", "KOK", "DIK", "SUK", "BUT", "PEE", "FUK", "POO", "PIS", "KKK", "HIT", "CUT", "SAD", "BAD", "MAD", "KLL", "PUB", "WET", "KUM", "CRY"
  };
  for (String bw : badWords) {
    if (s.equals(bw)) {
      return true;
    }
  }
  return false;
}


//
void printPostPuzzleActions() {
  int[] nextPuzzleIndex = new int[puzzlesByGuild.length]; // keeps track of the next available puzzle by guild

  // Allocate challenges.
  int challengeIndex = 0;
  int guildIndex=0;
  int CHALLENGE_TYPE = 0;
  int ticketIndex = 0;
  int QUEST_TYPE = 1;
  String maybeComma = ", ";

  println("    // Challenges ...");
  while (challengeIndex<challengeIndices.length) {
    int nextPuzzle = nextPuzzleIndex[guildIndex];
    assert(nextPuzzle<puzzlesByGuild[guildIndex].length);

    int puzzleId = puzzlesByGuild[guildIndex][nextPuzzle];
    println("    {" + puzzleId+ ", " + CHALLENGE_TYPE + ", " + challengeIndices[challengeIndex] + ", " + ticketIndex + "}" 
      + maybeComma + "// " + challengeNames[challengeIndices[challengeIndex]] + " -> " + tickets[ticketIndex] + " (Guild " + (guildIndex+1) + ")"); 
    nextPuzzleIndex[guildIndex]++;
    challengeIndex++;
    ticketIndex++;
    guildIndex = (guildIndex + 1) % puzzlesByGuild.length;
  }

  // Allocate quests...
    println("\n    // Quests ...");
  int questIndex = 0;
  guildIndex = 0;
  while (questIndex<questIndices.length) {
    int nextPuzzle = nextPuzzleIndex[guildIndex];
    assert(nextPuzzle<puzzlesByGuild[guildIndex].length);

    int puzzleId = puzzlesByGuild[guildIndex][nextPuzzle];
    if (questIndex == questIndices.length-1) {
      maybeComma = " ";
    }
    println("    {" + puzzleId+ ", " + QUEST_TYPE + ", " + questIndices[questIndex] + ", " + ticketIndex + "}" 
      + maybeComma + "// Quest " + (questIndices[questIndex]+1) + " -> " + tickets[ticketIndex] + " (Guild " + (guildIndex+1) + ")"); 
    nextPuzzleIndex[guildIndex]++;
    questIndex++;
    ticketIndex++;
    guildIndex = (guildIndex + 1) % puzzlesByGuild.length;
  }
}