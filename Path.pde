// Path Class

class Path2D {
  
  ArrayList pathArray;
  
  // constructor.
  // Initializes a new path object, with no path points.
  Path2D() {
    pathArray = new ArrayList();
  }


  // Adds a point to the end of the path.
  void addPoint(float X, float Y)
  {
    PVector pt = new PVector(X, Y);
    pathArray.add(pt);
  }


  // Adds a point to the end of the path.
  void addPoint(PVector pt)
  {
    pathArray.add(pt);
  }


  // Returns true if the path is a closed path.
  // A closed path is one that ends where it started.
  boolean isClosed()
  {
    if (pathArray.size() < 3) {
      return false;
    }
    PVector pt1 = (PVector)pathArray.get(0);
    PVector pt2 = (PVector)pathArray.get(pathArray.size()-1);
    return pt1.equals(pt2);
  }


  // Closes the path if it is not already closed.
  // A closed path is one that ends where it started.
  void close()
  {
    if (!this.isClosed()) {
      PVector pt = (PVector)pathArray.get(0);
      pathArray.add(pt);
    }
  }


  // If the point is inside the closed path, returns true.  False otherwise.
  // If the path is not closed, then returns false.
  boolean containsPoint(PVector testpoint)
  {
    if (!this.isClosed()) {
      return false;
    }
    if (pathArray.size() < 3) {
      return false;
    }
    PVector testpoint2 = new PVector(testpoint.x, testpoint.y+1e9);
    SSLine testline = new SSLine(testpoint, testpoint2);
    SSLine segment = new SSLine(0,0,0,0);

    int isectCount = 0;
    PVector pt2 = (PVector)pathArray.get(0);
    for (int i = 1; i < pathArray.size(); i++) {
      PVector pt1 = pt2;
      pt2 = (PVector)pathArray.get(i);
      segment.setPoint1(pt1);
      segment.setPoint2(pt2);
      if (segment.FindSegmentsIntersection(testline) != null) {
        if (!pt1.equals(testpoint)) {   // Last segments endpoint already matched.
	  isectCount++;
	}
      }
    }
    return ((isectCount & 0x1) == 1);  // return true if intersection count was odd.
  }


  // If the point is inside the closed path, returns true.  False otherwise.
  // If the path is not closed, then returns false.
  boolean containsPoint(float X, float Y)
  {
    PVector pt = new PVector(X, Y);
    return containsPoint(pt);
  }


  void reverse()
  {
    ArrayList nuPath = new ArrayList(pathArray.size());
    for (int i = pathArray.size()-1; i>=0; i++) {
      nuPath.add(pathArray.get(i));
    }
    pathArray = nuPath;
  }


  Path2D getReversed()
  {
    Path2D nuPath = new Path2D();
    for (int i = pathArray.size()-1; i>=0; i++) {
      nuPath.addPoint((PVector)pathArray.get(i));
    }
    return nuPath;
  }


  void reorderPoints(int newLeadPos)
  {
    int i;
    if (!this.isClosed()) {
      return;
    }
    if (pathArray.size() < 3) {
      return;
    }
    ArrayList nuPath = new ArrayList(pathArray.size());
    for (i = newLeadPos; i < pathArray.size()-2; i++) {
      nuPath.add(pathArray.get(i));
    }
    for (i = 0; i < newLeadPos; i++) {
      nuPath.add(pathArray.get(i));
    }
    nuPath.add(pathArray.get(0));
  }


  Path2D[] splitLoops()
  {
    ArrayList loops = new ArrayList();
    // TODO: finish this
    return (Path2D[])loops.toArray();
  }


}

