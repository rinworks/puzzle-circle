// Module: ClocksMain - code to generate  media needed for the Clocks Puzzle
// History:
//  Feb 2017  - JMJ created, adapted from earlier code I wrote for EAS and Puzzle Safari puzzles
class ClocksOptions {
  public String puzzleText;
}

class ClocksMain {

  final String outputDir;
  final String PUZZLE_TYPE = "clocks";
  final String[][] puzzleTexts = {
    {
      "MINU", 
      "TES ", 
      "IN A", 
      "WEEK"
    }, 
    {
      "HASTA", 
      "LA", 
      "VISTA", 
      "BABY"
    }
  };
  public ClocksMain(String outputDir) {
    this.outputDir = outputDir;
  }

  void genAllMedia() {

    for (int i=0; i<puzzleTexts.length; i++) {
      String fileStub = gUtils.genMediaFilenameStub(PUZZLE_TYPE, i);
      background(150);
      drawClocks(puzzleTexts[i], false);
      save(fileStub +  ".png");
      drawClocks(puzzleTexts[i], true);
      save(fileStub + "-answer" + ".png");
      saveAnswerText(i);
    }
  }

  // saves the text associated with 0-based puzzle "index" in a text file.
  void saveAnswerText(int index) {
    String[] puzzleText = puzzleTexts[index];
    String txt = "";
    for (String s: puzzleText) {
      txt += s;
    }
    gUtils.saveAnswerText(PUZZLE_TYPE, index, txt);
  }
  
  void drawClocks(String[] puzzleText, Boolean showText) {
    if (puzzleText.length==0) {
      return; // ******************** EARLY RETURN
    }

    Time[][] times = new Time[puzzleText.length][];
    for (int i=0; i<times.length; i++) {
      times[i] = semaphoreEncode(puzzleText[i]);
    }
    // G = R/2; // inter object gap
    // W = G + N(2R+G)
    //   = R/2 + N(2R+R/2)
    //   = R(1/2 + N(2+1/2))
    //   = R(0.5 + 2.5*N)
    // R = W/(0.5 + 2.5*N)

    float W = width;
    float H = height;
    int nX = times[0].length; 
    for (Time[] row : times) {
      if (nX<row.length) {
        nX = row.length;
      }
    }
    int nY = times.length;
    float rX = W/(0.5 + 2.5*nX);
    float rY = H/(0.5 + 2.5*nY);
    ;
    float r = min(rX, rY);

    float x0= 1.5*rX;
    float y0= 1.5*rY;

    // i is row
    for (int i=0; i<nY; i++) {
      float y = y0 + (int)(2.5*i*rY);
      // j is col
      for (int j=0; j<nX; j++) {
        float x = x0 + (int) (2.5*j*rX);
        if (j < times[i].length) {
          Time t = times[i][j];
          String text = showText ? ""+puzzleText[i].charAt(j) : null;
          drawClock((int)x, (int)y, (int)r, t.hour, t.minute, text);
        }
      }
    }
  }
}