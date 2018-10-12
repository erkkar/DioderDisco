/**
Dioder Disco
  */
  
final boolean DEBUG = false;

import ddf.minim.*;
import ddf.minim.analysis.*;
import themidibus.*;

Minim        minim;
AudioInput   in;
BeatDetect   bd;
BeatListener bl;
DioderDriver driver;
DmxDriver    quad_spot; 

// Beats and effects
BeatSet[] beatSets;
MixSet ms;
EffectSet effects;
char activeBeatSet = 'A';
boolean beatsOn = true;

// Sound volume
float level;
float mixLevel;
float levelPart = 0.5;
final float LEVEL_THRESHOLD = 0.005;

// Parameters
FloatDict parameters;
FloatDict status;

final int DECIMALS = 2;

boolean preview = false;

// Colour settings
final int MAX_HUE = 127;
final float MAX_SATURATION = 1;
final float MAX_BRIGHTNESS = 1;
final float INTENSITY_THRESHOLD = 0.005;
final int MAX_BEAT_EFFECTS = 3;

color masterColor;
float[] masterRGB;
float[] effectsRGB;

color WHITE, BLACK, GREY, RED, GREEN, BLUE;
float[] BLACK_RGB = {0, 0, 0};

final int WIDTH = 500;
final int HEIGHT = 500;
final int MARGIN = 20;
final int TEXT_SIZE = 20;
final int RECT_SIZE = 100;
final float SLIDER_TOP = HEIGHT / 2 + RECT_SIZE / 2;
final float SLIDER_BTM = HEIGHT - RECT_SIZE / 2;

final String LT_CONFIG = "LTs.cfg";
final int LTS_CONFIG_LINE_TOKENS = 3;

// Startup parameters
final float SENSITIVITY = 100.0;
final float LEVEL_PART = 1;
final float EFFECT_FADER = 0.9;
final float BEAT_FADER_SCALE = 1;
final float STROBE_CONST = 1000; // Max length of period (ms)

float masterLevel = 1;

MidiBus midiBus; // The MidiBus
final String MIDI_DEVICE = "Oxygen 25";
final int KEYS = 24;

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
  size(500, 500, P2D);
  
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
  parameters.set("beat fader scale", BEAT_FADER_SCALE);
  parameters.set("saturation", MAX_SATURATION);
  parameters.set("master level", masterLevel);
  parameters.set("strip mode", 1);
  parameters.set("strip pos", 0);
  
  status = new FloatDict();
    
  minim = new Minim(this);
  
  in = minim.getLineIn();
  
  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  bd = new BeatDetect(in.bufferSize(), in.sampleRate());
  
  // set the sensitivity to 300 milliseconds
  // After a beat has been detected, the algorithm will wait for 300 milliseconds 
  // before allowing another beat to be reported. You can use this to dampen the 
  // algorithm if it is giving too many false-positives. The default value is 10, 
  // which is essentially no damping. If you try to set the sensitivity to a negative value, 
  // an error will be reported and it will be set to 10 instead. 
  bd.setSensitivity((int) parameters.get("sensitivity"));
  
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(bd, in);  
  
  // Init Dioder driver
  driver = new DioderDriver(this, "COM4");
  
  // Init DMX driver
  quad_spot = new DmxDriver(0);
   
  //=================================
  // Init LightThings
  //beatSets = readBeatConfig();
  ms = new MixSet();
  effects = new EffectSet(128);
  //=================================
  

  midiBus = new MidiBus(this, MIDI_DEVICE, -1);
  
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
  //printSets(beatSets, MARGIN);
  //printThings(effects.theSet, height/2);
  printBeatSet();
  
  //Print preview
  if (preview) drawPreview();
  
  // Get sound level
  status.set("level", in.mix.level());
  level = status.get("level") * parameters.get("level part") 
          + (1 - parameters.get("level part"));
  
  if (effects.enabled) {
    effectsRGB = effects.mixRGB();
  } else {
    effectsRGB = BLACK_RGB;
  }
  // Fade & clean effects
  effects.fadeAll(parameters.get("eff fader"));
  effects.clean();
  
  if (beatsOn) {
    // Update lights
    ms.update(status.get("level"), parameters.get("beat fader scale"));
    // Mix master color
    masterRGB = ms.mixRGB(); 
  } else {
    masterRGB = BLACK_RGB;
  }  

  // Scale with level settings
  if (beatsOn) {
    for (int i = 0; i < 3; i++) {
      masterRGB[i] = masterRGB[i];
      masterRGB[i] = lerp(255, masterRGB[i], parameters.get("saturation"));
    }
  }
  
  if (effects.enabled) {
    for (int i = 0; i < 3; i++) {
      effectsRGB[i] = parameters.get("master level") * effectsRGB[i];
      effectsRGB[i] = lerp(255, effectsRGB[i], parameters.get("saturation"));
    }
  }
  
  colorMode(RGB, 255);
  masterColor = color(masterRGB[0], masterRGB[1], masterRGB[2]);
  
  // DMX driver
  quad_spot.r = int(masterRGB[0]);
  quad_spot.g = int(masterRGB[1]);
  quad_spot.b = int(masterRGB[2]);
  quad_spot.setLevel(parameters.get("master level"));

  // Dioder driver
  driver.r = int(effectsRGB[0]);
  driver.g = int(effectsRGB[1]);
  driver.b = int(effectsRGB[2]);
  
  driver.strip_mode = int(parameters.get("strip mode"));
  driver.strip_pos = int(parameters.get("strip pos") * 255);
  
  driver.update();
  quad_spot.update();
  
  // Print status
  printSomeValues(MARGIN, (int) 2/3 * height, 
                  status.keyArray(), nf(status.valueArray(), 1, 3));
                                  
  //text("Beats: "+beatSets[activeBeatSet].enabled, MARGIN, height - MARGIN - 2.2*TEXT_SIZE);
  //text("Effects: "+effects.enabled, MARGIN, height - MARGIN - TEXT_SIZE);
}
// end of draw



