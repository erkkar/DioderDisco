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

BeatSet[] beatSets;
BeatSet beatLights;
EffectSet effects;

// Sound volume
float level;
float mixLevel;
float levelPart = 0.5;
final float LEVEL_THRESHOLD = 0.005;


// Parameters
FloatDict parameters;
FloatDict status;

final int DECIMALS = 2;

boolean preview = true;

int activeLTs;

// Colour settings
final int MAX_HUE = 360;
final float MAX_SATURATION = 1;
final float MAX_BRIGHTNESS = 1;
final float INTENSITY_THRESHOLD = 0.005;

color masterColor;
float[] masterRGB;

color WHITE, BLACK, GREY, RED, GREEN, BLUE;
float[] BLACK_RGB = {0, 0, 0};

final int WIDTH = 500;
final int HEIGHT = 400;
final int MARGIN = 20;
final int TEXT_SIZE = 20;
final int RECT_SIZE = 100;

final String LT_CONFIG = "LTs.cfg";
final int LTS_CONFIG_LINE_TOKENS = 3;

// Startup parameters
final float SENSITIVITY = 100.0;
final float LEVEL_PART = 0.5;
final float EFFECT_FADER = 0.9;
final float STROBE = 0;
final float STROBE_CONST = 1000; // Max length of period (ms)

float masterLevel = 1;
float[] masterBalance = {1, 1, 1};

MidiBus midiBus; // The MidiBus

final String LTS_CONFIG_DIR = "effects";

// let's set a filter (which returns true if file's extension is .lts)
java.io.FilenameFilter ltsFilter = new java.io.FilenameFilter() {
  boolean accept(File dir, String name) {
    return name.toLowerCase().endsWith(".lts");
  }
};

// setup
void setup()
{
  colorMode(RGB, 255);
  
  // Define static colors
  WHITE = color(255, 255, 255);
  GREY = color(128, 128, 128);
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
  parameters.set("eff fader", EFFECT_FADER);
  parameters.set("master level", masterLevel);
  parameters.set("master red", masterLevel);
  parameters.set("master green", masterLevel);
  parameters.set("master blue", masterLevel);
  parameters.set("saturation", MAX_SATURATION);
  parameters.set("strobe", STROBE);
  
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
  beatSets = readBeatConfig();
  beatLights = beatSets[0];
  
  effects = new EffectSet(128);
  
  //=================================
  
  midiBus = new MidiBus(this, "Oxygen 25", -1);
  //println("Connected to Oxygen 25 MIDI");
  
}
// end of setup

// draw
void draw()
{ 
  
  background(0.5);
  
  fill(WHITE);
  textSize(TEXT_SIZE);
  printSomeValues(MARGIN, MARGIN, 
                  parameters.keyArray(), nf(parameters.valueArray(), 1, DECIMALS));
  printSets(beatSets, MARGIN);
  printThings(effects.theSet, height/2);
  
  //Print preview
  if (preview) drawPreview();
  
  // Get sound level
  status.set("level", in.mix.level());
  level = status.get("level") * parameters.get("level part") 
          + (1 - parameters.get("level part"));
  
  if (effects.enabled) {
    masterRGB = effects.mixRGB();
  } else if (beatLights.enabled) {
    // Update lights
    driver.strobe = 0;
    beatLights.update(status.get("level"));
    // Mix master color
    masterRGB = beatLights.mixRGB();
  } else {
    driver.strobe = 0;
    masterRGB = BLACK_RGB;
  }  
  // Fade & clean effects
  effects.fadeAll(parameters.get("eff fader"));
  effects.clean();
  
  // Scale with level settings
  if (effects.enabled || beatLights.enabled) {
    for (int i = 0; i < 3; i++) {
      masterRGB[i] = parameters.get("master level") * masterBalance[i] * masterRGB[i];
      masterRGB[i] = lerp(255, masterRGB[i], parameters.get("saturation"));
    }
  }
  
  colorMode(RGB, 255);
  masterColor = color(masterRGB[0], masterRGB[1], masterRGB[2]);
  
  // DioderDriver
  driver.r = int(masterRGB[0]);
  driver.g = int(masterRGB[1]);
  driver.b = int(masterRGB[2]);
  driver.update();
  
  // Print status
  printSomeValues(MARGIN, (int) 2/3 * height, 
                  status.keyArray(), nf(status.valueArray(), 1, 3));
                                  
  text("Beats: "+beatLights.enabled, MARGIN, height - MARGIN - 2.2*TEXT_SIZE);
  text("Effects: "+effects.enabled, MARGIN, height - MARGIN - TEXT_SIZE);
}
// end of draw


