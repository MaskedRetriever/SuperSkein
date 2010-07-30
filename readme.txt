SuperSkein Manual

*Parameters
Currently, we're doing all the parameters with the godawful UI of having you type them in the first screen or so of code in the Processing sketch.  This is terrible but it's what we've got for now.

--->float PrintHeadSpeed = 2000.0;
The F parameter of the gcode.  Higher values make the extruder move more quickly.
(Skeinforge users take note, This is "FeedRate" in Skeinforge.)

--->float FlowRate = 255;
Plastic flow rate.  255 is the maximum speed.  Low values will not work and may jam your extruder!  On MakerBots I've used, values higher than 170 or so extrude.  Your results may vary.
NOTE NOT IMPLEMENTED YET 

--->float LayerThickness = 0.3;
Space between the layers, obviously.  This affects both where the slicer cuts and where the print head moves.  If you want to distort your model I recommend adding a non-proportion-constrained scale function to the Mesh class.


--->String FileName = "sculpt_dragon.stl";


**Modularity note
I think most of the things we'll do to the file are going to be clearly divided between things we do to the whole mesh or to individual layers.  I think rather than cluttering the SuperSkein.pde file we should make every effort to "push down" modifications to the objects they affect.



*Hacking NOTES


Things like the Sink function (lower the mesh so the bottom layer is big rather than small points, esp for character meshes) I don't know if I want them post-processing or pre-processing.

We've got to worry about time; if you run something in post, you're hacking gcode which is a real (SLOW!!) pain because of all that ASCII and file io.  If you do it before you slice, you can save a TON of hack time.  But then again, we keep introducing hazards to the overall modularity and flow.

(Actually now that I think about it doing ops to gcode might be 2/3 of why Skeinforge is so %$#$@ing slow.)

I don't like the idea of losing modularity.  That's probably a deal breaker.  But how much can we get away with?  Let's take a 10,000 ft look.

Functions like sink, they're natively mesh things.  Things which are mesh native we should go ahead and do to the mesh.  I think if we're at least clear about "mesh transforms" and "slice transforms" and "line transforms" we can steer clear of breaking things too bad.

SO WHAT ARE WE GOING TO DO TO THE MESH, YOU MAY ASK!

Okay, how about this:

*slicing
*skinning
*filling
*shelling
*mesh doctoring
*repositioning the mesh
*support material.... RAYS?  YIKES RAYS


Huh.  About support material.

We could definitely do raytracing.  It's really straight forward when you're z-axis aligned.  (Gosh, all the 3D is easy) Buuuuuuuuut it's volume-filling and not edge-defined, so, make a grid.  What you do there is you put dots on your slices (give them two array lists?  Or more perhaps...)