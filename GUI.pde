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
    noFill();
    stroke(255);
    strokeWeight(1);
    arc(x+4,y+4,8,8,PI,TWO_PI-PI/2);
    line(x+4,y,x+w-4,y);
    arc(x+w-4,y+4,8,8,TWO_PI-PI/2,TWO_PI);
    line(x+w,y+4,x+w,y+h-4);
    arc(x+w-4,y+h-4,8,8,0,PI/2);
    line(x+4,y+h,x+w-4,y+h);
    arc(x+4,y+h-4,8,8,PI/2,PI);
    line(x,y+4,x,y+h-3);
    
    //rect(x,y,w,h);
    
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



//Note, cursor is always at the end.
//One day maybe we'll fix this.
class GUITextBox{
  String Text;
  int x,y,w,h;
  boolean Focus;
  
  GUITextBox(int ix, int iy, int iw, int ih, String iText) {
    Focus = false;
    x=ix;
    y=iy;
    w=iw;
    h=ih;
    Text = iText;
  }
  
  boolean over(int ix,int iy)
  {
    if((ix>x)&(ix<(x+w)&(iy>y)&(iy<(y+h))))return true;
    else return false;
  }
  
  void display()
  {
    PFont font = loadFont("ArialMT-12.vlw");
    textAlign(LEFT);
    textFont(font);
    fill(0);
    stroke(200);
    strokeWeight(1);
    if(Focus)stroke(255);
    rect(x,y,w,h);
    fill(255);
    text(Text,x+2,y+12);
  }

  void doKeystroke(int KeyStroke)
  {
    if(Focus){
      if((KeyStroke==8)&(Text.length()>0))Text=Text.substring(0,Text.length()-1);
      if((KeyStroke>31)&(KeyStroke<177))Text = Text + char(KeyStroke);
    }
  }
  
  void checkFocus(int X, int Y)
  {
    if(this.over(X,Y))Focus=true;
    else Focus=false;
  }
  
  float getFloat()
  {
    return Float.parseFloat(Text);
  }
  
}


