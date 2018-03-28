void setup() {
  int[][] guildPuzzles = {
    {0}
  };
  int[] oldIds = {  };
  int[] puzzleIds = generateRandomIds(0, oldIds, 20, 701, 899);
  
  for (int i=0; i<puzzleIds.length; i++) {
    println(puzzleIds[i]);
  }
/*
  String[] oldTickets = {}; // {"AAA", "BBB", "CCC"};
  String[] puzzleTickets = generateRandomTickets(128, oldTickets, 100);
  for (int i=0; i<puzzleTickets.length; i++) {
    String s = ((i>0) ? ", " : "") + ((i%10==0) ? "\n    " : "") + "\"" + puzzleTickets[i] + "\"";
    print(s);
  }
  
  
  printPostPuzzleActions();
  */
}