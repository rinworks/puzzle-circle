void drawStation(Point p, String trains) {
  //System.out.println("DS: "+p.toString()+trains);
  fill(255);
  stroke(0);
  strokeWeight(3);
  ellipse(p.x, p.y, 45, 45);
  fill(0);
  textSize(16);
  textLeading(16);
  textAlign(CENTER, CENTER);
  text(trains, p.x, p.y-3, 50, 50);
}
void drawLink(Point p1, Point p2) {
  //System.out.println("DL: "+p1.toString()+","+p2.toString());
  noFill();
  strokeWeight(10);
  stroke(128);
  beginShape();
  curveVertex(p1.x-200, p2.y); // control pt
  curveVertex(p1.x, p1.y);
  curveVertex(p2.x, p2.y);
  curveVertex(p2.x+200, p1.y); // control pt
  endShape();
}

void drawLoop(Point p1, Point p2) {
  //System.out.println("DL: "+p1.toString()+","+p2.toString());
  noFill();
  int x1 = Math.max(p1.x, p2.x);
  drawLink(p1, new Point(x1, p1.y));
  strokeWeight(10);
  beginShape();
  curveVertex(x1-400, p2.y); // control pt
  curveVertex(x1, p1.y);
  curveVertex(p2.x, p2.y);
  curveVertex(x1-400, p1.y); // control pt
  endShape();
}


// returns fraction of distance from p1 to p2. 
Point lerpPoint(Point p1, Point p2, float frac) {
  return new Point((int)(p1.x+(p2.x-p1.x)*frac), (int)(p1.y + (p2.y-p1.y)*frac));
}

void drawBridge(Point p, float angle) {
  pushMatrix();
  translate(p.x, p.y);
  rotate(-angle);
  stroke(0);
  strokeWeight(5);
  line(-9, 8, 13, 8);
  line(-9, -4, 13, -4);
  popMatrix();
  fill(0);
  textSize(12);;
  textAlign(CENTER, CENTER);
  text("bridge", p.x+40, p.y, 50, 50);
  
}



