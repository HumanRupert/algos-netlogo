# bai-cs2-algos

The repository, once completed, will include the sample code and agent-based models of the algorithms taught in the Computer Science – Module 2 of the Mathematical and Computing Sciences for Artificial Intelligence course.

## What's an algorithm?
Algorithms are ways to teach stupid computers to do smart things. They are, more formally, a set of clear and objective procedures that should be taken to solve a particular problem or make a computation. Humans use algorithms in their everyday life as well. One algorithm that we're all familiar with is the [long multiplication method](https://www.splashlearn.com/math-vocabulary/multiplication/long-multiplication).

## What's an agent-based model?
A computational model is a program that uses algorithmic and computational resources to simulate a phenomenon or a system. An agent-based model is a computational model that uses intelligent agents as its main tool for problem-solving. We can further clarify all these convoluted definitions with a simple example.

Assume we want to compute the equilibrium state of an ecosystem made of wolves, sheep, and grass, that is, to find the limit to infinity of the number of agents from each breed. An agent-based model to solve this problem would include a world made of three types of agents, where sheep and wolves wander around randomly. If the sheep see grass, they eat it and gain +5 energy points (EP), while they're eaten by the wolves for +10 EP. Animals lose 1 EP for moving one tile. Once an animal's EP reaches 20, it reproduces by hatching a new agent of the same breed and loses 20 EPs. An animal dies 30 seconds after birth or when its EP goes to zero. The grass automatically regrows 3% of the time. What will be the equilibrium state of this world? Solving the problem analytically would be quite difficult, if not impossible. However, there are agent-based models that run the simulation very quickly. An example of such model is the [Sheep Wolf Predation](http://www.netlogoweb.org/launch#http://ccl.northwestern.edu/netlogo/models/models/Sample%20Models/Biology/Wolf%20Sheep%20Predation.nlogo) in NetLogo.

Agent-based models usually rely on Monte-Carlo methods, which, in layman's terms, means they repeat a probabilistic experiment many times to identify deterministic aspects of the system. For example, in the predation model, the randomness of the regrowth of grass could change the outcome of the experiment every time. Mote-Carlo methods rely on the simplicity of re-running the simulation and the law of large numbers to obtain results.

[NetLogo](https://ccl.northwestern.edu/netlogo/), designed by Uri Wilensky and developed at the Center for Connected Learning and Computer-Based Modelling for the Northwestern University, is a programming language and IDE for agent-based modelling that uses turtles, patches, and links to build a simulation or model.

<img width="877" alt="Screen Shot 2022-06-13 at 22 03 08" src="https://user-images.githubusercontent.com/46029474/173416504-1f94f574-7bca-4922-b3ba-3764a4c9171f.png">


## Contribution Guidelines
Create a subfolder for your algorithm in the /algos folder. The folder must include a `model.nlogo` file, a `model.html` file, and a `readme.md`. Export the NetLogo Web version of your model and put it in the `model.html`. Provide an intuitive and theoretical explanation for the algorithm you implemented in the readme file. It's generally a good idea to follow the NetLogo style guide while coding.

## To-Do List
- [ ] Depth First Search (DFS)
- [ ] Breadth First Search (BFS)
- [ ] Karger's Min-Cut
- [ ] Dijkstra's SSSP
- [ ] Huffman Coding
- [ ] Ford-Fulkerson Algorithm
- [ ] Edmonds-Karp Algorithm
- [ ] Kosaraju's Algorithm
- [ ] Tarjan's Algorithm for SCCs
- [ ] Mergesort
- [ ] Binary Search
- [ ] Heapsort
- [ ] Kuhn's Toposort
- [X] Kruskal's MST
- [ ] Prim's MST
