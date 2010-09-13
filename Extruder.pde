// Extruder Class
import java.lang.Math;

class Extruder {
  int ToolNum;
  Material Filament;
  float ZThick;
  float Diameter;
  float FlowRate;

  Extruder() {
    ToolNum=0;
    Filament=new Material("ABS");
    Diameter=0.6;
    ZThick=0.37;
  }

  Extruder(int anInt) {
    ToolNum=anInt;
    Filament=new Material("ABS");
    Diameter=0.6;
    ZThick=0.37;
  }

  Extruder(int anInt, String aString) {
    ToolNum=anInt;
    Filament=new Material(aString);
    Diameter=0.6;
    ZThick=0.37;
  }

  void setDiameter(float aFloat) {
    Diameter=aFloat;
    if(ZThick>Diameter) {
      println("Z thickness greater than extruded diameter. Setting Z thickness to half diameter.");
      ZThick=Diameter/2;
    }
  }

  void setZThick(float aFloat) {
    if(aFloat<Diameter) {
      ZThick=aFloat;
    } else {
      println("Z thickness greater than extruded diameter. Setting Z thickness to half diameter.");
      ZThick=Diameter/2;
    }
  }

  void setFlowRate(float aFloat) {
    FlowRate=aFloat;
  }

  float calcWallWidth() {
    float freespace_area=PI*pow(Diameter/2,2);
    return(freespace_area/ZThick);
  }
}

