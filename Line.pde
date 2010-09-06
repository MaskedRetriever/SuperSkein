// Line Class
// Once we have the slices as 2D lines,
// we never look back.
// From this version (1.3ish?) SSLine will
// have both SPEED and PLASTIC FLOW RATE.
import java.awt.geom.Line2D;

class SSLine extends Line2D.Float {
  
//  float x1,y1,x2,y2;
  
  float HeadSpeed;
  float Flowrate;
  
  final float epsilon = 1e-6;
  
  SSLine(float nx1, float ny1, float nx2, float ny2) {
    super(nx1,ny1,nx2,ny2);
    HeadSpeed = 1000; //By default it at least does move.
    Flowrate = 0; //By default the plastic does not flow.
  }


  SSLine(PVector pt1, PVector pt2) {
    super(pt1.x,pt1.y,pt2.x,pt2.y);
    HeadSpeed = 1000; //By default it at least does move.
    Flowrate = 0; //By default the plastic does not flow.
  }
  
  
  void setPoint1(PVector pt) {
    x1 = pt.x;
    y1 = pt.y;
  }


  void setPoint2(PVector pt) {
    x2 = pt.x;
    y2 = pt.y;
  }


  PVector getPoint1() {
    return new PVector(x1,y1);
  }


  PVector getPoint2() {
    return new PVector(x2,y2);
  }


  void Scale(float Factor)
  {
    x1=x1*Factor;
    x2=x2*Factor;
    y1=y1*Factor;
    y2=y2*Factor;
  }


  void Flip()
  {
    float xn, yn;
    xn = x1;
    yn = y1;
    x1 = x2;
    y1 = y2;
    x2 = xn;
    y2 = yn;
  }

  
  void Rotate(float Angle)
  {
    float xn,yn;
    xn = x1*cos(Angle) - y1*sin(Angle);
    yn = x1*sin(Angle) + y1*cos(Angle);
    x1 = xn;
    y1 = yn;
    xn = x2*cos(Angle) - y2*sin(Angle);
    yn = x2*sin(Angle) + y2*cos(Angle);
    x2 = xn;
    y2 = yn;
  }

  void Translate(float tX, float tY)
  {
    x1 = x1 + tX;
    x2 = x2 + tX;
    y1 = y1 + tY;
    y2 = y2 + tY;
  }
  
  float Length()
  {
    return mag(y2-y1, x2-x1);
  }


  float RadianAngle()
  {
    return atan2(y2-y1, x2-x1);
  }
  
  
  PVector ClosestSegmentPointToXY(float px, float py)
  {
    float m, c, m2, c2, u;
    float xd, yd;
    PVector pt;

    xd = x2 - x1;
    yd = y2 - y1;
    if (abs(xd) < epsilon && abs(yd) < epsilon) {
      pt = new PVector(x1, y1);
      return pt;
    }
    u = ((px - x1) * xd + (py - y1) * yd) / (xd * xd + yd * yd);
    if (u < 0.0) {
      pt = new PVector(x1, y1);
    } else if (u > 1.0) {
      pt = new PVector(x2, y2);
    } else {
      pt = new PVector(x1 + u * xd, y1 + u * yd);
    }
    return pt;
  }


  PVector ClosestExtendedLinePointToXY(float px, float py)
  {
    float m, c, m2, c2, u;
    float xd, yd;
    PVector pt;

    xd = x2 - x1;
    yd = y2 - y1;
    if (abs(xd) < epsilon && abs(yd) < epsilon) {
      pt = new PVector(x1, y1);
      return pt;
    }
    u = ((px - x1) * xd + (py - y1) * yd) / (xd * xd + yd * yd);
    pt = new PVector(x1 + u * xd, y1 + u * yd);
    return pt;
  }


  float MinimumSegmentDistanceFromXY(float x, float y)
  {
    PVector pt = ClosestSegmentPointToXY(x, y);
    return mag(pt.y-y, pt.x-x);
  }


