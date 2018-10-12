import opendmx.*;

class DmxDriver {
  
  int r, g, b;
  
  private int SIZE = 3;
  private byte[] data = new byte[SIZE];
  
  OpenDmx openDmx = null;
  
  // Constructor
  DmxDriver(int device_id) {
    
  try {
    openDmx = new OpenDmx(device_id);
  } catch (FTDIException e) {
    println(e);
    exit();
  } 
  print("Connected to DMX device", device_id);
  
  r = 0;
  g = 0;
  b = 0;

  update();
}

void update() {
  
  data[0] = byte(r);
  data[1] = byte(g);
  data[2] = byte(b);
  openDmx.sendData(data, SIZE);
}

void close() {
    r = 0;
    g = 0;
    b = 0;
    update();
    if (openDmx.close() == 0) {
      print("\nClosed DMX connection");
    }
}
};
  