class Rat extends AnimatedObject {
  Rat(float w, float h, Point[] points, int[] path) {
    super(w, h, points, path);
  }
  void draw() {
    if (this.visible) {
      this.move();
      //println(this.w + ", " + this.h);
      ellipse(this.xC, this.yC, this.w, this.h);
    }
  }
}