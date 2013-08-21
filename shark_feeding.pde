PImage backgroundImage;

ArrayList allSharks;
int numberOfSharks;

ArrayList allTuna;
int numberOfTuna;

int smallestMealSize;

void setup() {
  size( 1200, 700 );
  smooth();
  
  backgroundImage = loadImage("aquarium.png");
  
  numberOfSharks = 3;
  numberOfTuna = 75;
  
  smallestMealSize = 3;

  allSharks = new ArrayList();
  allTuna = new ArrayList();
  
  for (int i = 0; i < numberOfSharks; i++) {
    Shark shark = new Shark( random(width), random(height) );
    shark.velocity.x = random(-5, 5);
    shark.velocity.y = random(-5, 5);
    allSharks.add( shark );
  }
    
  for (int i = 0; i < numberOfTuna; i++) {
    Tuna tuna = new Tuna( random(width), random(height) );
    tuna.velocity.x = random(-1, 1);
    tuna.velocity.y = random(-1, 1);
    allTuna.add( tuna );
  }
}

void draw() {
  background(backgroundImage); 
  
  processAndRenderSharks();
  processAndRenderTuna();
  
  purgeDeadTuna();
  scaleSmallestMealSize();
}

void processAndRenderSharks() {
 for (int i = 0; i < allSharks.size(); i++) {
    Shark shark = (Shark)allSharks.get(i);
    shark.checkState();
    shark.process();
    shark.render();
  } 
}

void processAndRenderTuna() {
 resetTunaInfluence();
 for (int i = 0; i < allTuna.size(); i++) {
    Tuna tuna = (Tuna)allTuna.get(i);
    tuna.process();
    tuna.render();
  } 
}

void resetTunaInfluence() {
 for (int i = 0; i < allTuna.size(); i++) {
    Tuna tuna = (Tuna)allTuna.get(i);
    tuna.flockInfluence = 0;
  } 
}

void purgeDeadTuna() {
 for (int i = 0; i < allTuna.size(); i++) {
    Tuna tuna = (Tuna)allTuna.get(i);
    if (!tuna.isAlive) {
      allTuna.remove(i);
    }
 }
}

void scaleSmallestMealSize() {
 if (allTuna.size() < 10) {
    smallestMealSize = 0;
  }
  else if (allTuna.size() < 15) {
    smallestMealSize = 1;
  }
  else if (allTuna.size() < 30) {
    smallestMealSize = 2;
  } 
}
