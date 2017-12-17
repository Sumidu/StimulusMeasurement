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
int studyLength = 100;
Long starttime;
float breaktime = 5;




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

// helper method for threading
void loadData() {
  loadStimuli(studyLength);
  dataLoaded();
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
    drawInstructions(1); 
    break;
  case 2:  
    drawInstructions(2); 
    break;  
  case 5:  
    drawStimulus(trial); 
    break;
  case 10:
    drawbreak();
    break;
  default:
    drawStimulus(trial);
    break;
  }

  if (debug) {
    text("trial:"+trial+" state:"+state+ " ", width/2, height-20);
  }
}


void drawbreak(){
  background(200);
  fill(20);
  textAlign(CENTER);
  text("Short break... please wait.", width/2, height/2);
  fill(255);
  rect(width/2-100, height/2 +20, 200, 20);
  fill(20);
  rect(width/2-100, height/2 +20, breaktime*40, 20);
  breaktime-=1/frameRate;
  if(breaktime<0){
    state=5;
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


void drawStudyOver() {
  background(0);
  fill(255);
  text("The end. Press ESC to quit.", width/2, height/2);
}



void resetBreakTime(){
  breaktime = 5;
}


/**
 ****************+
 Main method for drawing a single stimlus on screen centered
 */
void drawStimulus(int n) {
  if((breaktime > 0) & (n%10==0) ){
    state = 10;
  }
  if (n%10==1){
    resetBreakTime();
  }
  
  background(255);
  if (n>=images.size()|| n<0) { 
    n=0;
  }

  PImage img = images.get(n);
  //place stimulus in upper third
  image(img, width/2-img.width/2 - 30, height*1/2-img.height/2 - 50);

  //place instructions
  image( instructions, width/2-instructions.width/2, height/2+img.height/2-50);
  fill(255);
  rect(width/2-100, 5, 200, 20);
  fill(125);
  rect(width/2-100, 5, ((float)trial/studyLength)*200.0, 20);
}




/*
  Draws *screen* instruction screen
 */
void drawInstructions(int screen) {
  background(255);
  PImage inst = loadImage("data/inst"+screen+".png");
  centerImage(inst);
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
    Long now = System.nanoTime() - starttime;
    // get rating from Keycode 49 = 1, 50=2
    ratings.add(keyCode -48);
    timings.add(now);
    starttime = System.nanoTime();
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
    starttime = System.nanoTime();
    state = 5;
  }
}