
// Orchestrates interactions among rats and cheeses
class Orchestrator {
  Arena a;
  Rat[] rats;
  Cheese[] cheeses;

  Orchestrator(Arena a, Rat[] rats, Cheese[] cheeses) {
    this.a = a;
    this.rats = rats;
    this.cheeses = cheeses;
  }

  void start() {

    for (Rat r : rats) {
      r.start();
    }
  }

  void draw() {

    manageCheeses();

    this.a.draw();
  }

  // Return cheese present at the current point, null otherwise.
  Cheese tryGetCheeseAtPoint(int point) {
    for (Cheese c : this.cheeses) {
      if (c.point == point) {
        return c; // EARLY RETURN
      }
    }
    return null;
  }

  void manageCheeses() {
    final int MIN_CHEESE_ADDING_INTERVAL = 100;
    final int MAX_CHEESE_ADDING_INTERVAL = 300;
    // TODO: Factor in the number of vacant spaces and the number of mice in deciding what the random interval is going to be...
    int cheeseAddingInterval = (int) random(MIN_CHEESE_ADDING_INTERVAL, MAX_CHEESE_ADDING_INTERVAL); // interval between semi-periodic additions of a cheese.
    if (frameCount % cheeseAddingInterval == 0) {
      // Pick a random start offset and then run down from that (with wraparound) until you find an empty spot. 
      int offset = (int) random(0, cheeses.length);
      for (int i=0; i< this.cheeses.length; i++) {
        int j = (i + offset) % cheeses.length; 
        Cheese c = this.cheeses[j];
        if (!c.visible) {
          c.start();
          break;
        }
      }
    }
  }

  void manageDormantRats() {
    final int MIN_RAT_RELEASE_INTERVAL = 100;
    final int MAX_RAT_RELEASE_INTERVAL = 300;
    final int MIN_RATS_IN_FIELD = 3;
    int ratReleaseInterval = (int) random(MIN_RAT_RELEASE_INTERVAL, MAX_RAT_RELEASE_INTERVAL); // interval between semi-periodic release of rats from home.
    if (frameCount % ratReleaseInterval == 0) {
      int ratsInField = numRatsOnField(); // Rats roaming around the field.
      int dormantRats = numDormantRats(); // Rats waiting in the hole, but that still have work to do.
      if (dormantRats > 0 && ratsInField <  MIN_RATS_IN_FIELD) {
        // We're below the threshold of rats in the field and we have dormant rats, so release
        // the one with the longest remaining path.
        Rat r = findRatToRelease();
        assert(r!=null);
        // Release (unfreeze) it...
        assert(r.freeze);
        r.freeze=false;
      }
    }
  }

  int numRatsOnField() {
    int n = 0;
    for (Rat r : this.rats) {
      if (r.onField()) {
        n++;
      }
    }
    return n;
  }

  int numDormantRats() {
    int n = 0;
    for (Rat r : this.rats) {
      if (r.isDormant()) {
        n++;
      }
    }
    return n;
  }

  Rat findRatToRelease() {
    Rat rMax = null;
    int nMax = 0;
    for (Rat r : this.rats) {
      if (r.isDormant()) {
        int n = r.remainingPointCount();
        if (n>nMax) {
          nMax = n;
          rMax = r;
        }
      }
    }
    return rMax;
  }
}