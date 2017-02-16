// Module: LasersMain - code to generate  media needed for the Lasers Puzzle
// History:
//  Feb 2017  - JMJ created, adapted from earlier code I wrote for EAS and Puzzle Safari puzzles
// Module: LASERS.PDE
// Description: Main file for the lasers puzzle generator.
// History:
//  November 2015 - JMJ created
//
// General notes:
//     Grid coordinates: (i, j) are like rows of an array/matrix. So i is vertical,
//     with increasing i going downwards.
//     Angles: normal interpration (0 == going right; 90== going up, etc.)
//
import java.util.Comparator;
import java.util.Arrays;

class LasersMain {

  final String PUZZLE_TYPE = "lasers";
  final String[] puzzleTexts = {
    "BÚFALO", 
    "CAMELLO", 
    "VENADO", 
    "ELEFANTE", 
    "JIRAFA", 
    "GORILA", 
    "CABALLO", 
    "CANGURO", 
    "LEOPARDO", 
    "CONEJO", 
    "ARDILLA", 
    "BELLENA", 
    "DELFÍN", 
    "CUERVO", 
    "PALOMA", 
    "ÁGUILA", 
    "FLAMENCO", 
    "COLIBRÍ", 
    "AVESTRUZ", 
    "PAPAGAYO", 
    "PELICANO", 
    "PALOMA", 
    "QUETZAL"
  };

  void genAllMedia() {

    // To recreate a specific puzzle, make a note of the printed seed value and 
    // set seed to that printed seed value (comment out the call to round(random(...))).
    long seed = round(random(MAX_INT));
    println("SEED: " + seed);
    randomSeed(seed);

    // Set runSpecific to true to run a specific, previously-computed puzzle
    Boolean runSpecific = false;
    if (runSpecific) {
      runSpecific();
    } else { 

      // Size of the grid...
      int rows = 7;
      int cols = 7;
      int numCandidatePuzzlesPerPuzzle = 100;

      for (String puzzleText : puzzleTexts) {
        String IN  = gSolutions.lookupIN(puzzleText); // We expect the string version of the count to be a valid solution!
        String fileStub = gUtils.genMediaFilenameStub(PUZZLE_TYPE, IN);

        LaserHelper lh = generateGoodPuzzle(rows, cols, puzzleText, numCandidatePuzzlesPerPuzzle);
        background(LIGHT_GRAY_BACKGROUND);
        lh.g.draw();
        save(fileStub +  ".png");
        gUtils.saveAnswerText(PUZZLE_TYPE, IN, puzzleText);

        background(LIGHT_GRAY_BACKGROUND);
        // Actually draw out the paths taken by all the lasers
        // (comment out to NOT draw paths - the puzzle itself of course does NOT have
        // any paths drawn)
        lh.drawPaths(puzzleText);

        // Draw the lasers and the grid (drawn on TOP of the paths so that the labels, etc
        // are shown)
        lh.g.draw();
        save(fileStub +  "-ans.png");

        // Print out a text representation of the grid. This is actually Java code that defines
        // a couple of arrays - you can cut and paste this code into the runSpecific() method to
        // regenerate exactly that puzzle.
        //lh.printGrid(null);

        // Compute various "goodness" stats about this puzzle and print it out.
        //PuzzleStats pStats = lh.computePuzzleStats();
        //println("Puzzle Stats:");
        //println(pStats);
        // break;
      }
    }
  }


  LaserHelper genObjects(String[] spec, int[] laserIds) {
    int rows = spec.length;
    int cols = (rows>0)? spec[0].length():0;
    int GRID_WIDTH = width;
    int GRID_HEIGHT = height;
    int GRID_PADDING = 10;
    Grid g = new Grid(rows, cols, GRID_WIDTH, GRID_HEIGHT, GRID_PADDING);
    LaserHelper lh = new LaserHelper(g);
    lh.initFromSpec(spec, laserIds);

    return lh;
  }


