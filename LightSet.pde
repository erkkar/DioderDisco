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
    super(MAX_BEAT_EFFECTS);
    theSet[0] = new LightThing(true, 0.5, 0.0, MAX_BRIGHTNESS);
    theSet[1] = new LightThing(true, 0.5, 0.0, MAX_BRIGHTNESS);
    theSet[2] = new LightThing(true, 0.5, 0.0, MAX_BRIGHTNESS);
  }

  //void readConfig(String filename) {
  //  BufferedReader LTconfig = createReader(filename);
  //  String line;
  //  String[] config = {};
    
  //  // Get name on first line      
  //  try {
  //    line = LTconfig.readLine();
  //  } catch (IOException e) {
  //    line = null;
  //  }
  //  if (line == null || line.equals("")) return;
  //  else name = line;
    
  //  // Read effect config from rest of the file
  //  for (int i = 0; i < MAX_BEAT_EFFECTS; i += 1) {
  //    try {
  //      line = LTconfig.readLine();
  //    } catch (IOException e) {
  //      line = null;
  //      break;
  //    }
  //    if (line == null || line.equals("")) break;
      
  //    config = splitTokens(line);
  //    // Check correct length
  //    if (config.length != LTS_CONFIG_LINE_TOKENS) continue; 
      
  //    theSet[i] = new LightThing(true, float(config[1]), float(config[2]), MAX_BRIGHTNESS);
  //  }
  //}
}

class MixSet extends BeatSet {
  
  BeatSet A;
  BeatSet B;
  
  float mixA = 1;
  
  // Constructor
  MixSet() {
    super();
    A = new BeatSet();
    B = new BeatSet();
  }

  float[] mixRGB() {
    
    for (int i = 0; i < MAX_BEAT_EFFECTS; i += 1) {
      theSet[i].change(lerp(A.theSet[i].fader, B.theSet[i].fader, 1 - mixA), 
                       lerpColor(A.theSet[i].colour, B.theSet[i].colour, 1 - mixA));
    }                 
    return super.mixRGB();
  }
  
  void update(float level, float faderScaling) {
    boolean levelCheck = level > LEVEL_THRESHOLD;
    if (levelCheck && bd.isKick())  theSet[0].beat(level); else theSet[0].fadeWithScale(faderScaling);
    if (levelCheck && bd.isSnare()) theSet[1].beat(level); else theSet[1].fadeWithScale(faderScaling);
    if (levelCheck && bd.isHat())   theSet[2].beat(level); else theSet[2].fadeWithScale(faderScaling);
  }
  
  void changeHue(char set, int number, float hue) { //<>// //<>//
    if (set == 'A') {
      A.theSet[number].changeHue(hue);
    } else {
      B.theSet[number].changeHue(hue);
    }
  }
  
  void changeFader(char set, int number, float fader) {
    if (set == 'A') {
      A.theSet[number].fader = fader;
    } else {
      B.theSet[number].fader = fader;
    }
  }
  
// End of MixSet
}


// EffectSet
class EffectSet extends LightSet 
{  
  // Constructor
  EffectSet(int size) {
    super(size);
    for (int i = 0; i < size; i++) {
      theSet[i] = new LightThing(false, EFFECT_FADER, 0, MAX_BRIGHTNESS);
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