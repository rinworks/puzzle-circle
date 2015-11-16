void setup() {
  int[][] guildPuzzles = {
    {0}
  };
  int[] oldIds = {860, 288, 683, 199, 138, 343, 456, 565, 381, 613, 705, 403, 788  };
  int[] puzzleIds = generateRandomIds(0, oldIds, 60);
  /*
  for (int i=0; i<puzzleIds.length; i++) {
    println("["+(i+1)+"] "+puzzleIds[i]);
  }

  String[] oldTickets = {}; // {"AAA", "BBB", "CCC"};
  String[] puzzleTickets = generateRandomTickets(128, oldTickets, 100);
  for (int i=0; i<puzzleTickets.length; i++) {
    String s = ((i>0) ? ", " : "") + ((i%10==0) ? "\n    " : "") + "\"" + puzzleTickets[i] + "\"";
    print(s);
  }
  */
  
  printPostPuzzleActions();
}