  // Create a gid and fill it with dots.
  LaserHelper createDotGrid(int rows, int cols) {
    String[] spec = new String[rows];
    if (rows>0) {
      String dots = "";
      for (int i=0; i<cols; i++) {
        dots += ".";
      }
      for (int i=0; i<rows; i++) {
        spec[i] = dots;
      }
    }
    return genObjects(spec, null);
  }


  LaserHelper generateGoodPuzzle(int rows, int cols, String puzzleText, int numTrials) {

    PuzzleStats[] puzzleStats = new PuzzleStats[numTrials];
    String[][] puzzleSpecs = new String[numTrials][];
    int[][]laserIds = new int[numTrials][];
    Boolean[] qualifiedPuzzles = new Boolean[numTrials];

    for (int i=0; i<numTrials; i++) {
      LaserHelper lh = createRandomPuzzle(rows, cols, puzzleText, 100);
      qualifiedPuzzles[i] = !disqualifyPuzzle(lh);
      puzzleStats[i] = lh.computePuzzleStats();
      puzzleSpecs[i] =lh.specFromGrid();
      laserIds[i] = lh.getLaserIds();
      if (lh.hasError) {
        return lh; // ******* EARLY RETURN WITH BAD PUZZLE
      }
    }

    // Lets compute the average of the averages (they all have the same weight - number of lasers per puzzle)
    float mirrorCountAvg=0;
    float ssDAvg=0;
    float maxSpanAvg=0;
    for (PuzzleStats ps : puzzleStats) {
      mirrorCountAvg += ps.mirrorCount.avg;
      ssDAvg += ps.ssDistance.avg;
      maxSpanAvg += ps.maxSpan.avg;
    }
    mirrorCountAvg/=puzzleStats.length;
    ssDAvg/=puzzleStats.length;
    maxSpanAvg /= puzzleStats.length;
    println("mcAvg:" + mirrorCountAvg + " ssDAvg:" + ssDAvg + " maxSpanAvg:" + maxSpanAvg);

    // Now let's pick the one puzzle with the max(min/avg value for every stat.

    float bestPrimaryScore = -1;
    for (int i=0; i<puzzleStats.length; i++) {
      if (qualifiedPuzzles[i]) {
        float score = primaryCompositeScore(puzzleStats[i], mirrorCountAvg, ssDAvg, maxSpanAvg);
        if (bestPrimaryScore < score) {
          bestPrimaryScore = score;
        }
      }
    }

    float bestSecondaryScore = -1;
    int bestIndex = -1;
    for (int i=0; i<puzzleStats.length; i++) {
      if (qualifiedPuzzles[i]) {
        float score1 = primaryCompositeScore(puzzleStats[i], mirrorCountAvg, ssDAvg, maxSpanAvg);
        float score2 = secondaryCompositeScore(puzzleStats[i], mirrorCountAvg, ssDAvg, maxSpanAvg);
        if (score1>=bestPrimaryScore && bestSecondaryScore < score2) {
          bestSecondaryScore = score2;
          bestIndex=i;
        }
      }
    }

    println("BEST SCORE: " + bestPrimaryScore +  "-" + bestSecondaryScore);
    LaserHelper lhFinal  = genObjects(puzzleSpecs[bestIndex], laserIds[bestIndex]);
    return lhFinal;
  }


