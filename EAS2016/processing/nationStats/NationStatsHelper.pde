// Helper class for visualization

class NationStatHelper {
  String[]names;
  int populations[];
  int areas[];
  final int BAR_THICKNESS = 20; // Width of bar (graphic).
  final color POPULATION_COLOR = color(150, 150, 150);
  final color AREA_COLOR = color(32, 32, 32);


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
  public void   renderPuzzle(int[] chosenCountries, int[][] hilightedSpots) {
    background(255);
    int maxLetters = 0;
    int maxArea = 0;
    int maxPopulation = 0;
    for (int i : chosenCountries) {
      maxLetters = max(maxLetters, names[i].length());
      maxArea = max(maxArea, areas[i]);
      maxPopulation = max(maxPopulation, populations[i]);
    }
    for (int i=0; i<chosenCountries.length; i++) {
      int j = chosenCountries[i]; // j is the country ID
      drawVizForCountry(i, maxLetters, hilightedSpots[i], (float)populations[j]/maxPopulation, (float)areas[j]/maxArea);
    }
  }

  // Verifies that the hilighted spots indeed spell out the answer.
  // Assertion failure otherwise.
  void verifyAnswer(int[]chosenCountries, int[][] hilightedSpots, String answer) {
    int ansOffset=0;
    for (int i=0;i<chosenCountries.length;i++) {
      int id = chosenCountries[i]; // id is the countryID;
      int[] spots = hilightedSpots[i];
      String name = names[id];
      for (int s:spots) {
        assertMsg(s<name.length(), "offset " + s + "out of bounds for name " + name);
        char c = name.charAt(s);
        assertMsg(ansOffset<answer.length(), "too many hilighted boxes!");
        char ac = answer.charAt(ansOffset);
        assertMsg(c == ac, "hilighted letter("+c+") does not match answer letter("+ac+")");
        ansOffset++;
      }
    }
    assertMsg(ansOffset == answer.length(), "Unfilled answer chars: " + answer.substring(ansOffset));
  }

  void drawVizForCountry(int index, int maxLetters, int[]highlightedSpots, float populationFrac, float areaFrac) {
    int x_base = BAR_THICKNESS;
    int y_base = BAR_THICKNESS;
    int y_offset = y_base + index*3*BAR_THICKNESS; 
    int boxesWidth = drawLettersBox(x_base, y_offset, maxLetters, highlightedSpots);
    final int X_GAP = BAR_THICKNESS;
    final int MAX_BAR_LENGTH=100;
    drawBar(x_base + boxesWidth+X_GAP, y_offset, POPULATION_COLOR, MAX_BAR_LENGTH, populationFrac);
    drawBar(x_base + boxesWidth+X_GAP, y_offset+BAR_THICKNESS, AREA_COLOR, MAX_BAR_LENGTH, areaFrac);
  }

  // Draw a horizontal bar with upper left at (x, y) with color c and length frac fraction of max.
  void drawBar(int x, int y, color c, int max, float frac) {
    rectMode(CORNER);
    noStroke();
    fill(c);
    rect(x, y, frac*max, BAR_THICKNESS);
  }

  // Draw a row of adjacent boxes for n letters with upper left corner at (x, y), and with the specified
  // spots (0-based) hilighted in some way.
  // Returns width (x-dim) of box.
  int drawLettersBox(int x, int y, int n, int[] highlightedSpots) {
    final int DX=(int) (BAR_THICKNESS*1.5);
    final int DY=2*BAR_THICKNESS;
    final int DHY=5;
    rectMode(CORNER);
    stroke(0); // Black
    strokeWeight(2);
    int boxWidth=0;
    for (int i=0; i<n; i++) {
      noFill();
      rect(x+i*DX, y, DX, DY);
      boxWidth+=DX;
      for (int j : highlightedSpots) {
        if (i==j) { // Highlight!
          fill(0); // Black
          rect(x+i*DX, y+DY, DX, DHY);
        }
      }
    }
    return boxWidth;
  }
}