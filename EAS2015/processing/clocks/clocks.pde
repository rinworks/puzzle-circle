

void setup() {
  size(1500, 1500);
  noLoop();
  println(addSemaphoreEscapes("ABC123ABC DEF345 678"));
}

void draw() {
  background(150);
  Time[] times = semaphoreEncode("0123456789");
  drawClocks(times);
  save("output\\output.png");
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

void drawClocks(Time[][] times) {
  int n = times.length;
  int r = width/(3*n);
  int y = height/2;
  for (int i=0; i<n; i++) {
    int x = (int) (2.5*i*r + 2.5*r);
    Time t = times[i][0];
    drawClock(x, y, r, t.hour, t.minute);
  }
}