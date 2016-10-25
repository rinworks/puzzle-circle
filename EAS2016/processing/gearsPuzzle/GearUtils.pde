// Utility functions to position and mesh gears.
class GearUtils {
  
  
  // Move gNew to touch gCur with gNew's center as close as possible to (x,y)
  public void touchGear(Gear gCur, Gear gNew, double x, double y) {
    double space = extraGearSpacing(gCur, gNew);
    double d = (gCur.D+gNew.D)/2+space;
    double d1  = gCur.c.distance(x, y);
    gNew.c.x = gCur.c.x + (x-gCur.c.x)*d/d1;
    gNew.c.y = gCur.c.y + (y-gCur.c.y)*d/d1;
  }

  // Return extra spacing (if any) between gears so that they don't bump
  double extraGearSpacing(Gear g1, Gear g2) {
    double dist = Math.min(g1.D, g2.D);
    double scale = 0.02;
    double delta = -dist*scale;
    println("delta: " + delta);
    return delta; // TODO
  }
  
    // Return the rotation amount for newGear to mesh with baseGear
  // when the latter has rotation baseRotation
  double meshGearRotation(Gear baseGear, Gear newGear, double baseRotation) {
    // We're going to find the center of the tooth that is closest to newGear's center.
    // Then position newGear so that the gap between teeth is aligned with this point.
    double r = baseGear.D/2;
    double dMin = 100000;
    double minX = 0;
    double minY = 0;
    for (int i=0;i<baseGear.Z; i++) { 
      double angle = 2*PI*i/baseGear.Z + baseRotation;
      double x = baseGear.c.x + r * Math.cos(angle);
      double y = baseGear.c.y + r * Math.sin(angle);
      double d = newGear.c.distance(x, y);
      if (d<dMin) {
        minX = x;
        minY = y;
        dMin = d;
      }
    }
    // Now find angle to turn newGear to mesh with this point.
    minX -= newGear.c.x;
    minY -= newGear.c.y;
    double rot = Math.acos(minX/dMin);
    rot = minY>0 ? -rot : rot; // acos only returns a value in range [0, PI/2], so we have to look at the y values to get the true value of the angle.
    rot += 0.5*2*Math.PI/newGear.Z; // Shift so the valley, not the tooth, meshes...
      
    //+ 0.5*2*PI/Z;
    return rot;
  }
}