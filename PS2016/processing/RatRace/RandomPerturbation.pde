class RandomPerturbation {
  float a;
  float c;
  float s;
  float x;
  float y;
  
  // a=amplititude, c=constant, s=scale(e.g, 0.02, higher values result in higher frequency noise)
  RandomPerturbation(float a, float c, float s) {
    this.a = a;
    this.c = c;
    this.s = s;
    x=random(1000); // find a random point in noise space to start.
  }
  
  float nextValue() {
    x += s;
    return a*(noise(x)-0.5) + c; // noise() is always between 0 and 1.
  }
}