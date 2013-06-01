/**
Dioder Disco
  */

import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.serial.*;

Minim        minim;
AudioPlayer  in;
//AudioInput   in;
BeatDetect   beat;
BeatListener bl;
DioderDriver driver;
LightThing[] lts;

float kickSize, snareSize, hatSize;

// Sound volume
float level;
float levelPart = 0.5;

// Max / min levels
static int MIN_AMP = 1;
static int MAX_AMP = 255;

// Relative amplitudes
static float KICK  = 0.7;  //red
static float SNARE = 1.0;  //green
static float HAT   = 0.5;  //blue

float fade = 0.9;

boolean follow = true;
boolean kickMode = false;
String colourMood;

static int LIGHT_THINGS = 3;

color masterColor;

void setup()
{
  colorMode(HSB);
  masterColor = color(0,0,0);
  
  size(400,400);
  
  minim = new Minim(this);
  
  //in = minim.getLineIn();
  in = minim.loadFile("sample.mp3");
  in.loop();
  
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
  beat.setSensitivity(100);  
  
  kickSize = snareSize = hatSize = MIN_AMP;
  
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, in);  
  
  // Init Dioder driver
  driver = new DioderDriver(this);
  
  // Init LightThings
  lts = new LightThing[LIGHT_THINGS];
  
  lts[0] = new KickThing();
  lts[1] = new SnareThing();
  lts[2] = new HatThing();
  
  lts[0].setup(1, 0.9, MIN_AMP, MAX_AMP);
  lts[1].setup(1, 0.9, MIN_AMP, MAX_AMP);
  lts[2].setup(1, 0.9, MIN_AMP, MAX_AMP);
  
}

void draw()
{ 
  background(0.5);
  
  fill(255,255,255);
  textSize(20);
  text("Fade: ",20,20);
  text(fade,20,40);
  text("Level: ",20,60);
  text(levelPart,20,80);
  
  fill(masterColor);
  rect(200,200,100,100);
  
  if (follow) {
  
    // Get sound level
    level = in.mix.level() * levelPart + (1 - levelPart);
    //level = 1;
    
    // Fade out
    for (int i = 0; i < LIGHT_THINGS; i++) {
      lts[i].fade();
      lts[i].update(level);
    }
    
    // Mix master color
    masterColor = lts[0].getColor();
    if (LIGHT_THINGS > 1) { 
        for (int i = 1; i < LIGHT_THINGS; i++) {
            masterColor = lerpColor(masterColor, lts[i].getColor(), 0.5);
        }
    }
    
    
        
    
    
    
    if (!kickMode) { 
      // DioderDriver
      //driver.r = (int) lts[0].size;
      //driver.g = (int) lts[1].size;
      //driver.b = (int) lts[2].size;
    } else {
      if (colourMood == "red") {
          driver.r = (int) kickSize;
          driver.g = 0;
          driver.b = 0;
      }
      if (colourMood == "green") {
        driver.r = (int) 0;
        driver.g = (int) kickSize;
        driver.b = (int) 0;
      }   
      if (colourMood == "blue") {
        driver.r = 0;
        driver.g = 0;
        driver.b = (int) kickSize;
      }
    }
    driver.update();
  }

  
}

void stop()
{
  // always close Minim audio classes when you are finished with them
  in.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}

void keyPressed() {
  if (key == 44) { //,
      follow = false;
      driver.r = MAX_AMP;
      driver.g = 0;
      driver.b = 0;
      driver.update();
  }
  if (key == 46) { //.
      follow = false;
      driver.r = 0;
      driver.g = MAX_AMP;
      driver.b = 0;
      driver.update();
  }
  if (key == 45) { //-
      follow = false;
      driver.r = 0;
      driver.g = 0;
      driver.b = MAX_AMP;
      driver.update();
    }
  if (key == 8) { // Backsapce
    if (follow) {
      follow = false;
      driver.r = 0;
      driver.g = 0;
      driver.b = 0;
      driver.update();
    } else { 
      follow = true;
    }
    }
  if (key == 10) { // Enter
      follow = false;
      driver.r = 255;
      driver.g = 255;
      driver.b = 255;
      driver.update();
  }    
  if (key == 49) {  //1
    fade = 0.3;
  }    
  if (key == 50) {  //2
    fade = 0.9;
  }   
  if (key == 114) {  //r
    kickMode = true;
    colourMood = "red";
  }
  if (key == 103) {  //g
    kickMode = true;
    colourMood = "green";
  }
  if (key == 98) {  //b
    kickMode = true;
    colourMood = "blue";
  }
  if (key == 97) {  //a
    kickMode = false;
  }
  if (key == 122) { //z
    if(levelPart > 0) levelPart = levelPart - 0.1;
  }
  if (key == 120) { //x
    if(levelPart < 1) levelPart = levelPart + 0.1;
  }
}

void keyReleased() { 
  if (key != 8) follow = true;
}
