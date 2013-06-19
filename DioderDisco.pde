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

float kickSize, snareSize, hatSize;

// Sound volume
float level;
float levelPart = 0.5;

boolean follow = true;

static int LIGHT_THINGS = 3;

color masterColor;

static color WHITE, BLACK, RED, GREEN, BLUE;

static int MAX_AMP = 1;


// setup
void setup()
{
  colorMode(HSB, 359, 1, 1);
  
  masterColor = color(0,0,0);
  
  // Define static colors
  WHITE = color(0, 0, 1);
  BLACK = color(0, 0, 0);
  RED = color(0, 1, 1);
  GREEN = color(119, 1, 1);
  BLUE = color(239, 1, 1);
  
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
  
  //=================================
  // Init LightThings
  lts = new LightThing[LIGHT_THINGS];
  
  lts[2] = new KickThing();
  lts[2].setup(0, 0.9, 0, 1);
  
  lts[1] = new SnareThing();
  lts[1].setup(119, 0.5, 0, 0.1);
  
  lts[0] = new HatThing(); 
  lts[0].setup(239, 0.5, 0, 0.1);
  //=================================
}


// draw
void draw()
{ 
  background(0.5);
  
  fill(WHITE);
  textSize(20);
  text("Level: ",20,60);
  text(levelPart,20,80);
  
  fill(masterColor);
  //rect(200,200,100,100);
  
  if (follow) {
  
    // Get sound level
    level = in.mix.level() * levelPart + (1 - levelPart);
    //level = 1;
    
    // Check beats
    for (int i = 0; i < LIGHT_THINGS; i++) {
      lts[i].update(level);
    }
    
    // Mix master color
    masterColor = lts[0].getColor();
    if (LIGHT_THINGS > 1) { 
        for (int i = 1; i < LIGHT_THINGS; i++) {
            masterColor = lerpColor(masterColor, lts[i].getColor(), 0.5);
        }
    }
    
    // DioderDriver
    driver.setColor(masterColor);
  }
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
  if (key == 114) {  //r
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
    if(levelPart < 1) levelPart = levelPart + 0.1;
  } 
  driver.setColor(masterColor);
}


// keyReleased
void keyReleased() { 
  if (key != 8) follow = true;
}


// stop
void stop()
{
  // always close Minim audio classes when you are finished with them
  in.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}