  Boolean disqualifyPuzzle(LaserHelper lh) {
    // Check if any two lasers are back-to-back.
    Cell[] laserCells = lh.getLasers();
    for (int i=0; i<laserCells.length; i++) {
      Cell lcI = laserCells[i];
      for (int j=0; j<i; j++) {
        Cell lcJ = laserCells[j];
        if (abs(lcI.i-lcJ.i)+abs(lcI.j-lcJ.j) == 1) { // adjacent
          int dirI = lh.cardinalDirection(lcI.orientation);
          int dirJ = lh.cardinalDirection(lcJ.orientation);
          if ((4+dirI-dirJ)%4==2) {
            // opposite directions
            if ((dirI%2 == 0 && lcI.j!=lcJ.j) || (dirI%2 == 1&&lcI.i!=lcJ.i)) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }


  // We return the min of the min after normalizing each by dividing by the supplied population average.
  float primaryCompositeScore(PuzzleStats ps, float mirrorCountAvg, float ssDAvg, float maxSpanAvg) {
    float min1 = ps.mirrorCount.min/mirrorCountAvg;
    float min2 = ps.ssDistance.min/ssDAvg;
    float min3 = ps.maxSpan.min/maxSpanAvg;
    return min(min1, min2, min3);
    //return min(min2, min3);
  }


  float secondaryCompositeScore(PuzzleStats ps, float mirrorCountAvg, float ssDAvg, float maxSpanAvg) {
    //float min1 = ps.mirrorCount.min/mirrorCountAvg;
    float min2 = ps.ssDistance.min/ssDAvg;
    float min3 = ps.maxSpan.min/maxSpanAvg;
    //return min(min1, min2, min3);
    return min(min2, min3);
  }


  LaserHelper createRandomPuzzle(int rows, int cols, String puzzleText, int iterations) {
    LaserHelper lh = createDotGrid(rows, cols); 
    lh.addToGrid(puzzleText);
    int prevDotCount=-1;
    int noProgressCount=0;
    int MAX_NO_PROGRESS_COUNT = 10;
    for (int i=0; i<iterations; i++) {
      lh.addToPathComplexity();
      int dotCount = lh.dotCount();
      if (dotCount==prevDotCount) {
        //println("STOPPING AFTER " + i + " ITERATIONS!");
        noProgressCount++;
        if (noProgressCount>MAX_NO_PROGRESS_COUNT) {
          break;
        }
      } else {
        //Had this code to check if we would have made progress - doesn't hit for the current max count we set of 10.
        //if (noProgressCount>MAX_NO_PROGRESS_COUNT) {
        //  println("Hmm, PROGRESS *AFTER* we would have stopped. DC: " + dotCount + " prevDC: " + prevDotCount + " NPCount:" + noProgressCount);
        //}
        //assert(!hitBreak);
        noProgressCount=0;
      }
      prevDotCount = dotCount;
    }
    return lh;
  }


  // Generate a specific puzzle from its textual description.
  // This same description is printed by the call to printGrid().
  void  runSpecific() {
    String[] spec = {
      "........--.../......:]--[", 
      "../........../..[..-.|--|", 
      "....-........./....=.||||", 
      "/./|-.|---.|...--|//.-|||", 
      "..-D|.-|..--.......-...-|", 
      ".|-|...-................{", 
      ".A....|..|....:.:....-./:", 
      "^.-|..-|...-.....0...--..", 
      "|.........-....|...3.->./", 
      "||..-..|-.....-..../..:.{", 
      "|-|+..............:./....", 
      "||||...|.W.....|.|.......", 
      "||-.....|...-.|-........{", 
      "|.|..|....-.-..|.|.:.../.", 
      ".|.|.|-./&...|...|...|...", 
      "|.|...|..||-....../.../.|", 
      "||||-./......<.|.....|...", 
      "|.-|-/..:......:....|../:", 
      "..-|.......2-.-..|.......", 
      "./.../....----......|||..", 
      "../.../-../......./---...", 
      "/............:-:.....:-..", 
      ".... ...:.:8....:......./", 
      ":.../--.-.:........../<.{", 
      ">/:........../.{...-{:./."
    };
    int[] ids = {4, 5, 11, 1, 2, 3, 12, 8, 6, 10, 13, 7, 14, 9};
    String textboxText = "=DA03+W&2 8";
    LaserHelper lh = genObjects(spec, ids);
    background(200);
    lh.g.draw();
    save("output\\ouput-noPaths.png");
    background(200);
    String puzzleText = "1";
    //drawLaserPath(g, 1, "a"); // Uncomment to draw a specific path for the answer doc.
    //lh.drawPaths(puzzleText);
    lh.g.draw();
    save("output\\ouput-withPaths.png");
    lh.printGrid(sketchPath("output\\output-spec.txt"));
    //printGrid(g, null); // To print to console
  }
}