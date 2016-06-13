
// Orchestrates interactions among rats and cheeses
class Orchestrator {
  Arena a;
  Rat[] rats;
  Cheese[] cheeses;
  boolean ratsDone=false; // true when they are all done and no longer on the field.

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

    if (!this.ratsDone) {

      manageCheeses();
      manageDormantRats();

      this.a.draw();
      fill(black);
      a.displayStatus(0, "Elapsed: " + (millis()/1000));
    } else {     
      // We're all done... stop saving frames if we're saving frames.
      saveFrames = false;
    }
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
    final int MIN_CHEESE_ADDING_INTERVAL = 30;
    final int MAX_CHEESE_ADDING_INTERVAL = 75;
    // TODO: Factor in the number of vacant spaces and the number of mice in deciding what the random interval is going to be...
    int cheeseAddingInterval = (int) random(MIN_CHEESE_ADDING_INTERVAL, MAX_CHEESE_ADDING_INTERVAL); // interval between semi-periodic additions of a cheese.
    if (frameCount % cheeseAddingInterval == 0) {
      int ratsInField = numRatsOnField(); // Rats roaming around the field.
      int numVisibleCheeses = numVisibleCheeses();
      if (ratsInField > numVisibleCheeses) {
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
  }

  void manageDormantRats() {
    final int MIN_RAT_RELEASE_INTERVAL = 10;
    final int MAX_RAT_RELEASE_INTERVAL = 25;
    final int MIN_RATS_IN_FIELD = 2;
    int ratReleaseInterval = (int) random(MIN_RAT_RELEASE_INTERVAL, MAX_RAT_RELEASE_INTERVAL); // interval between semi-periodic release of rats from home.
    if (frameCount % ratReleaseInterval == 0) {
      int ratsInField = numRatsOnField(); // Rats roaming around the field.
      int dormantRats = numDormantRats(); // Rats waiting in the hole, but that still have work to do.
      if (dormantRats > 0 ) {
        // We're below the threshold of rats in the field and we have dormant rats, so release
        // the one with the longest remaining path.
        Rat r = findRatToRelease(ratsInField <  MIN_RATS_IN_FIELD);
        if (r!=null) {
          // Release (unfreeze) it...
          //assert(r.freeze);
          r.freeze=false;
          r.dormantStartMS=0;
        }
      }
      if (ratsInField+dormantRats == 0) {
        this.ratsDone = true; // we're all done
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

  int numVisibleCheeses() {
    int n = 0;
    for (Cheese c : this.cheeses) {
      if (c.visible) {
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

  Rat findRatToRelease(boolean forceRelease) {
    Rat rMax = null;
    Rat rRet = null;
    int nMax = 0;
    int iMax = -1;
    for (int i =0; i<this.rats.length; i++) {
      Rat r = this.rats[i];
      if (r.isDormant()) {
        int n = r.remainingPointCount();
        if (n>nMax) {
          nMax = n;
          rMax = r;
          iMax = i;
        }
      }
    }

    //a.displayStatus(2, "Rat"+(i+1)+"Has new max: " + nMax);

    if (forceRelease) {
      rRet = rMax;
    } else {
      for (Rat r : this.rats) {
        int n = r.remainingPointCount(); // Computed again .. not ideal, but...
        if (dormantDelayExpired(r, nMax-n)) {
          rRet  = r;
          break;
        }
      }
    }

    //println("Rat"+(iMax+1)+"released with points:" + nMax );

    return rRet;
  }

  boolean dormantDelayExpired(Rat r, int remainingPoints) {
    int perPointDelay=1;
    int expiry = r.dormantStartMS  + perPointDelay*remainingPoints;
    return expiry < millis();
  }
}