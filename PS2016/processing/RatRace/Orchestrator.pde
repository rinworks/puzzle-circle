
// Orchestrates interactions among rats and cheeses
class Orchestrator {
  Arena a;
  Rat[] rats;
  Cheese[] cheeses;
  int cheeseAddingInterval; // interval between semi-periodic additions of a cheese.


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



  void manageCheeses() {
    final int MIN_CHEESE_ADDING_INTERVAL = 100;
    final int MAX_CHEESE_ADDING_INTERVAL = 300;
    // TODO: Factor in the number of vacant spaces and the number of mice in deciding what the random interval is going to be...
    cheeseAddingInterval = (int) random(MIN_CHEESE_ADDING_INTERVAL, MAX_CHEESE_ADDING_INTERVAL);

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
}
}