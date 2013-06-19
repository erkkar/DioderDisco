class DioderDriver {
  int r,g,b;
  
  Serial serial;
  
  boolean dummyMode;
  
  DioderDriver(PApplet parent) {
    dummyMode = (parent == null);
    
    r = 0;
    g = 0;
    b = 0;
    
    try {
      String portName = Serial.list()[0];
      println(portName);
      serial = new Serial(parent, portName, 9600);
    } catch (Exception e) {   //gnu.io.PortInUse
      println("Dummy mode, no serial port in use!");
      dummyMode = true;
    }
  }
  
  void setColor(color c) {
    
    // Calculate rgb components
    r = (int) (c >> 16) & 0xFF;  // Faster way of getting red(c)
    g = (int) (c >> 8) & 0xFF;   // Faster way of getting green(c)
    b = (int) c & 0xFF;          // Faster way of getting blue(c)
    
    // Write to serial if connected
    if (!dummyMode) {
      serial.write(r);
      serial.write(g);
      serial.write(b);
    }
  }
};
