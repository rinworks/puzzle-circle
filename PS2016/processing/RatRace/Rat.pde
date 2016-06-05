class Rat extends AnimatedObject {
  color c;
  
  Rat(float w, float h, Point[] points, int[] path, color c) {
    super(w, h, points, path);
    this.c = c;
  }

  void draw() {
    if (this.visible) {
      this.move();
      //println(this.w + ", " + this.h);
      stroke(c);
      fill(c);
      ellipse(this.xC, this.yC, this.w, this.h);
    }
  }
  
  void pointCrossed(int point) {
    println("point crossed: " + point);
  }
}