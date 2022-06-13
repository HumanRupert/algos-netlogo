The model is authored by [James Steiner](http://modelingcommons.org/?id=296). Further description can be found in the [NetLogo Modelling Commons](http://modelingcommons.org/browse/one_model/3375).

## WHAT IS IT?
A model to demonstrate a method of constructing a minumum (or maximum) spanning tree for a network using Kruskal's algorithm.

## HOW TO USE IT
Press RESET (this is done automatically when the model first loads) to generate a random network graph. Then graph is constructed using a method that guarantees the network will be one giant component, with a fair number of loops and such. Each edge in the graph is assigned a random weight in the range 1 to 100.

You can create multiple components by clicking "SPLIT"

Press find-spanning-tree to find the minimum-weight spanning tree of the graph. (if INVERT? is On, the maximum-weight spanning tree is found)

## HOW DOES IT WORK?
In typical NetLogo idiom, the network is contructed using turtles of breed "vertices" connected by an undirected-link-breed "edges"

find-spanning-tree uses Kruskal's Algorithm, with some enhancements to allow early exit from the algorithm as soon as all vertexes in the graph have been processed.

To use Kruskal's algorithm:

First the vertices are assigned to sub-trees. Each vertice begins assigned to its own unique subtree. The who number is used to provide sub-tree id numbers.

Next the edges are sorted by weight.

Then, for each edge, in order:

If end1 and end2 of the current edge are not already in the same sub-tree, then the edge belongs in the spanning tree. The edge is so marked (IN-TREE? is set to true). Now, end2 and all other vertices in the same subtree as end2 are assigned to the subtree of end1. The unique count of vertice touched by edges added to the spanning tree is kept.

If there is another edges to process, and not every vertex has been touched, the next edge is processed.

## SPECIAL TRICKS
This model features an in-view gui that is active even if no button is pressed. A monitor control (sort of hiding under the synch? switch) runs a procedure that updates the layout and detects mouse dragging and layout-properties sliders moving. Since monitors always run, and since NetLogo 4 updates the view if needed when only monitor code is running (prior NetLogos did not), we can have models that can start running (albeit in a slow mode) as soon as they load.

This could be useful for displaying instructions, displaying an "attract" mode to entice users to begin using the model, or, as in this case, to provide a more-or-less full-time in-view gui.

## CREDITS
Thanks to Jim Lyons for his very clean implementation of Kruskal's algorithm, as described in [[ http://en.wikipedia.org/wiki/Kruskal's_algorithm ]], and dirted-up by me.

Quote:

 * create a forest F (a set of trees),
   where each vertex in the graph is a separate tree
 * create a set S containing all the edges in the graph
 * while S is nonempty
   o remove an edge with minimum weight from S
   o if that edge connects two different trees, then add it to the forest,
     combining two trees into a single tree
   o otherwise discard that edge
Of course, I had to go clutter it up, but the essense is there. I just didn't get the combining the forests and trees thing, that makes the whole thing so elegent and zippy.