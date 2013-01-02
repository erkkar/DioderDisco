class DioderDriver {
  int r,g,b;
  
  Serial serial;
  
  boolean dummyMode;
  
  DioderDriver(PApplet parent) {
    dummyMode = (parent == null);
    
    r = 0;
    g = 0;
    b = 0;
    
    if (!dummyMode) {
      String portName = Serial.list()[0];
      serial = new Serial(parent, portName, 9600);
    }
  }
  
  void update() {
    if (!dummyMode) {
      serial.write(r);
      serial.write(g);
      serial.write(b);
    }
  }
};