  // Returns the distance from the given XY point to the closest
  float MinimumExtendedLineDistanceFromXY(float x, float y)
  {
    PVector pt = ClosestExtendedLinePointToXY(x, y);
    return mag(pt.y-y, pt.x-x);
  }
  
  
  // Returns null if the two line segments don't intersect each other.
  // Otherwise returns intersection point as a PVector.
  // NOTE: coincident lines don't count as intersecting.
  PVector FindSegmentsIntersection(SSLine line2)
  {
    float dx1 = x2 - x1;
    float dy1 = y2 - y1;
    
    float dx2 = line2.x2 - line2.x1;
    float dy2 = line2.y2 - line2.y1;
    
    float dx3 = x1 - line2.x1;
    float dy3 = y1 - line2.y1;
    
    float d  = dy2 * dx1 - dx2 * dy1;
    float na = dx2 * dy3 - dy2 * dx3;    
    float nb = dx1 * dy3 - dy1 * dx3;
    
    if (d == 0) {
      //if (na == 0.0 && nb == 0.0) {
      //  return null;  // Lines are coincident.
      //}
      return null;  // No intersection; lines are parallel
    }
    
    float ua = na / d;
    float ub = nb / d;
    
    if (ua < 0.0 || ua > 1.0)
        return null;  // Intersection wouldn't be inside first segment

    if (ub < 0.0 || ub > 1.0)
        return null;  // Intersection wouldn't be inside second segment

    float xi = x1 + ua * dx1;
    float yi = y1 + ua * dy1;
    return new PVector(xi, yi);
  }


  // Returns null if the two extended lines are parallel.
  // Otherwise returns intersection point as a PVector.
  // NOTE: coincident lines don't count as intersecting.
  PVector FindExtendedLinesIntersection(SSLine line2)
  {
    float dx1 = x2 - x1;
    float dy1 = y2 - y1;
    
    float dx2 = line2.x2 - line2.x1;
    float dy2 = line2.y2 - line2.y1;
    
    float dx3 = x1 - line2.x1;
    float dy3 = y1 - line2.y1;
    
    float d  = dy2 * dx1 - dx2 * dy1;
    float na = dx2 * dy3 - dy2 * dx3;    
    float nb = dx1 * dy3 - dy1 * dx3;
    
    if (d == 0) {
      //if (na == 0.0 && nb == 0.0) {
      //  return null;  // Lines are coincident.
      //}
      return null;  // No intersection; lines are parallel
    }
    
    float ua = na / d;
    float ub = nb / d;
    
    float xi = x1 + ua * dx1;
    float yi = y1 + ua * dy1;
    return new PVector(xi, yi);
  }


  // Returns a SSLine of the current segment, if it were shifted
  // to the right by the given amount.
  SSLine Offset(float offsetby)
  {
    float ang = this.RadianAngle();
    float perpang = ang - HALF_PI;
    float nux1 = x1 + offsetby * cos(perpang);
    float nuy1 = y1 + offsetby * sin(perpang);
    float nux2 = x2 + offsetby * cos(perpang);
    float nuy2 = y2 + offsetby * sin(perpang);
    return new SSLine(nux1, nuy1, nux2, nuy2);
  }
  
  
  // Returns a PVector with the point where two joined lines would
  // intersect if both lines were offset to the right by the given
  // amount.  The end point of the first line segment must be the
  // exact same point as the start point of the second line.
  // Returns null if the two lines aren't joined.
  PVector FindOffsetIntersectionByBisection(SSLine line2, float offsetby)
  {
    if (x2 != line2.x1 || y2 != line2.y1) {
      return null;
    }
    SSLine offline1 = this.Offset(offsetby);
    SSLine offline2 = line2.Offset(offsetby);
    return offline1.FindExtendedLinesIntersection(offline2);
  }
}


