/**
Dioder Disco
  */

import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.serial.*;
import themidibus.*;

Minim        minim;
//AudioPlayer  in;
AudioInput   in;
BeatDetect   beat;
BeatListener bl;
DioderDriver driver;

BeatSet beatLights;
EffectSet effects;

// Sound volume
float level;
float mixLevel;
float levelPart = 0.5;
final float LEVEL_THRESHOLD = 0.005;

boolean follow = true;

// Parameters
FloatDict parameters;
FloatDict status;

boolean preview = true;

int activeLTs;

// Colour settings
final int MAX_HUE = 359;
final float MAX_SATURATION = 1;
final float MAX_BRIGHTNESS = 1;

color masterColor;
float[] masterRGB;

color WHITE, BLACK, RED, GREEN, BLUE;
float[] BLACK_RGB = {0, 0, 0};

final int WIDTH = 500;
final int HEIGHT = 400;
final int MARGIN = 20;
final int TEXT_SIZE = 20;
final int RECT_SIZE = 100;

final String LT_CONFIG = "LTs.cfg";
final int LTS_CONFIG_LINE_TOKENS = 4;

// Startup parameters
final float SENSITIVITY = 100.0;
final float LEVEL_PART = 0.5;
final float EFFECT_FADER = 0.9;

MidiBus midiBus; // The MidiBus

// setup
void setup()
{
  colorMode(RGB, 255);
  
  // Define static colors
  WHITE = color(255, 255, 255);
  BLACK = color(0, 0, 0);
  RED = color(255, 0, 0);
  GREEN = color(0, 255, 0);
  BLUE = color(0, 0, 255);
  
  masterColor = BLACK;
  masterRGB = BLACK_RGB;
    
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
  beatLights = new BeatSet();
  beatLights.readConfig(LT_CONFIG);
  
  effects = new EffectSet(MAX_HUE + 1);
  
  //=================================
  
  midiBus = new MidiBus(this, 0, -1);
  
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
  printThings(beatLights.theSet, MARGIN);
  printThings(effects.theSet, MARGIN + 10 * TEXT_SIZE);
  
  //Print preview
  if (preview) drawPreview();
  
  // Get sound level
  status.set("level", in.mix.level());
  level = status.get("level") * parameters.get("level part") 
          + (1 - parameters.get("level part"));
  
  if (effects.enabled) {
    masterRGB = effects.mixRGB();
  } else if (follow && beatLights.enabled) {
    // Update lights
    beatLights.update(status.get("level"));
    // Mix master color
    masterRGB = beatLights.mixRGB();
  } else {
    masterRGB = BLACK_RGB;
  }
  colorMode(RGB, 255);
  masterColor = color(masterRGB[0], masterRGB[1], masterRGB[2]);
    
  // Fade & clean effects
  effects.fadeAll();
  effects.clean();
  
  // DioderDriver
  driver.r = int(masterRGB[0]);
  driver.g = int(masterRGB[1]);
  driver.b = int(masterRGB[2]);
  driver.update();
  
  // Print status
  printSomeValues(MARGIN, (int) height/2, 
                  status.keyArray(), nf(status.valueArray(), 1, 3));
                  
  text("Follow: "+follow, MARGIN, height - MARGIN - 3.3*TEXT_SIZE);                
  text("Beats: "+beatLights.enabled, MARGIN, height - MARGIN - 2.2*TEXT_SIZE);
  text("Effects: "+effects.enabled, MARGIN, height - MARGIN - TEXT_SIZE);
  status.set("effects",effects.howMany);
}
// end of draw


// keyPressed
void keyPressed() {
  
  // --------------------------------
  // Light effects
  
  if (key == 44) { //,
      effects.create(0, EFFECT_FADER);
  }
  if (key == 46) { //.
      effects.create(120, EFFECT_FADER);
  }
  if (key == 45) { //-
      effects.create(240, EFFECT_FADER);
  }
  
  // --------------------------------
  
  if (key == 8) { // Backsapce
    if (follow) {
      follow = false;
    } else { 
      follow = true;
    }
  }
  if (key == 10) { // Enter
  //    follow = false;
  //    masterColor = WHITE;
  }       
  // Re-read light configuration
  if (key == 114) {  //r
    beatLights.readConfig(LT_CONFIG);
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
      beatLights.enableAll();
  }
  if (key == 43) { //0
    beatLights.disableAll();
  }
  if (key >= 49 && key <= 57) {
    beatLights.flip(key - 49);
  }
  if (key == 112) { //p
    preview = !preview;
  }
}


// keyReleased
void keyReleased() { 
  
  if (key != 8) follow = true;
  
  //-----------------------------
  // Light effects
  if (key == 44) { //,
      effects.disable(0);
  }
  if (key == 46) { //.
      effects.disable(120);
  }
  if (key == 45) { //-
      effects.disable(240);
  }
  //-----------------------------
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
void printThings(LightThing[] lts, int yPos) {
  
  int COLUM_WIDTH = 200;
  float LINESPREAD = 1.1;
  
  textAlign(LEFT);
  
  int i = 0;
  
  for (LightThing lt : lts) {
    if (lt != null && lt.enabled) { 
      fill(lt.getOrigColor());
      text(nf(i + 1,1,0) + ": " + lt.comment, width - COLUM_WIDTH, yPos);
      yPos = int(yPos + LINESPREAD * TEXT_SIZE);
    }
    i++;
  }
}



// drawPreview
// Draws a colour preview on screen
void drawPreview() {
  fill(masterColor);
  rect(width - RECT_SIZE, height - RECT_SIZE, RECT_SIZE, RECT_SIZE);
} 

// ------------------------------------------------------------------------
// MIDI Control
void noteOn(int channel, int pitch, int velocity) {
  print("Pitch: " + pitch + "  Velocity: " + velocity + "\n");
  float  hue = note2hue(pitch);
  print("Hue: " + hue + "\n");
  effects.create(int(hue), EFFECT_FADER);
}

void noteOff(int channel, int pitch, int velocity) {
  effects.disable(int(note2hue(pitch)));
}

float note2hue(int pitch) {
  return float(pitch) / 24 * MAX_HUE;
}

  
// ------------------------------------------------------------------------  


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
