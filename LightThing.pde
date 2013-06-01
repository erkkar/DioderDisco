class LightThing 
{
  float fader;
  int hue;
  float saturation;
  float brightness;
  int minB, maxB;
  
  // Constructor
  LightThing() 
  {
    saturation = 100;
    brightness = 100;
  }
  
  void setup(int hue, float fader, int minB, int maxB) { 
    this.hue = hue;
    this.fader = fader;
    this.minB = minB;
    this.maxB = maxB;
  }
  
  // Fader
  void fade() {
    brightness = (int) constrain(brightness * fader, minB, maxB); 
  }
  
  // Updater
  void update(float level) {
    saturation = level * 100;
  }
  
  // Get color
  color getColor() {
    return color(hue, saturation, brightness);
  }
}


class KickThing extends LightThing
{ 
  void update(float level) {
    super.update(level);
    if ( beat.isKick() ) brightness  = maxB;
  }
}

class SnareThing extends LightThing
{
  void update(float level) {
    super.update(level);
    if ( beat.isSnare() ) brightness  = maxB;
  }
}

class HatThing extends LightThing 
{
  void update(float level) {
    super.update(level);
    if ( beat.isHat() ) brightness  = maxB;
  }
}
