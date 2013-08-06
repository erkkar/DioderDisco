//import java.util.LinkedList;

class LightSet
{
  LightThing[] theSet;
  
  // Constructor
  LightSet(int size) {
     theSet = new LightThing[size];
  }
  
  // mixColour
  color mixColour() {
    // Mix colours
    
    float r = 0;
    float g = 0;
    float b = 0;
    
    int count = 0;
    
    for (LightThing lt : theSet) {      
      if (lt != null) {
        count++; 
        float[] rgb = lt.getRGB();
        r = r + rgb[0];
        g = g + rgb[1];
        b = b + rgb[2];
      }
    }
    r = r / count;
    g = g / count;
    b = b / count;
    
    colorMode(RGB, 255);
    return color(r, g, b);
  }
  
  void enable(int index) {
    theSet[index].enabled = true;
  }
  
  void enableAll() {
    for (LightThing lt : theSet) {
      if (lt != null) lt.enabled = true;
    }
  }
  
  void disable(int index) {
    theSet[index].enabled = false;
  }
  
  void disableAll() {
    for (LightThing lt : theSet) {
      if (lt != null) lt.enabled = false;
    }
  }
  
  void fadeAll() {
    for (LightThing lt : theSet) {
      if (lt != null) lt.fade();
    }
  }
  
  void flip(int index) {
    if (index < theSet.length) theSet[index].flip();
  }
}


//BeatSet
class BeatSet extends LightSet 
{
  // Constructor
  BeatSet() {
    super(0);
  }
  
  void update(float level) {
    for (LightThing lt : theSet) {
        if ( level > LEVEL_THRESHOLD ) {
          lt.beat(level);
        } else { 
          lt.fade(); 
        }  
     }
  }

  void readConfig(String filename) {
    theSet = new LightThing[0];
    BufferedReader LTconfig = createReader(filename);
    String line;
    String[] config = {};
    while (true) {
      try {
        line = LTconfig.readLine();
      } catch (IOException e) {
        line = null;
        break;
      }
      if (line == null || line.equals("")) break;
      
      config = splitTokens(line);
      // Check correct length
      if (config.length != LTS_CONFIG_LINE_TOKENS) continue; 
      
      switch(config[1].charAt(0)) {
        case 'k':
          theSet = (LightThing[]) append(theSet, new KickThing(config[0], float(config[2]), float(config[3])));
          break;
        case 's':
          theSet = (LightThing[]) append(theSet, new SnareThing(config[0], float(config[2]), float(config[3])));
          break;
        case 'h':
          theSet = (LightThing[]) append(theSet, new HatThing(config[0], float(config[2]), float(config[3])));
          break;
      }
    }
    println("Total Light Things read: " + theSet.length);  
  }
}


// EffectSet
class EffectSet extends LightSet 
{  
  // Constructor
  EffectSet(int size) {
    super(size);
  }
  
  void create(int hue, float fader) {
    theSet[hue] = new LightThing(true, "effect", fader, hue);
  }
  
  void fadeAll() {
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
