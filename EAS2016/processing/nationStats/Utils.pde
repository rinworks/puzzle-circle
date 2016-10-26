// Utilities.
// It is a static class so doesn't have access to enclosing classes instance variables and methods (such as size and ellipse)
static class Utils {
   static void assertMsg(boolean test, String msg) {
     if (!test) {
      System.err.println("ASSERTION FAILURE MESSAGE: " + msg);
      assert(false);
    }
  }
}