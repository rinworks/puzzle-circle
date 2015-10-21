final int red = color(250, 32, 32);
final int green = color(32, 250, 32);
final int blue = color(64, 64, 250);
final int body = 175;

void setup() {
  noLoop();
  smooth();
  noStroke();
  size(1500, 900);
  background(255);

  /*pushMatrix();
   //translate(200, 200);
   fill(255, 0, 0);
   drawMountain(200, 200, 50, 25,90);
   fill(0,255,0);
   drawValley(200, 175, 50, 25,-90);
   fill(0);
   ellipse(200, 200, 10, 10);
   popMatrix();*/

  drawHalfC(50, 300);
  drawI(300, 300);
  drawL(450, 300);
  drawATop(650, 300);
  
  drawABottom(50, 600);
  drawDiag(350,600);
  drawPlus(650, 600);
  drawBar(900,600);
}

void drawATop(int x, int y) {
  int h=150;
  int w=150;
  int t=60;
  fill(body);
  beginShape();
  vertex(x, y);
  vertex(x+w/2-0.5*t, y-h);
  vertex(x+w/2+0.5*t, y-h);
  vertex(x+w, y);
  vertex(x+w-t, y);
  vertex(x+w/2, y-h+1.5*t); // tip of v
  vertex(x+t, y);
  endShape();
  fill(blue);
  drawValley(x+t/2, y, t, t/2, -90);
  drawMountain(x+w-t/2, y, t, t/2, -90);
  fill(green);
  drawMountain(x+w/2, y-h, t, t/2, 90);
}

void drawABottom(int x, int y) {
  int h=150;
  int w=240;
  int wTop=150;
  int t=60;
  fill(body);
  beginShape();
  vertex(x, y);
  vertex(x+w/2-0.5*wTop, y-h);
  vertex(x+w/2+0.5*wTop, y-h);
  vertex(x+w, y);
  vertex(x+w-t, y);
  vertex(x+w/2+w/7, y-h+t); // tip of v
  vertex(x+w/2-w/7, y-h+t); // tip of v
  vertex(x+t, y);
  endShape();
  fill(blue);
  drawMountain(x+w/2-wTop/2+t/2, y-h, t, t/2, 90);
  drawValley(x+w/2+wTop/2-t/2,y-h, t, t/2, 90);

}

void drawDiag(int x, int y) {
  int h=250;
  int w=200;
  int t=60;
  int tx=t/4;
  int ty=t;
  fill(body);
  beginShape();
  vertex(x, y);
  vertex(x,y-t  -ty);
  vertex(x+w-tx, y-h+t);
  vertex(x+w-tx, y-h);
  vertex(x+w, y-h);
  vertex(x+w, y-h+t+ty);
  vertex(x+tx,y-t);
  vertex(x+tx, y);
  endShape();
  fill(green);
  drawMountain(x+tx,y-t/2, t, t/2, 0);
  drawMountain(x+w-tx,y-h+t/2, t, t/2, 180);

}


void drawL(int x, int y) {
  int h=200;
  int t=60;
  fill(body);
  rect(x, y-h, t, h);
  rect(x, y-t, h/2, t);
  //fill(255,0,0);
  fill(blue);
  drawValley(x+h/2, y-t/2, t, t/2, 0);
}

void drawPlus(int x, int y) {
  int h=200;
  int t=60;
  fill(body);
  rect(x+h/2-t/2, y-h, t, h);
  rect(x, y-h/2-t/2, h, t);
  fill(green);
  drawValley(x+h/2, y, t, t/2, -90);
  drawValley(x+h/2, y-h, t, t/2, 90);
  fill(red);
    drawValley(x, y-h/2, t, t/2, 180);
  drawValley(x+h, y-h/2, t, t/2, 0);
}

void drawBar(int x, int y) {
  int t=60;
  int w=2*t;
  int dy = t/4;
  fill(body);
  rect(x, y-dy, w, dy);
  fill(blue);
  drawValley(x+t/2, y-dy, t, t/2,90);
  drawMountain(x+t+t/2, y-dy, t, t/2, 90);
}

void drawI(int x, int y) {
  int h=200;
  int t=60;
  fill(body);
  rect(x, y-h, t, h);
  fill(green);
  drawValley(x+t/2, y, t, t/2, -90);
}

void drawHalfC(int x, int y) {
  int h=150;
  int w=150;
  int t=60;
  int dy=3*h;
  int dx=3*w;
  fill(body);
  beginShape();
  curveVertex(x+w, y-h+dy); // guide
  curveVertex(x, y);
  curveVertex(x+w, y-h);
  curveVertex(x+w+dx, y); // guide
  vertex(x+w, y-h+t);
  curveVertex(x+t+w+0.75*dx, y); // guide
  curveVertex(x+w, y-h+t);
  curveVertex(x+t, y);
  curveVertex(x+w, y-h+0.75*dy+t); // guide
  endShape();
  fill(red);
  drawValley(x+t/2, y, t, t/2, -90);
  drawMountain(x+w, y-h+t/2, t, t/2, 0);
}

// draws a mountain with center of the base at the specified location and the top pointing towards the specified angle.
void drawMountain(float x, float y, float b, float h, float angle) {
  pushMatrix();
  translate(x, y);
  rotate(radians(-angle+90));
  triangle(-b/2, 0, 0, -h, 0+b/2, 0);
  popMatrix();
}

// draws a valley with center of the base at the specified location and the top pointing towards the specified angle.
void drawValley(float x, float y, float b, float h, float angle) {
  pushMatrix();
  translate(x, y);
  rotate(radians(-angle+90));
  triangle(-b/2, 0, -b/2, -h, 0, 0);
  triangle(0, 0, b/2, -h, b/2, 0);
  popMatrix();
}

