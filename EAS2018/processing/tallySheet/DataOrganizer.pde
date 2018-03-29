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
    ArrayList<String[]> infoList = new ArrayList<String[]>();
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

  // Generate the tickets that this (clanNo, guildNo) will participate in.
  // These must be in the form of a 2D array.

  String[][] generateGuildTickets(int clanNo, int guildNo) {
    ArrayList<String[]> infoList = new ArrayList<String[]>();
    // Run down the table, picking up all items that match the specific guild by name.
    String guildName = g_guildNames[guildNo-1];
    for (TableRow row : this.input.rows()) {
      // 645,Magical Creatures-1,Green,C
      String gn = row.getString(2);
      String type = row.getString(3);
      final String TYPE_CHALLENGE = "C";
      int i = 0;
      if (guildName.equals(gn) && type.equals(TYPE_CHALLENGE)) {
        String ch = row.getString(1);
        String tornoff = "<<"+ch.toUpperCase()+"\n" + g_clanNames[clanNo-1] + "-" + g_guildNames[guildNo-1].toUpperCase() + " ticket";
        char letter = (char)('a'+i);
        String remains = "<< "+letter + ") " + ch;  
        String[] info = {tornoff, remains};
        infoList.add(info);
        i++;
      }
    }
    return infoList.toArray(new String[0][]);
  }
}