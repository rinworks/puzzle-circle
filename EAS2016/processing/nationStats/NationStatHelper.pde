// Helper class for visualization

class NationStatHelper {
  String[]names;
  int populations[];
  int areas[];
  
  public NationStatHelper(String[]names, int[] populations, int[] areas) {
    assert (names.length == populations.length);
    assert(names.length == areas.length);
    this.names = names;
    this.populations = populations;
    this.areas = areas;
  }
  
  // Render a puzzle for the specific countries. Find (if possible) an answer
  // by searching among letters of the chosen countries, and hilight those spaces.
  // Print & render a warning if the answer could not be found.
  public void   renderPuzzle(int[] chosenCountries, String answer) {
  }
}