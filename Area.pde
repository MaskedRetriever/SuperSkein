// SSArea class
import java.awt.geom.Area;

class SSArea extends Area {
  float GridScale;
  float HeadSpeed;
  float FlowRate;

  void SSArea() {
    GridScale=0.01;
    HeadSpeed=1000;
    FlowRate=0;
  }

  void setGridScale(float aGridScale) {
    GridScale=aGridScale;
  }
  float getGridScale() {
    return(GridScale);
  }

  void setHeadSpeed(float aHeadSpeed) {
    HeadSpeed=aHeadSpeed;
  }
  float getHeadSpeed() {
    return(HeadSpeed);
  }

  void setFlowRate(float aFlowRate) {
    FlowRate=aFlowRate;
  }
  float getFlowRate() {
    return(FlowRate);
  }

}
