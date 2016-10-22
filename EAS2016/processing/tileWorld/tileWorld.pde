// //<>// //<>// //<>//
// Module: tileWorld.PDE
// Description: Main file for Tile World puzzle generator.
//  TileWorld is based on Martyn Lowell's Tile World puzzle for the 2015 Microsoft Puzzle Safari
//
// History:
//	October 2016 - JMJ copied from laser code (uses the GraphicsBase code)
//
// General notes:
//     Grid coordinates: (i, j) are like rows of an array/matrix. So i is vertical,
//     with increasing i going downwards.
//
//import java.util.Comparator;
//import java.util.Arrays;

void setup() {
  size(1300, 1300);
  //println(PFont.list());
  //size(2000, 2000);
  TileHelper helper = new TileHelper();
  Utils gUtils = new Utils();
  Grid g = helper.createGrid(10, 10);
  g.draw();
}