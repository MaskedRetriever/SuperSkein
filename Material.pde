// Material Class

class Material {
  String TypeName;
  float MeltTemp;
  float ExtrudeTemp;

  Material(String aString) {
    if(aString == "ABS") {
      TypeName=aString;
      MeltTemp=100.0;
      ExtrudeTemp=220.0;
    } else {
      TypeName=aString;
      MeltTemp=0;
      ExtrudeTemp=0;
    }
  }

  void setMeltTemp(float aFloat) {
    MeltTemp=aFloat;
  }
  void setExtrudeTemp(float aFloat) {
    ExtrudeTemp=aFloat;
  }

}
