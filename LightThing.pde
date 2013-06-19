class LightThing 
{
  float fader;
  boolean enabled;
  String comment;
  
  float r, g, b;
  float R, G, B;
  
  // Constructor
  LightThing() 
  {
    enabled = true;
  }
  
  void setColor(float red, float green, float blue ) {
     R = red; G = green; B = blue;
     r = R; g = G; b = B;
  }
  
  void setColor(int red, int green, int blue, float scale) {
     setColor(red * scale, green * scale,  blue * scale);
  }
  

  
  // Fader
  void fade() {
    r = constrain(r * fader, 0, 255); 
    g = constrain(g * fader, 0, 255); 
    b = constrain(b * fader, 0, 255); 
  }
  
  // Beat
  void beat(float level) {
    if (enabled) {
      r = R * level;
      g = G * level;
      b = B * level;
    }
  }
  
  // Updater
  void update(float level) { 
  }
  
  // Get color
  color getColor() {
    return color(r, g, b);
  }
  
  // Get original color
  color getOrigColor() {
    return color(R, G, B);
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
