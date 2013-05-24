class LightThing 
{
  float size;
  float fader;
  int minSize, maxSize;
  int hue;
  
  // Constructor
  LightThing() 
  {
    
  }
  
  void setup(int hue, float fader, int minSize, int maxSize) 
  { 
    this.hue = hue;
    this.fader = fader;
    this.minSize = minSize;
    this.maxSize = maxSize;
  }
  
  // Fader
  void fade() 
  {
    size = (int) constrain(size * fader, minSize, maxSize); 
  }
  
  // Updater
  void update() 
  {
    fade();
  }
}


class KickThing extends LightThing
{ 
  void update()
  {
    super.fade();
    if ( beat.isKick() ) size  = maxSize;
  }
}

class SnareThing extends LightThing
{
  void update()
  {
    super.fade();
    if ( beat.isSnare() ) size  = maxSize;
  }
}

class HatThing extends LightThing
{
  void update()
  {
    super.fade();
    if ( beat.isHat() ) size  = maxSize;
  }
}
