The model is authored by [Uri Wilensky](http://modelingcommons.org/?id=30). Further description can be found in the [NetLogo Modelling Commons](http://modelingcommons.org/browse/one_model/1574).

## WHAT IS IT?
This model is a visual demonstration of a standard sort algorithm called merge sort. The algorithm reorders, or permutes, n numbers into ascending order. This is accomplished by dividing the numbers into groups and then merging smaller groups to form larger groups. Order is maintained as the lists are merged so when the algorithm finishes there is only one sorted list containing all n items.

Note that it is possible to express merge sort in NetLogo much more concisely than is done in this model. Since this model aims to demonstrate the sort algorithm visually, the code is more complex than would be needed if the model only needed to sort the numbers.

## HOW IT WORKS
We start out with as many independent groups as we have elements. As the algorithm progresses through the list, it merges each adjacent pair of groups; thus, after each pass, the number of groups is halved.

To merge two groups:

Compare the first elements of the two groups to each other
Place the smallest/largest element (depending on the increasing-order? switch) of the two in a third group
Remove that element from its source group
Repeat until one of the source groups is empty
Place all of the remaining elements from the non-empty source group onto the end of the third group
Substitute, in place, the third group for the two source groups
We do this merge repeatedly for each set of two groups until there is only one group left. This final group is the original set of numbers in sorted order.

The number of steps required to sort n items using this algorithm is the ceiling of logarithm (base 2) of n. Each step requires at most n comparisons between the numbers. Therefore, the time it takes for the algorithm to run is about n log n. Computer scientists often write this as O(n log n) where n is how many numbers are to be sorted.

## HOW TO USE IT
Change the value of the NUMBER-OF-ELEMENTS slider to modify how many numbers to sort.

Pressing SETUP creates NUMBER-OF-ELEMENTS random values to be sorted.

STEP (1 ITEM) merges one number into its new group.

STEP (1 ROW) does one full round of group merges.

## THINGS TO NOTICE
Groups are represented by color. Numbers in the same group have the same color. When two groups merge, the numbers take the color of the smallest/largest element in the new group. Can you predict what would be the final color of all elements before starting?

Would merging more than two groups at a time lead to the elements getting sorted in fewer steps? Would this change make the algorithm any faster?

## THINGS TO TRY
We stated above that the algorithm will take at most a constant factor times n log n time to execute. Can you figure out why the constant factor is needed to make this statement accurate?

## EXTENDING THE MODEL
Can you make the elements draw their paths across the view?

There are many different sorting algorithms. You can find a few described at http://en.wikipedia.org/wiki/Sorting_algorithm. Try implementing the different sorts in NetLogo and use BehaviorSpace to compare them. Do different sorts perform better with different input sets (uniformly random, nearly sorted, reverse sorted, etc.)?

## NETLOGO FEATURES
This model uses lists extensively.

Note that NetLogo includes SORT and SORT-BY primitives; normally, you would just use one of these, rather than implementing a sort algorithm yourself. SORT arranges items in ascending order; SORT-BY lets you specify how items are to be ordered.

## HOW TO CITE
If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

Wilensky, U. (2005). NetLogo Merge Sort model. http://ccl.northwestern.edu/netlogo/models/MergeSort. Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.
Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.
COPYRIGHT AND LICENSE
Copyright 2005 Uri Wilensky.

