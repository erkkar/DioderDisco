//import java.util.LinkedList;

class LightSet
{
  LightThing[] theSet;
  
  int activeLTs;
  
  float r = 0;
  float g = 0;
  float b = 0;
  
  // Constructor
  LightSet() {
     theSet = new LightThing[MAX_HUE + 1];
  }
  
  color mixColour() {
    // Mix colours
    
    r = 0;
    g = 0;
    b = 0;
    
    activeLTs = 0;
    
    for (LightThing lt : theSet) {      
      if (lt != null) {
        activeLTs++; 
        float[] rgb = lt.getRGB();
        r = r + rgb[0];
        g = g + rgb[1];
        b = b + rgb[2];
      }
    }
    r = r / activeLTs;
    g = g / activeLTs;
    b = b / activeLTs;
    
    colorMode(RGB, 255);
    return color(r, g, b);
  }
  
  void enable(int hue, float fader) {
    theSet[hue] = new LightThing(true, "effect", fader, hue);
  }
  
  void disable(int hue) {
    theSet[hue].enabled = false;
  }
  
  void fade() {
    for (LightThing lt : theSet) {
      if (lt != null && !lt.enabled) lt.fade();
    }
  }
  
  void clean() {
    for (int i = 0; i < theSet.length; i++) {
      if (theSet[i] != null && theSet[i].intensity < 0.1 * MAX_BRIGHTNESS) {
        theSet[i] = null;
      }
    }
  }
}
        
