//Configuration
//This class acts both as a writer for config.txt
//and as a storage space for all configuration variables.
//Ideally, if you create a new user-settable variable,
//it should be a member of this class and get a line in
//the configuration file.

//~config.txt, obviously

class Configuration {

  float PreScale;
  float XRotate;  
  String FileName;
  
  float PrintHeadSpeed;
  float LayerThickness;
  float Sink;
  int OperatingTemp;
  int FlowRate;
  
  
  //config values of last resort
  Configuration() {
    PreScale = 1.0;
    XRotate = 0;
    FileName="";  
    PrintHeadSpeed = 2000.0;
    LayerThickness = 0.3;
    Sink = 2;
    OperatingTemp = 220;
    FlowRate = 180;  
  }

  void Load(){
    String[] input = loadStrings("config.txt");
    int index = 0;
    while (index < input.length) {
      String[] pieces = split(input[index], '\t');
      if (pieces.length == 2) {
        if(pieces[0].equals("CONFIG_SCALE"))PreScale=Float.parseFloat(pieces[1]);  
        if(pieces[0].equals("CONFIG_STLFILE"))FileName=pieces[1];  
        if(pieces[0].equals("CONFIG_XROTATE"))XRotate=Float.parseFloat(pieces[1]);  
        if(pieces[0].equals("MACHINE_OPTEMP"))OperatingTemp=Integer.parseInt(pieces[1]);  
        if(pieces[0].equals("MACHINE_FLOWRATE"))FlowRate=Integer.parseInt(pieces[1]);  
        if(pieces[0].equals("CONFIG_SINK"))Sink=Float.parseFloat(pieces[1]);  
        if(pieces[0].equals("MACHINE_PRINTHEADSPEED"))PrintHeadSpeed=Float.parseFloat(pieces[1]);  
        if(pieces[0].equals("MACHINE_LAYERTHICKNESS"))LayerThickness=Float.parseFloat(pieces[1]);  
        
        
      }
      index=index+1;
    }
  }
  
  void Save(){
    output = createWriter("config.txt");
    output.print("CONFIG_SCALE\t" + PreScale + "\n");
    output.print("CONFIG_XROTATE\t" + XRotate + "\n");
    output.print("CONFIG_STLFILE\t" + FileName + "\n");
    output.print("MACHINE_OPTEMP\t" + OperatingTemp + "\n");
    output.print("MACHINE_FLOWRATE\t" + FlowRate + "\n");
    output.print("CONFIG_SINK\t" + Sink + "\n");
    output.print("MACHINE_PRINTHEADSPEED\t" + PrintHeadSpeed + "\n");
    output.print("MACHINE_LAYERTHICKNESS\t" + LayerThickness + "\n");
    
    output.flush();
    output.close();
  }

}


