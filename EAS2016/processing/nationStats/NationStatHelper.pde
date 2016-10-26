// Helper class for visualization

class NationStatHelper {
  String[]names;
  int populations[];
  int areas[];
  final int BAR_WIDTH = 20; // Width of bar (graphic).
  final color POPULATION_COLOR = color(128, 128, 128);
  final color AREA_COLOR = color(0,0,0);
  

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
    drawBar(10, 10, POPULATION_COLOR, 100, 0.5);
    drawBar(10, 20, AREA_COLOR, 100, 0.3);
    int[] highlightedSpots = {1, 3};
    drawLettersBox(10, 50, 10, highlightedSpots);
  }

  // Draw a horizontal bar with upper left at (x, y) with color c and length frac fraction of max.
  void drawBar(int x, int y, color c, int max, float frac) {
    rectMode(CORNER);
    noStroke();
    fill(c);
    rect(x, y, frac*max, BAR_WIDTH);
  }

  // Draw a row of adjacent boxes for n letters with upper left corner at (x, y), and with the specified
  // spots (0-based) hilighted in some way.
  void drawLettersBox(int x, int y, int n, int[] highlightedSpots) {
    final int DX=10;
    final int DY=20;
    final int DHY=5;
    rectMode(CORNER);
    stroke(0); // Black
    strokeWeight(2);
    for (int i=0; i<n; i++) {
      noFill();
      rect(x+i*DX, y, DX, DY);
      for (int j: highlightedSpots) {
        if (i==j) { // Highlight!
          fill(0); // Black
          rect(x+i*DX, y+DY, DX, DHY);
        }
      }
    }
  }
}