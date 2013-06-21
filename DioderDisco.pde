/**
Dioder Disco
  */

import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.serial.*;

Minim        minim;
//AudioPlayer  in;
AudioInput   in;
BeatDetect   beat;
BeatListener bl;
DioderDriver driver;
LightThing[] lts;

// Sound volume
float level;
float levelPart = 0.5;

boolean follow = true;

static int MAX_LIGHT_THINGS = 9;
int lightThings;

int PARAMETERS = 1;

int activeLTs;

color masterColor;
float totalR, totalG, totalB;

static color WHITE, BLACK, RED, GREEN, BLUE;

String[] parameters;
float[] values;

static int WIDTH = 400;
static int HEIGHT = 400;
static int MARGIN = 20;
static int TEXT_SIZE = 20;
static int RECT_SIZE = 100;

String LT_CONFIG = "LTs.cfg";
BufferedReader LTconfig;


// setup
void setup()
{
  colorMode(RGB);
  
  // Define static colors
  WHITE = color(255, 255, 255);
  BLACK = color(0, 0, 0);
  RED = color(255, 0, 0);
  GREEN = color(0, 255, 0);
  BLUE = color(0, 0, 255);
  
  masterColor = BLACK;
  
  size(400,400);
  
  minim = new Minim(this);
  
  in = minim.getLineIn();
  //in = minim.loadFile("sample.mp3");
  //in.loop();
  
  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  
  // set the sensitivity to 300 milliseconds
  // After a beat has been detected, the algorithm will wait for 300 milliseconds 
  // before allowing another beat to be reported. You can use this to dampen the 
  // algorithm if it is giving too many false-positives. The default value is 10, 
  // which is essentially no damping. If you try to set the sensitivity to a negative value, 
  // an error will be reported and it will be set to 10 instead. 
  beat.setSensitivity(10);  
  
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, in);  
  
  // Init Dioder driver
  driver = new DioderDriver(this);
  
  parameters = new String[PARAMETERS];
  values = new float[PARAMETERS];
  
  //=================================
  // Init LightThings
  lts = new LightThing[MAX_LIGHT_THINGS];
  
  for (int i = 0; i < MAX_LIGHT_THINGS; i++) {
    lts[i] = new LightThing(false);
  }
  
  readLTconfig(LT_CONFIG);

  //=================================
}


// draw
void draw()
{ 
  background(0.5);
  
  fill(WHITE);
  textSize(TEXT_SIZE);
  printParameters();
  printThings();
  
  fill(masterColor);
  rect(WIDTH-RECT_SIZE,HEIGHT-RECT_SIZE,RECT_SIZE,RECT_SIZE);
  
  if (follow) {
  
    // Get sound level
    level = in.mix.level() * levelPart + (1 - levelPart);
    //level = 1;
    
    // Check beats
    for (int i = 0; i < lightThings; i++) {
      lts[i].update(level);
    }
    
    // Mix master color
    totalR = 0; totalG = 0; totalB = 0; activeLTs = 0;
    for (int i = 0; i < lightThings; i++) {
      if (lts[i].enabled) {
        activeLTs++; 
        totalR = totalR + lts[i].r;
        totalG = totalG + lts[i].g;
        totalB = totalB + lts[i].b;
      }
    }
    totalR = totalR / activeLTs;
    totalG = totalG / activeLTs;
    totalB = totalB / activeLTs;  
    masterColor = color(totalR, totalG, totalB);
  }
  
  // DioderDriver
  driver.update(masterColor);
}


// keyPressed
void keyPressed() {
  
  if (key == 44) { //,
      follow = false;
      masterColor = RED;
  }
  if (key == 46) { //.
      follow = false;
      masterColor = GREEN;
  }
  if (key == 45) { //-
      follow = false;
      masterColor = BLUE;
  }
  if (key == 8) { // Backsapce
    if (follow) {
      follow = false;
      masterColor = BLACK;
    } else { 
      follow = true;
    }
  }
  if (key == 10) { // Enter
      follow = false;
      masterColor = WHITE;
  }       
  // Re-read light configuration
  if (key == 114) {  //r
    readLTconfig(LT_CONFIG);
  }
  if (key == 103) {  //g
  }
  if (key == 98) {  //b
  }
  if (key == 97) {  //a
  }
  if (key == 122) { //z
    if(levelPart > 0.1) levelPart = levelPart - 0.1;
  }
  if (key == 120) { //x
    if(levelPart < 1.0) levelPart = levelPart + 0.1;
  } 
  
  // Switch LightThings on/off
  if (key == 48) { //0
      for (LightThing lt : lts) { 
        lt.enabled = true;
      }
  }
  if (key == 49) { //1
      lts[0].flip();
  }
  if (key == 50) { //2
      lts[1].flip();
  }
  if (key == 51) { //3
      lts[2].flip();
  }
  if (key == 52) { //4
      lts[3].flip();
  }
  if (key == 53) { //5
      lts[4].flip();
  }
  if (key == 54) { //6
      lts[5].flip();
  }
  if (key == 55) { //7
      lts[6].flip();
  }
  if (key == 56) { //8
      lts[7].flip();
  }
  if (key == 57) { //9
      lts[8].flip();
  }
}


// keyReleased
void keyReleased() { 
  if (key != 8) follow = true;
}


// printParameters
void printParameters() {
  fill(WHITE);
  textAlign(LEFT);
  
  parameters[0] = "Level";
  values[0] = levelPart;
  
  for (int i = 0; i < PARAMETERS; i++) {
    text(parameters[i] + ": ", MARGIN, MARGIN + i * 1.1 * TEXT_SIZE);
    text(values[i], 100, MARGIN + i * TEXT_SIZE);
  }
}


// printThings
void printThings() {
  textAlign(LEFT);
  for (int i = 0; i < lightThings; i++) {
    if (lts[i].enabled) { 
      fill(lts[i].getOrigColor());
      text(nf(i + 1,1,0) + ": " + lts[i].comment, WIDTH / 2, MARGIN + i * 1.1 * TEXT_SIZE);
    }
  }
}

void readLTconfig(String filename) {
  LTconfig = createReader(filename);
  String line;
  String[] config = new String[6];
  for (int i = 0; i < MAX_LIGHT_THINGS; i++) {
    try {
      line = LTconfig.readLine();
    } catch (IOException e) {
      e.printStackTrace();
      line = null;
      break;
    }
    if (line.equals("")) break;
    
    config = splitTokens(line);
    println(i);
    switch(config[1].charAt(0)) {
      case 'k':
        lts[i] = new KickThing();
        break;
      case 's':
        lts[i] = new SnareThing();
        break;
      case 'h':
        lts[i] = new HatThing();
        break;
    }
    
    lts[i].comment = config[0];
    lts[i].fader = float(config[2]);
    lts[i].setColor(int(config[3]), int(config[4]), int(config[5]));
    
    lightThings = i + 1;
  }
  
}
  


// stop
void stop()
{
  // Switch lights off
  driver.update(BLACK);
  
  // always close Minim audio classes when you are finished with them
  in.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}
