// LightThing
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
  LightThing(boolean status, float fader, float hue) 
  {
    this.enabled = status;
    this.comment = "";
    this.fader = fader;
    this.hue = hue;
    this.saturation = MAX_SATURATION;
    this.brightness = MAX_BRIGHTNESS;
    
    colorMode(HSB, MAX_HUE, MAX_SATURATION, MAX_BRIGHTNESS);
    this.colour = color(hue, saturation, brightness);
    
    this.intensity = 0;
    
    calcRGB();
  }
  
  void change(float fader, float hue, float saturation, float brightness) {
    this.enabled = true;
    this.fader = fader;
    this.hue = hue;
    this.saturation = saturation;
    this.brightness = brightness;
    this.intensity = brightness; 
    calcRGB();
  }
  
  void calcRGB() {
    colorMode(RGB, 255);
    R = (this.colour >> 16) & 0xFF;
    G = (this.colour >> 8) & 0xFF;
    B = this.colour & 0xFF;
  }
  
  // fade
  void fade(float fader) {
    intensity = constrain(intensity * fader, 0, brightness); 
  }
  
  // beat
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
  
  // getColor
  color getRGBColor() {
    colorMode(RGB, 255); 
    return color(intensity * R, intensity * B, intensity * B); 
  }
  
  color getHSBColor() {
    colorMode(HSB, MAX_HUE, MAX_SATURATION, MAX_BRIGHTNESS);
    return color(hue, saturation, intensity * brightness);
  }
  
  // Get original color
  color getOrigColor() { 
    colorMode(RGB, 255);
    return color(R, G, B); 
  }
  
  // flip
  void flip() { 
    enabled = !enabled; 
  }
}


// BeatThing
class BeatThing extends LightThing
{
  char type;
  
  // Constructor
  BeatThing(char type, float fader, float hue) {
    super(true, fader, hue);
    this.type = type; 
  }
  
  void beat(float level, float scaledFader) {
    switch(type) {
      case 'k':
        if (bd.isKick()) super.beat(level); else super.fade(scaledFader);
        break;
      case 's':
        if (bd.isSnare()) super.beat(level); else super.fade(scaledFader);
        break;
      case 'h':
        if (bd.isHat()) super.beat(level); else super.fade(scaledFader);
        break;
    }
  }
}


// EffectThing
//class EffectThing extends LightThing
//{
//  // Constructor
//  EffectThing(float hue, float saturation, float brightness) {
//    enabled = status;
//    this.fader = EFFECT_FADER;
//    this.hue = hue;
//    this.saturation = saturation;
//    this.brightness = MAX_BRIGHTNE;
//    
//    intensity = brightness;
//    
//    colorMode(HSB, MAX_HUE, MAX_SATURATION, MAX_BRIGHTNESS);
//    colour = color(hue, saturation, brightness);
//    colorMode(RGB, 255);
//    R = (colour >> 16) & 0xFF;
//    G = (colour >> 8) & 0xFF;
//    B = colour & 0xFF;
//  }
//}