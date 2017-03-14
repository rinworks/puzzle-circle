
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
    //return name + " is a " + type + " aged " + age;
    return String.format("%s, name %s, age %d", type, name, age);
  }
}

Animal[] makeAnimals(String typeFile, String nameFile) {
  String[] types = loadStrings(typeFile);
  String[] names = loadStrings(nameFile);
  randomSeed(0);
  ArrayList<Animal> list = new ArrayList<Animal>();
  ArrayList<String> selectedNames = new ArrayList<String>();
  for (String type : types) {
    type = type.trim();
    if (type.length()>1) {
      // viable type; pick random name and age.
      String name = pickRandomName(names, selectedNames);
      selectedNames.add(name);
      int age = (int) random(1, 20);
      Animal a = new Animal(type, name, age);
      list.add(a);
    }
  }

  return list.toArray(new Animal[list.size()]);
}

String pickRandomName(String[] names, ArrayList<String>selectedNames) {
  String newName = null;
  do {
    int ni = (int) random(names.length);
    newName = names[ni];
    newName = newName.trim();
    if (newName.length()< 2 || selectedNames.contains(newName)) {
      newName = null; // Too small or dup
    }
    /*for (String s: selectedNames) {
      if (s.equals(newName)) {
        // Dup.
        newName = null;
        break;
      }
    }*/
  } while (newName == null);
  return newName;
}

void testMakeAnimals() {
  Animal[] arr = makeAnimals("data/animals.txt", "data/raw-names.txt");
  for (int i = 0; i<arr.length; i++) {
    println(i + ": " + arr[i]);
  }
}