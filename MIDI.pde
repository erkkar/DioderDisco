// MIDI Control
void noteOn(int channel, int pitch, int velocity) {
  if (DEBUG) print("Pitch: " + pitch + "  Velocity: " + velocity + "\n");
  float hue, saturation, brightness;
  hue = (float(pitch) % KEYS) * (MAX_HUE / KEYS);
  saturation = parameters.get("saturation"); 
  brightness = float(velocity) / 127;
  //print("H: " + hue + " S: " + saturation + " B: + " + brightness + "\n");
  effects.change(pitch, parameters.get("eff fader"), hue, saturation, brightness);
}

void noteOff(int channel, int pitch, int velocity) {
  if (parameters.get("strip mode") == 1) {
    effects.disable(pitch);
  } else if (parameters.get("strip mode") == 2) {
    effects.kill();
  }
}

void controllerChange(int channel, int number, int value) {  
  if (DEBUG) println("Controller: " + str(channel) +"/"+ str(number) +"/"+ str(value));
    if (number == 74) { //C1  
      ms.changeHue(activeBeatSet, 0, float(value));
  } 
  if (number == 71) { //C2  
    ms.changeHue(activeBeatSet, 1, float(value));
  }
  if (number == 91) { //C3
    //parameters.set("eff fader", float(value) / 127);
    ms.changeHue(activeBeatSet, 2, float(value));
  }
  if (number == 93) { //C4
    //parameters.set("beat fader scale", 2 * float(value) / 127);
    parameters.set("master level", float(value) / 127);
  }
  if (number == 73) { //C5  
    //parameters.set("saturation", float(value) / 127);
    ms.changeFader(activeBeatSet, 0, float(value) / 127);
  }
  if (number == 72) { //C6
    ms.changeFader(activeBeatSet, 1, float(value) / 127);
  }
  if (number == 5) { //C7
    ms.changeFader(activeBeatSet, 2, float(value) / 127);  
  }
  if (number == 84) { //C8
    parameters.set("sensitivity",pow(10,float(value)/127*3));
    bd.setSensitivity((int) parameters.get("sensitivity"));
  }
  if (number == 7) { //C9
    ms.mixA = float(value) / 127;
  }
  if (number == 1) { //C17  
    parameters.set("strip pos", float(value) / 127);
  }
  if (number == 116) { //STOP  
    if(value == 127) effects.kill();
  }
  if (number == 117) { //PLAY  
    if(value == 127) effects.enabled = !effects.enabled;
  }
  if (number == 118) { //RECORD  
    if (value == 127) {
      beatsOn = !beatsOn;
      println("Beats: ", beatsOn);
    }
  }
  if (number == 113) { //RECYCLE  C10
    //if(value == 127) {}
  }
  if (number == 110) { // TRACK LEFT
    if (value == 127 && parameters.get("eff fader") > 0) {
      parameters.set("eff fader", parameters.get("eff fader") - 0.1);
    }
  }
  if (number == 111) { // TRACK RIGHT
    if (value == 127 && parameters.get("eff fader") < 1) {
      parameters.set("eff fader", parameters.get("eff fader") + 0.1);
    }
  }

}