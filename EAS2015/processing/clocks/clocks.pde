class Time {
  int hour;
  int minute;
  Time(int h, int m) {
    hour=h;
    minute=m;
  }

  Time(Time t) {
    hour = t.hour;
    minute = t.minute;
  }
}

// Encode letters a-z
int[][] semaphoreLetterTable = {
  {7, 30}, {9, 30}, {10, 30}, {12, 30}, {6, 7}, // ABCDE
  {6, 15}, {6, 22}, {7, 45}, {10, 37}, {12, 15}, // FGHIJ
  {7, 0}, {7, 7}, {7, 15}, {7, 22}, {8, 52}, // KLMNO
  {9, 0}, {9, 7}, {9, 15}, {9, 22}, {11, 00}, // PQRST
  {10, 7}, {12, 22}, {1, 15}, {1, 22}, {10, 15}, // UVWXY
  {4, 15}    // Z
};

void setup() {
  noLoop();
  size(1500, 500);
  println(addSemaphoreEscapes("ABC123ABC DEF345 678"));
}

void draw() {
  background(150);
  //drawClock(150, 150, 100, 12, 10);
  //Time[] times = rot13SemaphoreTimes();
  Time[] times = semaphoreEncode("0123456789");
  drawClocks(times);
}

void drawClocks(Time[] times) {
  int n = times.length;
  int r = width/(3*n);
  int y = height/2;
  for (int i=0; i<n; i++) {
    int x = (int) (2.5*i*r + 2.5*r);
    Time t = times[i];
    drawClock(x, y, r, t.hour, t.minute);
  }
}

Time[] randomTimes(int n) {
  Time[] times = new Time[n];
  for (int i=0; i<n; i++) {
    Time t = new Time((int)random(12), (int) random(60));
    times[i] = t;
  }
  return times;
}

Time[] rot13SemaphoreTimes() {
  Time[] times = new Time[6];
  times[0] = new Time(9, 15); // R
  times[1] = new Time(10, 45); // O
  times[2] = new Time(10, 0); // T
  times[3] = new Time(0, 7); // #
  times[4] = new Time(7, 30); // 1
  times[5] = new Time(10, 30); // 3
  return times;
}

// Return semaphore coding of the given text.
// Numbers are mapped to A-I and K (# is not
// inserted so the caller should be responsible for
// inserting the #). Space is encoded.
Time[] semaphoreEncode(String puzzleText) {
  puzzleText = addSemaphoreEscapes(puzzleText); // insert # or L when switching from alpha ton non alpha and back

  Time[] ret = new Time[puzzleText.length()];
  for (int i=0; i< puzzleText.length(); i++) {
    ret[i] = semaphoreEncode(puzzleText.charAt(i));
  }
  return ret;
}

// insert # or L when switching from alpha to non alpha and back.
// Throws IllegalArgumentException if a non-alnum (or space) character is detected.
String addSemaphoreEscapes(String puzzleText) {
  puzzleText = puzzleText.toUpperCase();
  String ret = "";
  Boolean alpha=true;
  for (int i=0; i< puzzleText.length(); i++) {
    char c = puzzleText.charAt(i);
    if (c >='0' && c <='9') {
      // Numeric
      if (alpha) {
        ret += '#';
        alpha=false;
      }
      ret += c;
    } else if ((c >= 'A' && c <= 'Z')|| (c ==' ')) {
      // Alpha
      if (!alpha) {
        ret += 'L';
        alpha=true;
      }
      ret += c;
    } else {
      throw new IllegalArgumentException("unsopported semaphore clar: " + c);
    }
  }
  return ret;
}


Time semaphoreEncode(char c) {
  // Reference: https://en.wikipedia.org/wiki/Flag_semaphore 
  c = Character.toUpperCase(c);
  int[] time;
  if (c == '#') {
    return new Time(12, 7); // ***** EARLY RETURN *****
  } else if (c == ' ') {
    return new Time(6, 30); // ***** EARLY RETURN *****
  } else if (c == '0') {
    return  semaphoreEncode('K'); // ***** EARLY RETURN *****
  } else if (c >= '1' && c <= '9') {
    time =  semaphoreLetterTable[c-'1'];
  } else if (c >= 'A' && c <= 'Z') {
    time =  semaphoreLetterTable[c-'A'];
  } else {
    throw new IllegalArgumentException("Illegal character: " + c);
  }

  return new Time(time[0], time[1]);
}