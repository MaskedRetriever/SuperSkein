// GUI Classes

class GUIButton {
  
  int x,y,w,h;
  String title;
  boolean Focus;
  boolean Pressed;
  PFont font;
  
  GUIButton(int ix, int iy, int iw, int ih, String ititle) {
    Focus = false;
    Pressed = false;
    x=ix;
    y=iy;
    w=iw;
    h=ih;
    title = ititle;
    
  }
  
  void display()
  {
    font = loadFont("ArialMT-12.vlw");
    fill(0);
    stroke(255);
    strokeWeight(1);
    rect(x,y,w,h);
    
    fill(255);
    textAlign(CENTER);
    textFont(font);
    text(title,x+w/2,(y+h/2)+6);
  }
  
  boolean over(int ix,int iy)
  {
    if((ix>x)&(ix<(x+w)&(iy>y)&(iy<(y+h))))return true;
    else return false;
  }
  
}  

//Value is between 0 and 1
//Value set to >1 becomes a DONE bar.
class GUIProgressBar {
  
  float Value;
  int x,y,w,h;
  String Mesg;
  
  GUIProgressBar(int ix, int iy, int iw, int ih){
    Value = 0;
    x=ix;
    y=iy;
    w=iw;
    h=ih;
    Mesg = "";
  }

  void update(float nValue)
  {
    Value = nValue;
  }
  
  void display()
  {
    PFont font;
    font = loadFont("ArialMT-12.vlw");
    textAlign(CENTER);
    textFont(font);

    if(Value<1)
    {
      fill(0,0,200);
      rect(x,y,w*Value,h);
      fill(255);
      //if(Value>0.01)text("Working...",x+w/2,(y+h/2)+6);
    }
    else
    {
      fill(0,200,0);
      rect(x,y,w,h);

      fill(255);
      Mesg="Done!";
      //text("Done!",x+w/2,(y+h/2)+6);
    }
    stroke(255);
    strokeWeight(1);
    noFill();
    rect(x,y,w,h);
    text(Mesg,x+w/2,(y+h/2)+6);
  }
  
  void message(String input)
  {
    Mesg=input;
  }
}