// keyPressed
void keyPressed() {
  /*
  if (key == 44) { //,
  }
  if (key == 46) { //.
  }
  if (key == 45) { //-   
  }
  if (key == 8) { // Backsapce
  }
  if (key == 10) { // Enter
  }       
  if (key == 103) { //g
  }
  if (key == 98) { //b 
  }
  if (key == 97) { //a
  }
  if (key == 122) { //z
  }
  if (key == 120) { //x
  } 
  */
  // Switch LightThings on/off
  if (key == 48) { //0
      beatLights.enableAll();
  }
  if (key == 43) { //+
    beatLights.disableAll();
  }
  if (key >= 49 && key <= 57) { // 1...9
    if (key - 49 < beatSets.length) beatSets[key - 49].flip();
  }
  if (key == 112) { //p
    preview = !preview;
    if (preview) println("Preview ON"); else println("Preview OFF");
  }
  if (key == 114) { //r
    readBeatConfig();
  }
}


// keyReleased
void keyReleased() {   
  
}

BeatSet[] readBeatConfig() {
  print("Reading effects...");
  // we'll have a look in the data folder
  File folder = new File(dataPath(""));
  
  // list the files in the data folder, passing the filter as parameter
  String[] filenames = folder.list(ltsFilter);
 
  BeatSet[] sets;
  sets = new BeatSet[filenames.length];
   
  for (int i = 0; i < filenames.length; i++) {
    sets[i] = new BeatSet();
    sets[i].readConfig(dataPath(filenames[i]));
  }
  println(filenames.length + " files read.");
  return sets;
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

// printSets
void printSets(LightSet[] lts, int yPos) {
  
  int COLUM_WIDTH = 200;
  float LINESPREAD = 1.1;
  
  textAlign(LEFT);
  
  int i = 0;
  
  for (LightSet ls : lts) {
    if (ls != null) {
      if (ls.enabled) fill(WHITE); else fill(GREY); 
      text(nf(i + 1,1,0) + ": " + ls.name, width - COLUM_WIDTH, yPos);
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
  //print("Pitch: " + pitch + "  Velocity: " + velocity + "\n");
  float hue, saturation, brightness;
  hue = (float(pitch) % 24) * 15;
  saturation = parameters.get("saturation"); 
  brightness = float(velocity) / 127;
  //print("H: " + hue + " S: " + saturation + " B: + " + brightness + "\n");
  effects.change(pitch, parameters.get("eff fader"), hue, saturation, brightness);
}

void noteOff(int channel, int pitch, int velocity) {
  effects.disable(pitch);
  //print("OFF: " + pitch + "\n");
}

void controllerChange(int channel, int number, int value) {  
  //println("Controller: " + str(channel) +"/"+ str(number) +"/"+ str(value));
  if (number == 7) { //C9
    parameters.set("master level", float(value) / 127);
  }
  if (number == 84) { //C8
    parameters.set("eff fader", float(value) / 127);
  }
  if (number == 74) { //C1
    masterBalance[0] = float(value) / 127;
    parameters.set("master red", float(value) / 127);
  }
  if (number == 71) { //C2
    masterBalance[1] = float(value) / 127;
    parameters.set("master green", float(value) / 127);  
  }
  if (number == 91) { //C3
    masterBalance[2] = float(value) / 127;  
    parameters.set("master blue", float(value) / 127);
  }
  if (number == 1) { //C17  
    parameters.set("strobe", value);
  }
  if (number == 93) { //C4  
    parameters.set("saturation", float(value) / 127);
  }
  if (number == 116) { //STOP  
    if(value == 127) effects.kill();
  }
  if (number == 117) { //PLAY  
    if(value == 127) effects.enabled = !effects.enabled;
  }
  if (number == 118) { //RECORD  
    if(value == 127) beatLights.enabled = !beatLights.enabled;
  }
  if (number == 113) { //RECYCLE  
    if(value == 127) beatLights.readConfig(LT_CONFIG);
  }
  if (number == 73) { //C5  
    parameters.set("sensitivity",pow(10,float(value)/127*3));
    beat.setSensitivity((int) parameters.get("sensitivity"));
  }
  if (number == 72) { //C6  
    parameters.set("level part", float(value) / 127); 
  }
}

  
// ------------------------------------------------------------------------  


// stop
void exit()
{
  print("Shutting down . . . ");
  
  // Switch lights off
  driver.update(BLACK);
  
  // always close Minim audio classes when you are finished with them
  in.close();
  // always stop Minim before exiting
  minim.stop();
  // close MIDI bus
  midiBus.close();
  
  print("done. Goodbye!\n");
  
  // this closes the sketch
  super.exit();
}
