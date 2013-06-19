class LightThing 
{
  float fader;
  int hue;
  float saturation;
  float brightness;
  float minB, maxB;
  boolean enabled;
  String comment;
  
  // Constructor
  LightThing() 
  {
    saturation = 100;
    brightness = maxB;
    enabled = true;
  }
  
  void setup(int hue, float fader, float minB, float maxB) { 
    this.hue = hue;
    this.fader = fader;
    this.minB = minB;
    this.maxB = maxB;
  }
  
  
  
  // Fader
  void fade() {
    brightness = constrain(brightness * fader, minB, maxB); 
  }
  
  // Beat
  void beat(float level) {
    if (enabled) brightness  = maxB * level; 
  }
  
  // Updater
  void update(float level) { 
  }
  
  // Get color
  color getColor() {
    return color(hue, saturation, brightness);
  }
  
  // Get original color
  color getOrigColor() {
    return color(hue, 100, 100);
  }
  
  // Switch
  void flip() {
    enabled = !enabled;
  }
}


// KickThing
class KickThing extends LightThing
{ 
  void update(float level) {
    if ( beat.isKick() ) { super.beat(level);
    } else {super.fade();}
  }
}


//SanreThing
class SnareThing extends LightThing
{
  void update(float level) {
    if ( beat.isSnare() ) {super.beat(level);
    } else {super.fade();}
  }
}


// HatThing
class HatThing extends LightThing 
{
  void update(float level) {
    if ( beat.isHat() ) {super.beat(level);
    } else {super.fade();}
  }
}
