// Creates a simple star configuration with a gear in the center
// and other gears connecting to it arranged around it
class StarMachine {
  Gear centerGear;
  Gear[] outerGears; // These are positioned to be evenly spaced around the center gear, touching it.
  int centerTeeth;  // Number of teeth of the center gear
  int[] outerTeeth; // Number of teeth of the outer gears
  PGraphics pg; // Gears are rendered to this canvas
  
  public StarMachine(int centerTeeth, int[] outerTeeth, PGraphics pg) {
    this.centerTeeth = centerTeeth;
    this.outerTeeth = outerTeeth;
    this.pg = pg;

    // Initialize gears
    centerGear = new Gear(centerTeeth, pg);
    outerGears = new Gear[outerTeeth.length];
    for (int i=0; i<outerGears.length; i++) {
      outerGears[i] = new Gear(outerTeeth[i], pg);
    }
    positionGears();
  }

  public void draw() {
    // Draw central gear
    float baseRotation = 0;
    centerGear.draw(baseRotation);
    for (Gear g: outerGears) {
       float rot = (float) gGearUtils.meshGearRotation(centerGear, g, baseRotation);
      g.draw(rot);
    }
  }

  void positionGears() {
    // Center gear
    Gear cg = centerGear;
    cg.c.x = pg.width/2;
    cg.c.y = pg.height/2;
    
    // Outer gears
    // We position them outside in a star pattern, making them touch
    for (int i=0; i<outerGears.length; i++) {
      Gear g = outerGears[i];
      float angle = 2*PI*i/(outerGears.length);
      float x = (float) (cg.c.x + cos(angle)*(cg.D + g.D));
      float y = (float) (cg.c.y + sin(angle)*(cg.D + g.D));
      gGearUtils.touchGear(cg, g, x, y);
    }
    
  }


}