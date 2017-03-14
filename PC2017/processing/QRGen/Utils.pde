// Utils - simple utilities used by other classes.
// History:
// Y17M03 - Joseph created.
class Utils {
  // Note - to make this predictable, 
  // set the random seed before calling, using randomSeed()
  public void randomlyPermute(int[] arr) {
    if (arr.length<2) return;
    for (int i=0; i<arr.length-1; i++) {
      swap(arr, i, (int) random(i+1, arr.length));
    }
  }

  void swap(int[] arr, int i, int j) {
    int t = arr[i];
    arr[i] = arr[j];
    arr[j] = t;
  }
  
  // Returns an array of integers from 0 to (n-1)
  int[] range(int n) {
    assert(n>=0);
    int[] arr = new int[n];
    for (int i=0;i<n; i++) {
      arr[i] = i;
    }
    return arr;
  }
  
  // Return a random permutation of [0, (n-1)]
  int[] randomPermutation(int n) {
    assert(n>=0);
    int[] arr = range(n);
    randomlyPermute(arr);
    return arr;
  }
}