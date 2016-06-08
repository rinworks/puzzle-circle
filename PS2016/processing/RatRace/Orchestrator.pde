
// Orchestrates interactions among rats and cheeses
class Orchestrator {
  Arena a;
  Rat[] rats;
  Cheese[] cheeses;
  final int INTERVAL = 100;

  Orchestrator(Arena a, Rat[] rats, Cheese[] cheeses) {
    this.a = a;
    this.rats = rats;
    this.cheeses = cheeses;
  }

  void start() {
    for (Cheese c : cheeses) {
      c.start();
    }

    for (Rat r : rats) {
      r.start();
    }
  }

  void draw() {
    if (frameCount % INTERVAL == 0) {
      periodicTimerHandler();
    }
    this.a.draw();
  }

  void periodicTimerHandler() {
    //println("******* TIMER *****");
    manageCheeses();
  }

  void manageCheeses() {

    // Go through cheeses and selectively stop/start them.
    for (Cheese c : this.cheeses) {
      if ((int) random(1, this.cheeses.length) < 2) {
        if (c.visible) {
          c.stop();
        } else {
          c.start();
        }
      }
    }
  }
}