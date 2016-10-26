// Helper class for visualization

class NationStatHelper {
  String[]names;
  int populations[];
  int areas[];
  final int BAR_THICKNESS = 20; // Width of bar (graphic).
  final color POPULATION_COLOR = color(128, 128, 128);
  final color AREA_COLOR = color(0, 0, 0);


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
    int[][]hilightedSpots = getHilightedSpots(chosenCountries, answer);
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

  // Compute location of answer letters amongst the chosencountries
  int[][] getHilightedSpots(int[]chosenCountries, String answer) {
    int[][] ret = new int[chosenCountries.length][1];
    for (int[]row : ret) {
      row[0] = 0;
    }
    return ret;
  }

  void drawVizForCountry(int index, int maxLetters, int[]highlightedSpots, float populationFrac, float areaFrac) {
    int y_offset = index*3*BAR_THICKNESS; 
    int boxesWidth = drawLettersBox(10, y_offset, maxLetters, highlightedSpots);
    final int X_GAP = 10;
    final int MAX_BAR_LENGTH=100;
    drawBar(boxesWidth+X_GAP, y_offset, POPULATION_COLOR, MAX_BAR_LENGTH, populationFrac);
    drawBar(boxesWidth+X_GAP, y_offset+BAR_THICKNESS, AREA_COLOR, MAX_BAR_LENGTH, areaFrac);
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
    final int DX=10;
    final int DY=20;
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