import processing.serial.*;

class DioderDriver {
  int r, g, b;
  int strip_mode;
  
  Serial serial;
  
  boolean dummyMode;
  
  DioderDriver(PApplet parent) {
    dummyMode = (parent == null);
    
    r = 0;
    g = 0;
    b = 0;
    strip_mode = 0;
    
    try {
      String portName = Serial.list()[0];
      println(portName);
      serial = new Serial(parent, portName, 9600);
    } catch (Exception e) {   //gnu.io.PortInUse
      println("Dummy mode, no serial port in use!");
      dummyMode = true;
    }
    
    update();
  }
  
  void update() {
    // Write to serial if connected
    if (!dummyMode) {
      serial.write(byte(r));
      serial.write(byte(g));
      serial.write(byte(b));
      serial.write(byte(strip_mode));
      serial.clear();
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
    if (!dummyMode) serial.stop();
  }
};
