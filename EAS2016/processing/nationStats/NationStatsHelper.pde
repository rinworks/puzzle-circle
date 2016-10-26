// Helper class for visualization

class Country {
  public String name;
  public String ucName;
  public int population;
  public int area; // in SQ Miles.
  public Country(String n, int p, int a) {
    name = n;
    ucName = n.toUpperCase(); // For comparison
    population = p;
    area = a;
  }
}

class NationStatHelper {
  Country[] countries;
  final int BAR_THICKNESS = 20; // Width of bar (graphic).
  final color POPULATION_COLOR = color(150, 150, 150);
  final color AREA_COLOR = color(32, 32, 32);


  public NationStatHelper(Country[] countries) {
    this.countries = countries;
  }

  // Returns the country with the given name (case INsensitive exact match), null otherwise.
  Country findCountry(String name) {
    name = name.toUpperCase();
    for (Country c : countries) {
      if (c.ucName.equals(name)) {
        return c;
      }
    }
    return null;
  }

  // Render a puzzle for the specific countries. Find (if possible) an answer
  // by searching among letters of the chosen countries, and hilight those spaces.
  // Print & render a warning if the answer could not be found.
  // Returns a table containing the stats of the selected countries.
  public Table renderPuzzle(String[] encodedNames) {
     background(255);
    int maxLetters = 0;
    int maxArea = 0;
    int maxPopulation = 0;
    int[][] hilightedSpots = extractHighlightedSpots(encodedNames);
    ArrayList<Country>  chosenCountries = getChosenCountries(encodedNames);

    for (Country c : chosenCountries) {
      maxLetters = max(maxLetters, c.name.length());
      maxArea = max(maxArea, c.area);
      maxPopulation = max(maxPopulation, c.population);
    }

    int i=0;
    for (Country c : chosenCountries) {
      drawVizForCountry(i, maxLetters, hilightedSpots[i], (float)c.population/maxPopulation, (float)c.area/maxArea);
      i++;
    }
    
    return makeStatsTable(chosenCountries);
  }

  // Construct a 2D array representing highlighted letters by
  // scannning the encodedNames, that have '>' immediately preceeding
  // hilighted (answer) characters.
  int[][] extractHighlightedSpots(String[] encodedNames) {
    final char MARK = '>';
    int[][]allSpots = new int[encodedNames.length][];
    ArrayList<Integer>tmp = new ArrayList<Integer>(); // scratch array
    
    // We're going to initialize each row with the locations of the MARK char within
    // the ith element of encodedNames. 
    for (int i=0; i<allSpots.length; i++) {
      String name = encodedNames[i];
      int j = name.indexOf(MARK);
      int pastMarks=0; // Count of MARK characters we've already seen, to adjust offsets.
      tmp.clear();
      while (j>=0) {
        Utils.assertMsg((j+1)<name.length(), "Illegal '>' char at end of name " + name);
        assert(j>=pastMarks);
        tmp.add(j-pastMarks);
        j = name.indexOf(MARK, j+1);
      }
      // Convert the array list into an int array (don't think there is an
      // easier way to do this - tmp.toArray() returns an array of Integers, not ints.
      int[] newSpots = new int[tmp.size()];
      j=0;
      for (int k: tmp) {
        newSpots[j] = k;
        j++;
      }
      allSpots[i] = newSpots;
    }
    return allSpots;
  }

  // Return the list of countries specified in the array of encoded names.
  // (Encoded names have embedded '>' markers that have to be removed first.
  ArrayList<Country> getChosenCountries(String[] encodedNames) {
    ArrayList<Country> list = new ArrayList<Country>(encodedNames.length);
    for (String e : encodedNames) {
      String name = e.replace(">", "");
      Country c = findCountry(name);
      Utils.assertMsg(name!=null, "Could not find country with name " + name);
      list.add(c);
    }
    return list;
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

  // The answer letters are preceded by the '>' character.
  String computeAnswer(String[] chosenCountries) {
    final char MARK = '>';
    String ans = "";
    for (String name : chosenCountries) {
      int i = name.indexOf(MARK);
      while (i>=0) {
        Utils.assertMsg((i+1)<name.length(), "Illegal '>' char at end of name " + name);
        ans += name.charAt(i+1);
        i = name.indexOf(MARK, i+1);
      }
    }
    return ans;
  }
  
  Table makeStatsTable(ArrayList<Country>chosen) {
    Table tab = new Table();
    final String N = "Country";
    final String P = "Population";
    final String A = "Area(sq mi)";
    tab.addColumn(N);
    tab.addColumn(P);
    tab.addColumn(A);
    for (Country c: chosen) {
      TableRow row = tab.addRow();
      row.setString(N, c.name);
      row.setInt(P, c.population);
      row.setInt(A, c.area);
    }
    return tab;
  }
}