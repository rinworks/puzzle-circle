// Module: Utilities
// History:
//  Feb 2017  - JMJ created.
import java.util.NoSuchElementException;
import java.util.Locale;

// NOTE: we're not making CommonUtils a static class so that we can call Processing's numerous methods if needed.
// Downside is that you need an instance to use it. This global instance is typically called gUtils.
public class CommonUtils {

  // Generates a media filename stub given puzzle type and 0-based index of puzzle index.
  // Example: genMediaFileNameStub("clocks", "01" ) produces "output/clocks/clocks-01"
  public  String genMediaFilenameStub(String puzzleType, String IN) {
    return "output/" + puzzleType + "/" + puzzleType + "-" + IN;
  }

  // Saves the given answer text into an appropriately named file.
  // Sample text file name: output/clocks/clocks-02-ans.txt
  public  void saveAnswerText(String puzzleType, String IN, String answerText) {
    String filename = genMediaFilenameStub(puzzleType, IN) + "-ans.txt";
    saveStrings(filename, new String[] {answerText});
  }
}

class MasterSolutionList {

  private class Mapping {
    public String id;
    public String sol;
    public String canSol;
    public Mapping(String id, String sol, String canSol) {
      this.id = id;
      this.sol = sol;
      this.canSol = canSol;
    }
    public String toString() {
      return "(" + id + "," + sol + "," + canSol + ")";
    }
  }
  private final String ID_HEADING = "IN";
  private Mapping[] map; // Map of IDs to Solutions. 1st Col are IDs. 
  // 2nd Col is solution. 3rd col is canonicalized soln.      
  // We don't use a dictionary as we want flexibility in finding IDs.
  // filename - CSV file containing the master solutions list.
  // solutionCol - The heading of the column that contains the solution
  public MasterSolutionList(String filename, String solutionCol) {
    Table table = loadTable(filename, "header");
    println("MSL: rowcount: " + table.getRowCount());
    map = new Mapping[table.getRowCount()];
    int i = 0;
    for (TableRow row : table.rows()) {
      int id = row.getInt(ID_HEADING);
      String sol = row.getString(solutionCol);
      map[i] = new Mapping(String.format("%02d", id), sol, canonicalize(sol));
      //println(map[i]);
      i++;
    }
  }

  // Looks up the instance ID corresponding to the supplied solution.
  // This lookup strips out all whitespace and then does a case-insensitive compare.
  // Throws a NotFound exception if it doesn't find anything.
  public String lookupIN(String solution) {
    String canSol = canonicalize(solution);
    println("Looking up " + canSol);
    for (Mapping item : map) {
      if (canSol.equals(item.canSol)) {
        return item.id;
      }
    }
    throw new NoSuchElementException("Unknown solution: " + solution + "/" + canSol);
  }

  private String canonicalize(String s) {
    final char[] accentsMap = "ÚUÁAÍIÉE".toCharArray(); // There are more of course, but these we are dealing with now.
    s = s.replaceAll("\\s", "").toUpperCase();//Locale.ENGLISH);
    // Now replace accents...
    for (int i = 0; i< accentsMap.length; i+=2) {
       s = s.replace(accentsMap[i], accentsMap[i+1]);
    }
    return s;
  }
}