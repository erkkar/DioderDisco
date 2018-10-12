import opendmx.*;

class DmxDriver {
  
  int r, g, b;
  int level;
  
  private int SIZE = 4;
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
  level = 0;

  update();
}

void update() {
  
  data[0] = byte(r);
  data[1] = byte(g);
  data[2] = byte(b);
  data[3] = byte(level);
  openDmx.sendData(data, SIZE);
}

void setLevel(float fraction) {
  level = int(fraction * 255);
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
  