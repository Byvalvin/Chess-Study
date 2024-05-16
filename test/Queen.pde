// practice class(NOT PART OF PROJECT)

class Queen{
  float px; float py;
  
  float pw; float ph;
  Queen(float width_, float length_){
    px = width_/2; py = length_/2;
    pw = 25; ph = 2*pw;
  }
  
  void show(){
    
    
    //fill(bg_colour);
    
    fill(54);
    ellipse(px,py,pw,ph);
    
  }
}
