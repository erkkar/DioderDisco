// LightSet
class LightSet
{ 
  String name;
  boolean enabled;
  LightThing[] theSet;
  
  // Constructor
  LightSet(int size) {
     this.theSet = new LightThing[size];
  }
  
  // mixColour
  float[] mixRGB() {
    // Mix colours
    
    float r = 0;
    float g = 0;
    float b = 0;
    
    for (LightThing lt : theSet) {      
      if (lt.intensity > INTENSITY_THRESHOLD) { 
        float[] rgb = lt.getRGB();
        r = max(r, rgb[0]);
        g = max(g, rgb[1]);
        b = max(b, rgb[2]);
      }
    }
    float[] rgb = {r, g, b};
    return rgb;
  }
  
  void enable(int index) {
    enabled = true;
    theSet[index].enabled = true;
  }
  
  void enableAll() {
    for (LightThing lt : theSet) {
      if (lt != null) lt.enabled = true;
    }
  }
  
  void disable(int index) {
    if (theSet[index] != null) theSet[index].enabled = false;
  }
  
  void disableAll() {
    for (LightThing lt : theSet) {
      if (lt != null) lt.enabled = false;
    }
  }
  
  void fadeAll() {
    for (LightThing lt : theSet) {
      if (lt != null) lt.fade(lt.fader);
    }
  }
  
  // enable & disable & flip
  void enable() { 
    enabled = true; 
  }
  void disable() { 
    enabled = false; 
  }
  void flip() { 
    enabled = !enabled; 
  } 
}


//BeatSet
class BeatSet extends LightSet 
{
  // Constructor
  BeatSet() {
    super(0);
    enabled = false;
  }
  
  void update(float level, float faderScaling) {
    float scaledFader;
    for (BeatThing lt : (BeatThing[]) theSet) {
      scaledFader = constrain(faderScaling * lt.fader, 0.01, 0.99);
        if ( level > LEVEL_THRESHOLD ) {
          lt.beat(level, scaledFader);
        } else {
          lt.fade(scaledFader); 
        }  
     }
  }

  void readConfig(String filename) {
    theSet = new BeatThing[0];
    BufferedReader LTconfig = createReader(filename);
    String line;
    String[] config = {};
    char type;
    
    // Get name on first line      
    try {
      line = LTconfig.readLine();
    } catch (IOException e) {
      line = null;
    }
    if (line == null || line.equals("")) return;
    else name = line;
    
    // Read effect config from rest of the file
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
      
      type = config[0].charAt(0);
      theSet = (BeatThing[]) append(theSet, new BeatThing(type, float(config[1]), float(config[2])));
    }
  }
}



// EffectSet
class EffectSet extends LightSet 
{  
  // Constructor
  EffectSet(int size) {
    super(size);
    for (int i = 0; i < size; i++) {
      theSet[i] = new LightThing(false, EFFECT_FADER, 0);
    }
  }
  
  void change(int index, float fader, float hue, float saturation, float brightness) {
    enabled = true;
    theSet[index].change(fader, hue, saturation, brightness);
  }
  
  void fadeAll(float fader) {
    for (LightThing lt : theSet) {
      if (lt != null && !lt.enabled) lt.fade(fader);
    }
  }
  
  void clean() {
    int howMany = 0;
    for (LightThing lt : theSet) {
      if (lt.intensity > INTENSITY_THRESHOLD) howMany++;
    }
    if (howMany == 0) enabled = false;
  } 
  
  void kill() {
    enabled = false;
    for (LightThing lt : theSet) {
      lt.intensity = 0;
    }
  }
}