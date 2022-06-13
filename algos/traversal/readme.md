The model is authored by [Jiri Lukas]. Further description can be found in the [NetLogo User Community Models](http://ccl.northwestern.edu/netlogo/models/community/Graph_search-DFS_and_BFS).

## WHAT IS IT?

This is an application that demonstrates 2 basic algortihms for traversing or searching tree or graph: The Depth-first search (DFS) algorithm and the Breadth-first search (BFS) algorithm.You can search any graph you create by simply adding vertices and edges in the GUI.

## HOW IT WORKS

Vertices are represented by agents with a circle shape and edges are represented by links between two agents(vertices). You can add as much vertices as you want, create links and then just run of these algorithms. It will show you the entire course of the algorithm.

## HOW TO USE IT

Setup - it delets all agents from the previous model, clears up the surface and set up the new model to run

Reset - it restores the searched graph to its original state, the roots remains unchanged

Add vertex - it allows you to add a vertex by clicking in the green window

Add edge - it adds an edge between two selected vertices. Click on one of the vertices, then the other and the edge itself adds

Remove vertex - it removes the selected vertex

Remove edge - it removes the selected edge. Click on one of the vertices, then the other and the edge between them will be removed

Relocate vertex - it allows you to move the vertices and make your graph easy on the eye

Pick root - it allows you to pick the root = starting vertex, from which the searching will start

Run BFS - it will launch the Breadth-first search algorithm

Run DFS - it will launch the Depth-first search algorithm

Most of these buttons also have their own hotkeys.

Slider delay allows you to change the delay between the individual steps of the algorithm.

The output window will show the course of the algorithm.

## EXTENDING THE MODEL

It would be great to allow the user to create the graph in the form of matrix and run the searching in this matrix.

You could also try to implement a method that would automatically relocate vertices and make the graph easy on the eye.

## NETLOGO FEATURES

There is used LIFO and FIFO data structure using primitives as lput, fput, but-first, but-last etc. There are also used links and mouse interaction.

## CREDITS AND REFERENCES

Author: Jiri Lukas
Email: jirilukas3@seznam.cz
Adress:
Street: Havlickova 628
Town: Mlada Boleslav
Zip code: 29301
State: Czech Republic
Continent: Europe
Facebook link: https://www.facebook.com/jiri.lukas.7?fref=ts