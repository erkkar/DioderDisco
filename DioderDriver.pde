import processing.serial.*;

class DioderDriver {
  int r, g, b;
  int strip_r, strip_g, strip_b;
  
  int strip_mode, strip_pos;
  
  Serial serial;
  
  boolean dummyMode;
  
  DioderDriver(PApplet parent) {
    dummyMode = (parent == null);
    
    r = 0;
    g = 0;
    b = 0;
    strip_r = 0;
    strip_g = 0;
    strip_b = 0;
    
    strip_mode = 1;
    
    try {
      String portName = Serial.list()[0];
      println(portName);
      serial = new Serial(parent, portName, 9600);
      serial.clear();
      serial.buffer(6);
    } catch (Exception e) {   //gnu.io.PortInUse
      println("Dummy mode, no serial port in use!");
      dummyMode = true;
    }
    
    update();
  }
  
  void update() {
    // Write to serial if connected
    if (!dummyMode) {
      serial.clear();
      serial.write(r);
      serial.write(g);
      serial.write(b);
      serial.write(strip_r);
      serial.write(strip_g);
      serial.write(strip_b);
      //serial.write(strip_mode);
      //serial.write(strip_pos);
      
      delay(5);
    }
  }
  
  void update(color c) {
    
    // Calculate rgb components
    r = (int) (c >> 16) & 0xFF;  // Faster way of getting red(c)
    g = (int) (c >> 8) & 0xFF;   // Faster way of getting green(c)
    b = (int) c & 0xFF;          // Faster way of getting blue(c)
    
    update();

  }
  
  void close() {
    if (!dummyMode) {
      serial.clear();
      serial.stop();
    }
  }
};