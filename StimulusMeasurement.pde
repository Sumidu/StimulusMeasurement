import java.util.*;

Vector<PImage> images;
Vector<Integer> ratings;
Vector<Long> timings;

String filename;
String user="UID"+System.currentTimeMillis();
String homeFolder = System.getProperty("user.home");
String fullPath = homeFolder + "/Documents/studydata"+user+".csv";
File f = new File(fullPath);

PImage instructions;

Boolean debug= false;
// trial counter
int trial = 0;

// state-machine
int state = 0;


float finished = 0;
int studyLength = 5;
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

void centerImage(PImage img) {
  image(img, width/2 - img.width/2, height/2- img.height/2);
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
  //place stimulus in upper third
  image(img, width/2-img.width/2 - 30, height*1/2-img.height/2 - 50);

  image( instructions, width/2-instructions.width/2, height/2+img.height/2-50);
  
  fill(255);
  rect(width/2-100, 5, 200, 20);
  fill(125);
  rect(width/2-100, 5, ((float)trial/studyLength)*200.0, 20);
  
  drawCommands();
}

void drawInstructions() {
  background(255);
  PImage inst = loadImage("data/inst1.png");
  centerImage(inst);
}

void drawInstructions2() {
  background(255);
  PImage inst = loadImage("data/inst2.png");
  centerImage(inst);
}



/**
 */
void drawCommands() {
}




/*
  Setup Method that loads data in a thread
 */
void setup() {
  //size(900, 900);
  pixelDensity(displayDensity());
  fullScreen();
  surface.setResizable(true);
  startState();
  instructions = loadImage("data/keys.png");
  thread("loadData");
}


void drawStudyOver() {
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
    drawInstructions2(); 
    break;  
  case 5:  
    drawStimulus(trial); 
    break;
  default:
    drawStimulus(trial);
    break;
  }

  if (debug) {
    text("trial:"+trial+" state:"+state+ " ", width/2, height-20);
  }
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
  // print(trial);
  switch(state) {
  case -1: 
    break;
  case 0: 
    break;
  case 1: 
    nextInst(); 
    break;
  case 2: 
    startStudy(); 
    break;
  case 5: 
    keyPressedStudy();
  default: 
    break;
  }
}

/*
  Interaktionslogis für die Studie
 */
void keyPressedStudy() {

  if (keyCode == 27) endStudy();
  if (keyCode >48 && keyCode <55) {
    Long now = System.currentTimeMillis() - starttime;
    // get rating from Keycode 49 = 1, 50=2
    ratings.add(keyCode -48);
    timings.add(now);
    trial++;
  }
  if (trial > studyLength-1) {
    endStudy();
  }
}

void startState() {
  state = 0;
}


void nextInst() {
  if (keyCode==49) { 
    state = 2;
  }
}

void dataLoaded() {
  state = 1;
}

void startStudy() {
  if (keyCode==53) {
    starttime = System.currentTimeMillis();
    state = 5;
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    selectOutput("Select a file to write to:", "fileSelected", f);
  } else {
    filename = selection.getAbsolutePath();
  }
}

void endStudy() {


  filename = fullPath;
  selectOutput("Select a file to write to:", "fileSelected", f);

  Table table = new Table();
  table.addColumn("id");
  table.addColumn("user-id");
  table.addColumn("rating");
  table.addColumn("timing");
  for (int i=0; i < ratings.size(); i ++) {
    TableRow newRow = table.addRow();
    newRow.setInt("id", table.getRowCount() - 1);
    newRow.setString("user-id", user);
    newRow.setInt("rating", ratings.get(i));
    newRow.setLong("timing", timings.get(i));
  }
  saveTable(table, filename);
  println("Saved to:" + filename);

  state = -1;
}