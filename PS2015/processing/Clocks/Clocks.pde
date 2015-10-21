class Time {
  int hour;
  int minute;
  Time(int h, int m) {
    hour=h;
    minute=m;
  }
}

void setup() {
  noLoop();
  size(1500, 500);
}

void draw() {
  background(150);
  //drawClock(150, 150, 100, 12, 10);
  Time[] times = rot13SemaphoreTimes();
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

