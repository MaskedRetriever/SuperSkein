// Slice Class
//
class Slice {
  
  ArrayList Lines;

  //Right now this is all in the constructor.
  //It might make more sense to split these
  //out but that's a pretty minor difference
  //at the moment.
  Slice(Mesh InMesh, float ZLevel) {
    
    ArrayList UnsortedLines;
    Line2D Intersection;
    UnsortedLines = new ArrayList();
    for(int i = InMesh.Triangles.size()-1;i>=0;i--)
    {
      Triangle tri = (Triangle) InMesh.Triangles.get(i);
      Intersection = tri.GetZIntersect(ZLevel);
      if(Intersection!=null)UnsortedLines.add(Intersection);
    }
    
    
    if(UnsortedLines==null)return;
        
    //Slice Sort: arrange the line segments so that
    //each segment leads to the nearest available
    //segment. This is accomplished by using two
    //arraylists of lines, and at each step moving
    //the nearest available line segment from the
    //unsorted pile to the next slot in the sorted pile.
    Lines = new ArrayList();
    Lines.add(UnsortedLines.get(0));
    int FinalSize = UnsortedLines.size();
    UnsortedLines.remove(0);

    //ratchets for distance
    //enddist2 exists to catch flipped lines
    float frontdist1, frontdist2, enddist1, enddist2;
    float mindist = 10000;

    int iNextLine;
    int iFirstLine = 0;

    float epsilon = 1e-6;
    
    Line2D FirstSeg = (Line2D) Lines.get(0);//Get First

    //while(Lines.size()<FinalSize)
    while(UnsortedLines.size()>0)
    {
      Line2D EndSeg   = (Line2D) Lines.get(Lines.size()-1);//Get last
      iNextLine = (Lines.size()-1);
      mindist = 10000;
      boolean doflip = false;
      boolean doprepend = false;
      for(int i = UnsortedLines.size()-1;i>=0;i--)
      {
        Line2D LineCandidate = (Line2D) UnsortedLines.get(i);
        enddist1   = mag(LineCandidate.x1-EndSeg.x2,   LineCandidate.y1-EndSeg.y2);
        enddist2   = mag(LineCandidate.x2-EndSeg.x2,   LineCandidate.y2-EndSeg.y2); // flipped
        frontdist1 = mag(LineCandidate.x2-FirstSeg.x1, LineCandidate.y2-FirstSeg.y1);
        frontdist2 = mag(LineCandidate.x1-FirstSeg.x1, LineCandidate.y1-FirstSeg.y1); // flipped
          
	if(enddist1<epsilon)
	{
	  // We found exact match.  Break out early.
	  doflip = false;
	  doprepend = false;
	  iNextLine = i;
          mindist = 0;
	  break;
	}

	if(enddist2<epsilon)
	{
	  // We found exact flipped match.  Break out early.
	  doflip = true;
	  doprepend = false;
	  iNextLine = i;
          mindist = 0;
	  break;
	}

	if(frontdist1<epsilon)
	{
	  // We found exact match.  Break out early.
	  doflip = false;
	  doprepend = true;
	  iNextLine = i;
          mindist = 0;
	  break;
	}

	if(frontdist2<epsilon)
	{
	  // We found exact flipped match.  Break out early.
	  doflip = true;
	  doprepend = true;
	  iNextLine = i;
          mindist = 0;
	  break;
	}

        if(enddist1<mindist)
        {
	  // remember closest nonexact matches to end
	  doflip = false;
	  doprepend = false;
          iNextLine=i;
          mindist = enddist1;
        }

        if(enddist2<mindist)
        {
	  // remember closest flipped nonexact matches to end
	  doflip = true;
	  doprepend = false;
          iNextLine=i;
          mindist = enddist2;
        }
      }

      Line2D LineToMove = (Line2D) UnsortedLines.get(iNextLine);
      if(doflip) {
        LineToMove.Flip();
      }
      if(doprepend) {
	FirstSeg = LineToMove;
        Lines.add(iFirstLine,LineToMove);
      } else {
        Lines.add(LineToMove);
	if(mindist>0) {
	  FirstSeg = LineToMove;
	  iFirstLine = Lines.size()-1;
	}
      }
      UnsortedLines.remove(iNextLine);
    }
  }
  



} 
