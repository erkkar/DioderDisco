import java.util.LinkedList;

class LightSet
{
 
  int MAX_LTS = 3;
  
  LinkedList<LightThing> theSet;
  
  int activeLTs;
  
  float r = 0;
  float g = 0;
  float b = 0;
  
  // Constructor
  LightSet() {
     theSet = new LinkedList<LightThing>();
  }
  
  color mixColour() {
    // Mix master color
    
    r = 0;
    g = 0;
    b = 0;
    
    activeLTs = 0;
    
    for (LightThing lt : theSet) {
      if (lt.enabled) {
        activeLTs++; 
        float[] rgb = lt.getRGB();
        r = r + rgb[0];
        g = g + rgb[1];
        b = b + rgb[2];
      }
    }
    r = totalR / activeLTs;
    g = totalG / activeLTs;
    b = totalB / activeLTs;
    
    colorMode(RGB);
    return color(totalR, totalG, totalB);
  }
  
}
        
