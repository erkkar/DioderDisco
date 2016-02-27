#include <Adafruit_NeoPixel.h>
#define PIN 8
#define NLEDS 120

const int outR = 9;
const int outG = 11;
const int outB = 10;

const int READ_COUNT = 6;

int r, g, b;
int strip_mode, strip_pos, old_pos;
int strip_r, strip_g, strip_b;

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NLEDS, PIN, NEO_GRB + NEO_KHZ800);
 
void setup() {
  black();
  
  strip.begin();
  stripOff(); // Initialize all pixels to 'off'
  
  Serial.begin(9600); 
  
  r = 0;
  g = 0;
  b = 0;
  strip_r = 0;
  strip_g = 0;
  strip_b = 0;

  strip_mode = 1;
  strip_pos = 0;
  old_pos = -1;
}
 
void loop() {  

  while(Serial.available() < READ_COUNT);
  
  if (Serial.available() >= READ_COUNT) {
      r = Serial.read();
      g = Serial.read();
      b = Serial.read();
      strip_r = Serial.read();
      strip_g = Serial.read();
      strip_b = Serial.read();
      //strip_mode = Serial.read();
      //strip_pos = Serial.read();
  }
  
  setColor(r, g, b);
 
  switch (strip_mode) {
    case 0:
      stripOff();
      break;
    case 1:
      stripOn(strip_r, strip_g, strip_b);
      break;
    case 2:      
      stripOff();
      setPixel(int(float(strip_pos) / 255 * NLEDS), strip_r, strip_g, strip_b);
      break;
    default:
      stripOff();
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
