import java.util.*;
Vector<PImage> images;
Vector<Integer> ratings;
Vector<Long> timings;
String user="asdlkjh";

int trial = 0;
int state = 0;
float finished = 0;
int studyLength = 10;
Long starttime;

/**
 Loading Stimuli into Memory
 */
void loadStimuli(int n) {
  println("Loading stimuli");
  images = new Vector<PImage>(n);
  ratings = new Vector<Integer>(n);
  timings = new Vector<Long>(n);
  
  for (int i=0; i<n; i++) {
    finished = (float)i/n;
    String filename = "data/stimulus"+i+".png";
    PImage img = loadImage(filename);
    images.add(img);
  }
}


/**
 Method for drawing a single stimlus on screen centered
 */
void drawStimulus(int n) {
  background(255);
  if (n>=images.size()|| n<0) { 
    n=0;
  }

  PImage img = images.get(n);
  image(img, width/2-img.width/2, height/2-img.height/2);

  drawCommands();
}

void drawInstructions() {
  background(200);
  text("Hallo. Press a key to start", width/2, height/2);
}

void drawCommands() {
}
/*
  Setup Method that loads data in a thread
 */
void setup() {
  //size(900, 900);
  fullScreen();
  startState();
  thread("loadData");
}


void drawStudyOver(){
  background(0);
  fill(255);
  text("The end. Press ESC to quit.", width/2, height/2);
}

/*
  state-dependent DrawMethod
*/

void draw() {
  switch(state) {
  case -1:
    drawStudyOver();
    break;
  case 0: 
    drawLoad();
    break;
  case 1:  
    drawInstructions(); 
    break;
  case 2:  
    drawStimulus(trial); 
    break;
  default:
    drawStimulus(trial);
    break;
  }
  
  text("trial:"+trial+" state:"+state+ " ",width/2,height-20);
}

/*
  Ladebildschirm zeichnen
*/
void drawLoad() {
  background(200);
  fill(20);
  textAlign(CENTER);
  text("Loading... please wait.", width/2, height/2);
  fill(255);
  rect(width/2-100, height/2 +20, 200, 20);
  fill(20);
  rect(width/2-100, height/2 +20, finished*200, 20);
}

void loadData() {
  loadStimuli(studyLength);
  dataLoaded();
}


/*
  State dependent Key-Evaluation
*/
void keyPressed() {
  print(trial);
  switch(state) {
  case -1: 
    break;
  case 0: 
    break;
  case 1: 
    startStudy(); 
    break;
  case 2: 
    keyPressedStudy();
  default: 
    break;
  }
}

/*
  Interaktionslogis für die Studie
 */
void keyPressedStudy() {
  
  if(keyCode == 27) endStudy();
  if(keyCode >48 && keyCode <55){
   Long now = System.currentTimeMillis() - starttime;
   // get rating from Keycode 49 = 1, 50=2
    ratings.add(keyCode -48);
    timings.add(now);
    trial++;
  }
  if (trial > studyLength-1){
    endStudy();
  }
 
}

void startState() {
  state = 0;
}

void dataLoaded() {
  state = 1;
}

void startStudy() {
  starttime = System.currentTimeMillis();
  state = 2;
}

void endStudy() {
 
  //String homeFolder = System.getProperty("user.home");
  //String fullPath = homeFolder + "/Documents/data.csv";
  Table table = new Table();
  table.addColumn("id");
  table.addColumn("user-id");
  table.addColumn("rating");
  table.addColumn("timing");
  for(int i=0; i < ratings.size(); i ++){
    TableRow newRow = table.addRow();
    newRow.setInt("id", table.getRowCount() - 1);
    newRow.setString("user-id", user);
    newRow.setInt("rating", ratings.get(i));
    newRow.setLong("timing", timings.get(i));
  }
  saveTable(table, "test.csv");
  
  state = -1;
}