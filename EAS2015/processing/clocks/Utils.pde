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
  println("DEGREES:" + hourAngleDegrees);
  float fraction  = 8*hourAngleDegrees/360;
  println("FRACTION:" + fraction);
  float delta = fraction - round(fraction);
    println("DELTA:" + delta);
   float newDelta = delta/3;
   hourAngleDegrees = (round(fraction)+delta)*360/8;
    println("MODDED DEGREES:" + hourAngleDegrees);
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
  ellipse(0,0, 0.1*r, 0.1*r);
  fill(128);
  noStroke();
  ellipse(0,0, 0.07*r, 0.07*r);
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