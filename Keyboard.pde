// keyPressed
void keyPressed() {
  if (DEBUG) println("Key: " + int(key));
  if (key == 44) { //,
    parameters.set("strip mode", 1);
  }
  if (key == 46) { //.
    parameters.set("strip mode", 2);
  }
  if (key == 45) { //-  
   parameters.set("strip mode", 3);
  }
  if (key == 8) { // Backspace
   parameters.set("strip mode", 0);
  }
  if (key == 10) { // Enter
  }       
  if (key == 103) { //g
  }
  if (key == 97) { //a
    activeBeatSet = 'A';
  }
  if (key == 98) { //b
    activeBeatSet = 'B';
  }
  if (key == 122) { //z
    if (parameters.get("level part") > 0) {
      parameters.set("level part", parameters.get("level part") - 0.1);
    }
  }
  if (key == 120) { //x
    if (parameters.get("level part") < 1) {
      parameters.set("level part", parameters.get("level part") + 0.1);
    }
  } 
  // Switch LightThings on/off
  if (key == 48) { //0
  }
  if (key == 43) { //+
  }
  if (key >= 49 && key <= 57) { // 1...9
    //if (key - 49 <= beatSets.length) {
    //    if (activeBeatSet == "A") {
    //      ms.A = beatSets[key - 49];
    //    } else {
    //      ms.B = beatSets[key - 49];
    //    }
    //}
  }
  if (key == 112) { //p
//    preview = !preview;
//    if (preview) println("Preview ON"); else println("Preview OFF");
  }
  if (key == 114) { //r
//    beatSets = readBeatConfig();
  }
  if (keyCode == LEFT) {
    if (ms.mixA < 1) ms.mixA += 0.1;
    parameters.set("mix A", ms.mixA);
  }
  if (keyCode == RIGHT) {
    if (ms.mixA > 0) ms.mixA -= 0.1;
    parameters.set("mix A", ms.mixA);
  }
}


// keyReleased
void keyReleased() {   
  
}