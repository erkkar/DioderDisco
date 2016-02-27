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
  LightThing(boolean status, float fader, float hue, float brightness) 
  {
    this.enabled = status;
    this.fader = fader;
    this.hue = hue;
    this.saturation = MAX_SATURATION;
    this.brightness = brightness;
    
    colorMode(HSB, MAX_HUE, MAX_SATURATION, MAX_BRIGHTNESS);
    this.colour = color(hue, saturation, brightness);
    
    this.intensity = 0;
    
    calcRGB();
  }
  
  void update() {
  }
  
  void change(float fader, float hue, float saturation, float brightness) {
    this.enabled = true;
    this.fader = fader;
    this.hue = hue;
    this.saturation = saturation;
    this.brightness = brightness;
    this.intensity = brightness;
    colorMode(HSB, MAX_HUE, MAX_SATURATION, MAX_BRIGHTNESS);
    colour = color(hue, saturation, brightness);
    calcRGB();
  }
  
  void change(float fader, color colour) {
   this.fader = fader;
   this.colour = colour;
   calcRGB();
  }
  
  void changeHue(float hue) {
    if (hue == 0) {
      this.brightness = 0;
    } else {
      this.brightness = MAX_BRIGHTNESS;
      this.hue = hue;
    }
    colorMode(HSB, MAX_HUE, MAX_SATURATION, MAX_BRIGHTNESS);
    colour = color(hue, saturation, brightness);
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
  
  void fadeWithScale(float scaling) {
    fade(constrain(scaling * fader, 0.01, 0.99));
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