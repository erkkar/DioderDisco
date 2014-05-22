import processing.serial.*;
import cc.arduino.*;

class DioderDriver {
  
  Arduino arduino;
  
  boolean dummyMode;
  
  DioderDriver(PApplet parent) {
    dummyMode = (parent == null);
    
    try {
      String portName = Arduino.list()[0];
      arduino = new Arduino(parent, Arduino.list()[0]);
      println("Connected to Arduino at " + portName);
    } catch (Exception e) {   //gnu.io.PortInUse
      println("Dummy mode, no serial port in use!");
      dummyMode = true;
    }
    
    update(0, 0, 0);
  }
  
  void update(int r, int g, int b) {
    // Write to serial if connected
    if (!dummyMode) {
      arduino.analogWrite(9, r);
      arduino.analogWrite(11, g);
      arduino.analogWrite(10, b);
    }
  }
  
  void update(color c) {
    int r, g, b;
    
    // Calculate rgb components
    r = (int) (c >> 16) & 0xFF;  // Faster way of getting red(c)
    g = (int) (c >> 8) & 0xFF;   // Faster way of getting green(c)
    b = (int) c & 0xFF;          // Faster way of getting blue(c)
    
    update(r, g, b);

  }
  
  void close() {
  }
};