//BeatSet[] readBeatConfig() {
//  print("Reading effects...");
//  // we'll have a look in the data folder
//  File folder = new File(dataPath(""));
  
//  // list the files in the data folder, passing the filter as parameter
//  String[] filenames = folder.list(ltsFilter);
//  if (filenames.length > 9) println("Too many effect configs, only first 9 loaded!");
 
//  BeatSet[] sets;
//  sets = new BeatSet[filenames.length];
   
//  for (int i = 0; i < filenames.length; i++) {
//    sets[i] = new BeatSet();
//    sets[i].readConfig(dataPath(filenames[i]));
//  }
//  println(filenames.length + " files read.");
//  return sets;
//}


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

// printBeatSet
void printBeatSet() {
  
  fill(WHITE);
  text("Kick", 0 * RECT_SIZE + RECT_SIZE / 2, 3/4 * height);
  text("Snare", 1 * RECT_SIZE + RECT_SIZE / 2, 3/4 * height);
  text("Hat", 2 * RECT_SIZE + RECT_SIZE / 2, 3/4 * height);
  text("A", 3 * RECT_SIZE + RECT_SIZE / 2, SLIDER_TOP);
  text("B", 3 * RECT_SIZE + RECT_SIZE / 2, SLIDER_BTM);

  
  float x, y;
  
  for (int i = 0; i < MAX_BEAT_EFFECTS; i += 1) {
    x = i * RECT_SIZE;
    
    // A
    y = height / 2;
    fill(ms.A.theSet[i].colour);
    if (activeBeatSet == 'A') strokeWeight(2); else strokeWeight(0);
    rect(x, y, RECT_SIZE, RECT_SIZE);
    fill(WHITE);
    text(nf(ms.A.theSet[i].fader, 1, 2), x + 0.3 * RECT_SIZE, y + RECT_SIZE / 2); 
    
    //// Out
    //y = height / 2 + RECT_SIZE;
    //fill(ms.theSet[i].colour);
    //rect(x, y, RECT_SIZE, RECT_SIZE / 2);
    //fill(WHITE);
    //text(nf(ms.theSet[i].fader, 1, 2), x + 0.3 * RECT_SIZE, y + RECT_SIZE / 4);
    
    // B
    y = height - RECT_SIZE;
    fill(ms.B.theSet[i].colour);
    if (activeBeatSet == 'B') strokeWeight(2); else strokeWeight(0);
    rect(x, y, RECT_SIZE, RECT_SIZE);
    fill(WHITE);
    text(nf(ms.B.theSet[i].fader, 1, 2), x + 0.3 * RECT_SIZE, y + RECT_SIZE / 2);
    
  }
  
  stroke(WHITE);
  strokeWeight(5);
  line(width - 50, SLIDER_TOP, width - 50, SLIDER_BTM);
  y = SLIDER_BTM - ms.mixA * (SLIDER_BTM - SLIDER_TOP);
  line(width - 60, y, width - 40, y); 

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
//void printSets(LightSet[] lts, int yPos) {
  
//  int COLUM_WIDTH = 200;
//  float LINESPREAD = 1.1;
  
//  textAlign(LEFT);
  
//  int i = 0;
  
//  for (LightSet ls : lts) {
//    if (ls != null) {
//      if (ls.enabled) fill(WHITE); else fill(GREY); 
//      text(nf(i + 1, 1, 0) + ": " + ls.name, width - COLUM_WIDTH, yPos);
//      yPos = int(yPos + LINESPREAD * TEXT_SIZE);
//    }
//    i++;
//  }
//}



// drawPreview
// Draws a colour preview on screen
void drawPreview() {
  fill(masterColor);
  rect(width - RECT_SIZE, height - RECT_SIZE, RECT_SIZE, RECT_SIZE);
} 

// ------------------------------------------------------------------------  


// stop
void exit()
{
  print("Shutting down . . . ");
  
  // Switch lights off
  driver.update(BLACK);
  driver.close();
  
  // Close DMX
  quad_spot.close();
  
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