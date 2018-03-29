class DataOrganizer {

  private final Table input;

  // Load a csv file containing puzzle data. It has no header, and columns like:
  //  391,Mathematical Mischief-1,Green,P
  // 431,Mathematical Mischief-2,Gray,P
  DataOrganizer(Table input) {
    this.input = input;
  }

  // guildNo: One-based guild number
  String[][] generateGuildAnswerRowInfo(int guildNo) {
    ArrayList<String[]> infoList = new ArrayList<>();
    // Run down the table, picking up all items that match the specific guild by name.
    String guildName = g_guildNames[guildNo-1];
    for (TableRow row : this.input.rows()) {
      // 391,Mathematical Mischief-1,Green,P
      String gn = row.getString(2);
      if (guildName.equals(gn)) {
        String[] info = {row.getString(0), row.getString(1)};
        infoList.add(info);
      }
    }

    return infoList.toArray(new String[0][]);
  }


  // guildNo: One-based guild number
  String[][] generateGuildAnswerRowInfoDummy(int guildNo) {
    final int N = 10;
    final int PBASE = 100;
    String[][] info = new String[N][];
    for (int i = 0; i < N; i++) {
      String pnum = ""+ (PBASE+g_guildNames.length*guildNo + i);
      String pname = "Puzzle " + g_guildNames[guildNo-1] + " " + (i + 1);
      info[i] = new String[]{pnum, pname};
    }
    return info;
  }

  // Generate the tickets that this (clanNo, guildNo) will participate in.
  // These must be in the form of a 2D array.
  //    cellText[i][1] = "<< "+letter + ") " + a;
  //    cellText[i][0] = "<<"+a.toUpperCase()+"\n" + g_clanNames[clanNo-1] + "-" + guildNo + " ticket";

  String[][] generateGuildTickets(int clanNo, int guildNo) {
    final int N = 10;
    final int PBASE = 100;
    String[][] info = new String[N][];
    for (int i = 0; i < N; i++) {
      String ch = "Challenge " + (i+1);
      String tornoff = "<<"+ch.toUpperCase()+"\n" + g_clanNames[clanNo-1] + "-" + g_guildNames[guildNo-1].toUpperCase() + " ticket";
      char letter = (char)('a'+i);
      String remains = "<< "+letter + ") " + ch;
      info[i] = new String[]{tornoff, remains};
    }
    return info;
  }
}