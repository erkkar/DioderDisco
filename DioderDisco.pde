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
LightThing[] lts = {};

// Sound volume
float level;
float mixLevel;
float levelPart = 0.5;
final float LEVEL_THRESHOLD = 0.005;

boolean follow = true;

// Parameters
FloatDict parameters;
FloatDict status;

boolean preview = false;

int activeLTs;

// Colour settings
final float MAX_HUE = 359;
final float MAX_SATURATION = 1;
final float MAX_BRIGHTNESS = 1;

color masterColor;
float totalR, totalG, totalB;

color WHITE, BLACK, RED, GREEN, BLUE;

final int WIDTH = 500;
final int HEIGHT = 400;
final int MARGIN = 20;
final int TEXT_SIZE = 20;
final int RECT_SIZE = 100;

final String LT_CONFIG = "LTs.cfg";
BufferedReader LTconfig;
final int LTS_CONFIG_LINE_TOKENS = 4;

// Startup parameters
final float SENSITIVITY = 100.0;
final float LEVEL_PART = 0.5;

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
    
  // Set up parameters
  parameters = new FloatDict();
  parameters.set("sensitivity", SENSITIVITY);
  parameters.set("level part", LEVEL_PART);
  
  status = new FloatDict();
  
  size(WIDTH, HEIGHT, P2D);
  
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
  beat.setSensitivity((int) parameters.get("sensitivity"));
  
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, in);  
  
  // Init Dioder driver
  driver = new DioderDriver(this);
   
  //=================================
  // Init LightThings
  readLTconfig(LT_CONFIG);

  //=================================
  
}
// end of setup

// draw
void draw()
{ 
  
  background(0.5);
  
  fill(WHITE);
  textSize(TEXT_SIZE);
  printSomeValues(MARGIN, MARGIN, 
                  parameters.keyArray(), nf(parameters.valueArray(), 1, 1));
  printThings();
  
  //Print preview
  if (preview) drawPreview();
  
  // Get sound level
  status.set("level", in.mix.level());
  level = status.get("level") * parameters.get("level part") 
          + (1 - parameters.get("level part"));
  
  if (follow) {
      
    // Update lights
    for (LightThing lt : lts) {
      if ( status.get("level") > LEVEL_THRESHOLD ) {
        lt.beat(level);
      } else { lt.fade(); }  
    }
    
    // Mix master color
    totalR = 0; totalG = 0; totalB = 0; activeLTs = 0;
    for (LightThing lt : lts) {
      if (lt.enabled) {
        activeLTs++; 
        float[] rgb = lt.getRGB();
        totalR = totalR + rgb[0];
        totalG = totalG + rgb[1];
        totalB = totalB + rgb[2];
      }
    }
    totalR = totalR / activeLTs;
    totalG = totalG / activeLTs;
    totalB = totalB / activeLTs;
    colorMode(RGB);
    masterColor = color(totalR, totalG, totalB);
  }
  
  // DioderDriver
  driver.r = int(totalR);
  driver.g = int(totalG);
  driver.b = int(totalB);
  driver.update();
  
  // Print status
  printSomeValues(MARGIN, (int) height/2, 
                  status.keyArray(), nf(status.valueArray(), 1, 3));
}
// end of draw


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
    parameters.mult("sensitivity",2);
    beat.setSensitivity((int) parameters.get("sensitivity"));
  }
  if (key == 98) {  //b
    parameters.div("sensitivity",2);
    beat.setSensitivity((int) parameters.get("sensitivity")); 
  }
  if (key == 97) {  //a
  }
  if (key == 122) { //z
    parameters.set("level part", constrain(parameters.get("level part") - 0.1, 0, 1));
  }
  if (key == 120) { //x
    parameters.set("level part", constrain(parameters.get("level part") + 0.1, 0, 1));
  } 
  
  // Switch LightThings on/off
  if (key == 48) { //0
      for (LightThing lt : lts) { 
        lt.enabled = true;
      }
  }
  if (key == 43) { //0
      for (LightThing lt : lts) { 
        lt.enabled = false;
      }
  }
  if (key >= 49 && key <= 57) {
    try {
        lts[key - 49].flip();
    } catch (ArrayIndexOutOfBoundsException e) {}
  }
  if (key == 112) { //p
    preview = !preview;
  }
}


// keyReleased
void keyReleased() { 
  if (key != 8) follow = true;
}


// printSomeValues
void printSomeValues(int x, int y, String[] keys, String[] values) {
  
  int COLUMN_WIDTH = 150; 
  
  fill(WHITE);
  textAlign(LEFT);
  
  for (int i = 0; i < keys.length; i++) {
    text(keys[i] + ": ", x, y + i * 1.2 * TEXT_SIZE);
    text(values[i], x + COLUMN_WIDTH, y + i * 1.2 * TEXT_SIZE);
  }
}


// printThings
void printThings() {
  
  int COLUM_WIDTH = 200;
  
  textAlign(LEFT);
  for (int i = 0; i < lts.length; i++) {
    if (lts[i].enabled) { 
      fill(lts[i].getOrigColor());
      text(nf(i + 1,1,0) + ": " + lts[i].comment, 
              width - COLUM_WIDTH, MARGIN + i * 1.1 * TEXT_SIZE);
    }
  }
}

void readLTconfig(String filename) {
  lts = new LightThing[0];
  LTconfig = createReader(filename);
  String line;
  String[] config = {};
  while (true) {
    try {
      line = LTconfig.readLine();
    } catch (IOException e) {
      line = null;
      break;
    }
    if (line == null || line.equals("")) break;
    
    config = splitTokens(line);
    // Check correct length
    if (config.length != LTS_CONFIG_LINE_TOKENS) continue; 
    
    switch(config[1].charAt(0)) {
      case 'k':
        lts = (LightThing[]) append(lts, new KickThing(config[0], float(config[2]), float(config[3])));
        break;
      case 's':
        lts = (LightThing[]) append(lts, new SnareThing(config[0], float(config[2]), float(config[3])));
        break;
      case 'h':
        lts = (LightThing[]) append(lts, new HatThing(config[0], float(config[2]), float(config[3])));
        break;
    }
  }
  
  println("Total Light Things read: " + lts.length);
  
}

// drawPreview
// Draws a colour preview on screen
void drawPreview() {
  fill(masterColor);
  rect(width - RECT_SIZE, height - RECT_SIZE, RECT_SIZE, RECT_SIZE);
}
  
  


// stop
//void stop()
//{
//  print("Shutting down . . . ");
//  
//  // Switch lights off
//  driver.update(BLACK);
//  
//  // always close Minim audio classes when you are finished with them
//  in.close();
//  // always stop Minim before exiting
//  minim.stop();
//  // this closes the sketch
//  super.stop();
//  
//  print("done. Goodbye!");
//}
