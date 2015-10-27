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


void drawClock(int x, int y, int r, int hour, int minute) {
  fill(220);
  strokeWeight(5);
  stroke(50);
  ellipse(x+3, y+3, 2*r, 2*r);
  stroke(0);
  ellipse(x, y, 2*r, 2*r);


  // draw hour hand
  float hourAngle = 2*PI*(hour/12.0 + minute/(12*60.0))   - PI/2;
  // HACK - for semaphores - make the hour hand closer to the 8 possible
  // semaphor positions.
  float hourAngleDegrees = degrees(hourAngle);
  float fraction  = 8*hourAngleDegrees/360;
  float delta = fraction - round(fraction);
  float newDelta = delta/3; // Increase the denominator to do more clamping to semaphore directions.
  hourAngleDegrees = (round(fraction)+newDelta)*360/8;
  hourAngle = radians(hourAngleDegrees);
  pushMatrix();
  translate(x, y); 
  rotate(hourAngle);
  strokeWeight(6);
  line(0, 0, 0.6*r, 0);
  popMatrix();



  // draw minute hand
  float minuteAngle = 2*PI*minute/60.0  - PI/2;
  pushMatrix();
  translate(x, y); 
  rotate(minuteAngle);
  strokeWeight(4);
  line(0, 0, 0.9*r, 0);
  fill(0);
  ellipse(0, 0, 0.1*r, 0.1*r);
  fill(128);
  noStroke();
  ellipse(0, 0, 0.07*r, 0.07*r);
  popMatrix();

  // Draw glass
  pushMatrix();
  translate(x, y); 
  //beginShape();
  noFill();
  stroke(255, 128);
  strokeWeight(8);
  arc(0, 0, 1.8*r, 1.8*r, -PI/2.5, -PI/20);
  //endShape();
  popMatrix();
}