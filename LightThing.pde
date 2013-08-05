class LightThing 
{
  float fader;
  boolean enabled;
  String comment;
  
  color colour; 
  float hue;
  float saturation;
  float brightness;
  
  float intensity;
  
  float R, G, B;
  
  // Constructor
  LightThing(boolean status, String comment, float fader, float hue) 
  {
    enabled = status;
    this.comment = comment;
    this.fader = fader;
    this.hue = hue;
    this.saturation = MAX_SATURATION;
    this.brightness = MAX_BRIGHTNESS;
    
    intensity = brightness;
    
    colorMode(HSB, MAX_HUE, MAX_SATURATION, MAX_BRIGHTNESS);
    colour = color(hue, saturation, brightness);
    colorMode(RGB, 255);
    R = (colour >> 16) & 0xFF;
    G = (colour >> 8) & 0xFF;
    B = colour & 0xFF;
  }
  
  
  // Fader
  void fade() {
    intensity = constrain(intensity * fader, 0, brightness); 
  }
  
  // Beat
  void beat(float level) {
    if (enabled) {
      intensity = brightness * level;
    }
  }
  
  // getRGB
  float[] getRGB() {
    float[] rgb = new float[3];
    rgb[0] = intensity * R;
    rgb[1] = intensity * G;
    rgb[2] = intensity * B;
    return rgb;
  }
      
  
  // Get color
  color getColor() {
    colorMode(RGB); 
    return color(intensity * R, intensity * B, intensity * B); 
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
  KickThing(String comment, float fader, float hue) { super(true, comment, fader, hue); }
  
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
  SnareThing(String comment, float fader, float hue) { super(true, comment, fader, hue); }
  
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
  HatThing(String comment, float fader, float hue) { super(true, comment, fader, hue); }
  
  void beat(float level) {
    if ( beat.isHat() ) {
      super.beat(level);
    } else {
      super.fade();
    }
  }
}
