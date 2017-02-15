// Module: Utilities
// History:
//  Feb 2017  - JMJ created.

// NOTE: we're not making CommonUtils a static class so that we can call Processing's numerous methods if needed.
// Downside is that you need an instance to use it. This global instance is typically called gUtils.
public class CommonUtils {

  // Generates a media filename stub given puzzle type and 0-based index of puzzle index.
  // Note: the filename stub has the instance ID encode, but it is ONE-based.
  // Example: genMediaFileNameStub("clocks", 1) produces "output/clocks/clocks-02"
  public  String genMediaFilenameStub(String puzzleType, int index) {
    String ID = String.format("%02d", index+1); // 1-based puzzle instance ID. E.g., "01"
    return "output/" + puzzleType + "/" + puzzleType + "-" + ID;
  }
  
  // Saves the given answer text into an appropriately named file.
  // Index is a 0-based instance index of the puzzle.
  // Sample text file name: output/clocks/clocks-02-ans.txt
  public  void saveAnswerText(String puzzleType, int index, String answerText) {
    String filename = genMediaFilenameStub(puzzleType, index) + "-ans.txt";
    saveStrings(filename, new String[] {answerText});
  }
}