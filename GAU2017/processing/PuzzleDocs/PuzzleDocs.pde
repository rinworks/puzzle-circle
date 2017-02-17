// Module: PuzzleDocs  - program entrypoint
// History:
//  Feb 2017  - JMJ created.

void setup() {
  //size(800, 1024, PDF, "output/out.pdf");
  size(800, 1024);
  runTests();
}

void runTests() {
  String[] mdText = {
    "#502: Relojes IV", 
    "![](data/lasers/lasers-41.png)", 
    "Estos relojes esconden un mensaje. El mensaje es una" +
    " frase corta que lo dirige a usted a calcular un número." +
    " El número es la solución de este rompecabezas. Pista: " +
    " utilice la gráfica del semáforo.", 
    "vvv", 
    "©2015 Joseph Joy (Rinworks, LLC)"
  };
  TextRenderer r = new TextRenderer(new Point(0, 0), width, height);
  r.runTests();
  r.renderMarkdown(mdText);
}