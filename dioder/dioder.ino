const int outR = 9;
const int outG = 11;
const int outB = 10;

byte r, g, b;
 
void setup() {
  black();
  Serial.begin(9600); 
  r = 0;
  g = 0;
  b = 0;
}
 
void loop() {    
  if (Serial.available() >= 4) {
    r = Serial.read();
    g = Serial.read();
    b = Serial.read();
  }
  setColor(r, g, b);
  }
}

void setColor(byte _r, byte _g, byte _b) {
  analogWrite(outR, _r);
  analogWrite(outG, _g);
  analogWrite(outB, _b);
}

void black() {
  setColor(0, 0, 0);
}
