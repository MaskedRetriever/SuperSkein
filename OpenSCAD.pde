// OpenSCAD Wrapper Functions.

class OpenSCAD {

  String execPath;
  String execArgs;
  String inputFile;
  String outputType;
  String outputFile;

  OpenSCAD() {
    execPath="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD";
    execArgs="-D render_select=0 -D slice_index=0";
    outputType=DXF;
    outputFile="output.dxf";
  }

  OpenSCAD(String iexecPath, String iexecArgs) {
    execPath=iexecPath;
    execArgs=iexecArgs;
  }

  void setInput(String iinputFile) { inputFile=iinputFile; }
  void setExecArgs(String iexecArgs) { execArgs=iexecArgs; }
  void setExecPath(String iexecPath) { execPath=iexecPath; }
  void setOutput(String ioutputType, String ioutputFile) {
    if( ioutputType==DXF ) {
      outputType=ioutputType;
      outputFile=ioutputFile;
    }
  }
  String getInput() { return(inputFile); }
  String getExecArgs() { return(execArgs); }
  String getExecPath() { return(execPath); }

  boolean run() {
    String commandLine=execPath;
    if(outputType==DXF) {
      commandLine=commandLine+" -x "+outputFile+" "+execArgs;
    }
    if(!inputFile.equals("")) {
      try {
        commandLine+=" "+inputFile;
        Runtime rtime = Runtime.getRuntime();
        print("Command Line: "+commandLine+"\n");
        Process child = rtime.exec(commandLine);
        child.waitFor();
	return(true);
      } catch (Exception e) {
        e.printStackTrace();
	return(false);
      }
    } else {
      return(false);
    }
  }
}

