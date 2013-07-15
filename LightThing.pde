class LightThing 
{
  float fader;
  boolean enabled;
  String comment;
  
  color colour; 
  float hue;
  float saturation;
  float brightness;
  
  float currentBrightness;
  
  // Constructor
  LightThing(boolean status) 
  {
    enabled = status;
    hue = 0;
    saturation = MAX_SATURATION;
    brightness = MAX_BRIGHTNESS;
    currentBrightness = brightness;
    
  }

  
  // setColour()
  void setColour() {
     colorMode(HSB, MAX_HUE, MAX_SATURATION, MAX_BRIGHTNESS);
     colour = color(hue, saturation, currentBrightness);
  }
  
  
  // Fader
  void fade() {
    currentBrightness = constrain(currentBrightness * fader, 0, brightness); 
  }
  
  // Beat
  void beat(float level) {
    if (enabled) {
      currentBrightness = constrain(brightness * level, 0, MAX_BRIGHTNESS);
    }
  }
  
  // getRGB
  int[] getRGB() {
    setColour();
    int[] rgb = new int[3];
    rgb[0] = (colour >> 16) & 0xFF;
    rgb[1] = (colour >> 8) & 0xFF;
    rgb[2] = colour & 0xFF;
    return rgb;
  }
      
  
  // Get color
  color getColor() { 
    setColour();
    return colour; 
  }
  
  // Get original color
  color getOrigColor() { 
    colorMode(HSB, MAX_HUE, MAX_SATURATION, MAX_BRIGHTNESS);
    return color(hue, saturation, brightness); 
  }
  
  // Flip status
  void flip() { enabled = !enabled; }
}


// KickThing
class KickThing extends LightThing
{ 
  KickThing() { super(true); }
  
  void beat(float level) {
    if ( beat.isKick() ) { 
      super.beat(level);
    } else {
      super.fade();
    }
  }
}


//SanreThing
class SnareThing extends LightThing
{
  SnareThing() { super(true); }
  
  void beat(float level) {
    if ( beat.isSnare() ) {
      super.beat(level);
    } else {
      super.fade();
    }
  }
}


// HatThing
class HatThing extends LightThing 
{
  HatThing() { super(true); }
  
  void beat(float level) {
    if ( beat.isHat() ) {
      super.beat(level);
    } else {
      super.fade();
    }
  }
}
