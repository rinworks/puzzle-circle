/*****************************************************************************
 *
 *  AnimalTiles - Load animal names and types data and render content to make tiles to be used for
 *  sorting and searching exercises.
 *
 *
 *  History: 
 *   Y17M03 JMJ Created
 *
 *****************************************************************************/
import java.util.Collections;
import java.util.Arrays;
import java.util.HashSet;


class Animal {
  public String type;
  public String name;
  public int age;

  public Animal(String t, String n, int a) {
    type = t;
    name = n;
    age = a;
  }

  public String toString() {
    return name + " the " + type + " is " + age + " year" + (age>1 ? "s" : "") + " old.";
    //return String.format("%s, name %s, age %d", type, name, age);
  }
}


// Create {count} animal by reading data from two files:
// {speciesFile} - text file, one species per line.
// {nameFile} - A very large raw list of names
Animal[] makeAnimals(String speciesFile, String nameFile, int count) {

  // Load the data: species data(type and max age), and names
  String[] species = loadStrings(speciesFile);
  String[] names = loadStrings(nameFile);
  randomSeed(0);

  // Select exacly count names in sorted order, out of a larger
  // list of names.
  String[] selectedNames = selectNames(names, count); 
  assert(selectedNames.length == count);
  Animal[] animals = new Animal[count];

  // We are going to assign species to names in a random permutation, but 
  // will loop back  to the start of the random permutation if needed.
  int[] typePermutation = gUtils.randomPermutation(species.length);
  int unpermutedTypeIndex = 0;

  // Generate exactly count animals. Each with a unique name,
  // a type (species), and a randome species-appropriate age.
  for (int i=0; i< count; i++) {
    String name = selectedNames[i];
    String info = species[typePermutation[unpermutedTypeIndex]];
    String type = typeFromInfo(info);
    int maxAge = maxAgeFromInfo(info);
    unpermutedTypeIndex = (unpermutedTypeIndex+1) % species.length; // possible wraparound
    int age = (int) random(1, maxAge+1);
    Animal a = new Animal(type, name, age);
    animals[i] = a;
  }

  return animals;
}


// Carefully select a random selection of {count} names from {names}.
// Names should be randomly spread over all of {names} but they should not be
// "too alike".
String[] selectNames(String[] names, int count) {
  String[] chosenNames = new String[count];
  String[] scrunchedNames = new String[names.length];
  for (int i=0; i<names.length; i++) {
    String s = names[i].toUpperCase().replaceAll("[AEIOUY]", "");
    s = s.replaceAll("H$", "");
    //println(String.format("Name: {0:%s}; Scrunched: {1:%s}", names[i], s));
    scrunchedNames[i] = s;
  }
  //Arrays.sort(scrunchedNames);
  int[] randomIndexes =   gUtils.randomPermutation(names.length);

  // Now we pick up to count "sufficiently different" names in random order.
  HashSet set = new HashSet();
  int outIndex = 0;
  for (int i = 0; i<names.length && outIndex < count; i++) {
    int randInd = randomIndexes[i];
    String scrunched = scrunchedNames[randInd];
    if (!set.contains(scrunched)) {
      // Got a distinct name!
      chosenNames[outIndex] = names[randInd];
      outIndex++;
      set.add(scrunched);
    }
  }
  assert(outIndex == count); // We expect to have enough names to do this!
  Arrays.sort(chosenNames);
  return chosenNames;
}


// Extract the species type from line {info} of species data.
// input examples:
// Gorilla
// Cocroach, 5
String typeFromInfo(String info) {
  int iComma = info.indexOf(',');
  if (iComma >= 0) {
    return info.substring(0, iComma).trim();
  } else {
    return info.trim();
  }
}

// Extract the max age from a line {info} of species data.
// input examples:
// Gorilla
// Cocroach, 5
int maxAgeFromInfo(String info) {
  final int DEFAULT_AGE = 25;
  int iComma = info.indexOf(',');
  if (iComma >= 0) {
    String sAge  = info.substring(iComma+1).trim();
    int age = Integer.parseInt(sAge);
    //println("INPUT: "  + info + "; maxAge: " + age);
    return age;
  } else {
    return DEFAULT_AGE;
  }
}

// Picks a random name from {names}, making sure it doesn't already exist in {selectedNames}.
String pickRandomName(String[] names, ArrayList<String>selectedNames) {
  String newName = null;
  
  do {
    int ni = (int) random(names.length);
    newName = names[ni];
    newName = newName.trim();
    if (newName.length()< 2 || selectedNames.contains(newName)) {
      newName = null; // Too small or dup
    }
  } while (newName == null);
  
  return newName;
}


// Test code
void testMakeAnimals() {
  Animal[] arr = makeAnimals("data/animals.txt", "data/raw-names.txt", 100);
  for (int i = 0; i<arr.length; i++) {
    println(i + ": " + arr[i]);
  }
}