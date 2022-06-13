;; summary: A minimal spanning tree is not a narrow evergreen.
;; copyright: Copyright � 2007, James P. Steiner

globals
[ dragged ;; used by mouse-gui code
  oldpull ;; used to synch the layout properties sliders
  oldpush ;; used to synch the layout properties sliders
  gui-message ;; used by the mouse and animate code
]

undirected-link-breed [ edges edge ]
edges-own
[ weight   ;; the weight of this edge
  in-tree? ;; in this edge in the spanning tree?
]

breed [ vertices vertex ]
vertices-own
[ subtree ;; the ID of the component that this vertex belongs to
  tested? ;; in the current detection, has this vertex been tested yet?
  old-avg-link-len
  new-avg-link-len
  old-x
  old-y
]

to startup setup end

to setup
   ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  clear-all

  setup-patches
  ; no-display
  setup-network
  ; display
  ;; now that the network is created,
  ;; auto-layout the network for a short time
  ;; hopefully to make is more attractive
  layout-for-seconds 1
  reset-ticks
end 

to layout-for-seconds [ $seconds ]
   let t timer + $seconds
   while [ timer < t ] [ layout-spanning-tree ]
end 

to go
   ;; do the main kruskal thing
   vis-network-spanning-tree-only
   kruskal-spanning-tree
   vis-network-show-all
   layout-for-seconds 1
end 

to setup-network
   ;; create a number of vertices
   ;; connect them into a single component
   ;; apply weights to the edges
   set-default-shape vertices "circle"
   create-vertices vertex-count
   [ set size 1.0
     setxy random-xcor random-ycor
     set color 15 + 10 * (who mod 12)
     ;; apply default value for subtree id
     set subtree who
     ;; apply default value for spanning tree flag
     set tested? false
     if who > 0
     [ ;; get the set of vertices that this vertex might link with
       let candidates vertices with [ who < [ who ] of myself ]
       ;; pick a number of edges to make
       let edge-count 2 + random 3
       ;; can't make more edges than there are vertices
       ;; so fix number of edges so that it does not exceed
       ;; available number of vertices
       ;; (in this simple implementation,
       ;; vertices are created first, so
       ;; are numbered from 0 - up, and bear
       ;; consecutive numbers, so
       ;; (who - 1) is the number of vertices available
       ;; to make edges with this vertex.
       set edge-count min (list edge-count (who - 1) )

       ;; address the desired quantity of randomly selected vertexes
       ;; and make them make links with this vertex
       ask n-of edge-count candidates
       [ create-edge-with myself
         [ ;; apply default value for spanning tree flag
           set in-tree? false
           ;; apply weight to the edge
           set weight (1 + random 100)
           set thickness 0
           set label weight
           set label-color black
         ]
       ]
     ]
   ]
end 

to setup-patches
   ;; color the background in an attractive pattern
   ask patches [ set pcolor checkered 5 blue 3 .5 ]
end 

to-report checkered [ $size $hue $tint $diff] ;; patch / turtle reporter
   ;; report a color to the calling patch
   ;; this formula produces a checker-board (chess-board) pattern
   ;; of light and tints of the given color
   ;; hue = base color
   ;; tint = base tint of that color (-5...4.9)
   ;; diff = difference between the base tint and the lighter shade
   report ( $hue + $tint + $diff * (((floor(pxcor / $size)  + floor(pycor / $size) )) mod 2 ) )
end 

to JPS-spanning-tree-not-really-kruksal
   ; no-display
   ask edges [ set in-tree? false ]
   ask vertices [ set tested? false ]
   let sorted-edges sort-by [ [?1 ?2] -> [ weight ] of ?1 > [ weight ] of ?2 ] edges
   if invert? [ set sorted-edges reverse sorted-edges ]

   let verts-to-test vertices with [ any? my-edges ]

   foreach sorted-edges
   [ ?1 -> ask ?1
     [ ;; does this edge make a loop in the tree-so-far?
       ;; i.e. are both of its vertices already in the tree?
       ifelse ( in-loop? nobody end1 end2 )
       [ ;; yes. skip it.
       ]
       [ ;; no. add it to the tree
         set in-tree? true
         ask both-ends with [ not tested? ]
         [ set tested? true
           set verts-to-test verts-to-test - 1
         ]
       ]
     ]
     ;; once all vertices have been tested once, we are done.
     ;; remaining untested edges must form loops
     if verts-to-test <= 0 [ stop ]
   ]
end 

to kruskal-spanning-tree
   ;; identifies the vertices that compose the minimum (or max, if inverted) spanning tree(s)
   ;; for the network made of up the vertices and edges currently in existence

   ;; Note that if graph is not a single component,
   ;; then the results will be all the spanning trees for each component.

   ;; edges in the spanning tree are marked with in-tree? = true
   ;; vertices that have been processed and placed in a tree are marked in-tree? = true
   ;;

   ; no-display

   ;; reset the testing flag for the vertices
   ;; place each vertex in its own sub-tree
   ask vertices
   [ set tested? false
     set subtree who
   ]

   ;; reset the in-tree flag for the edges
   ask edges
   [ set in-tree? false
   ]

   let sorted-edges []

   ;; sort low to high
   set sorted-edges sort-on [ weight ] edges
   if invert? [ set sorted-edges reverse sorted-edges ]

   ;; store the number of vertices with edges
   let verts-to-test count ( vertices with [ any? my-edges ] )

   if slow? and not netlogo-web? [ vis-network-spanning-tree-only ]

   foreach sorted-edges
   [ ?1 -> ;; once all verts with edges have been placed in trees (and thus subtrees merged, as needed),
     ;; ...this loop is done.
     ;; any remaining edges are (by definition) loops, since they must connect
     ;; vertices that are already in the same tree

     ;; are there any connected vertices not accounted for?
     if verts-to-test >= 0
     [ ;; yes. so lets process this edge
       ask ?1
       [ ;; get subtrees of the endpoints
         let subtree-1 [subtree] of end1
         let subtree-2 [subtree] of end2
         ;; compare them. are they in different sub-trees?
         if subtree-1 != subtree-2
         [ ;; yes! (no loop is formed)
           ;; this edge in in the spanning tree--mark it
           set in-tree? true
           ;; mark one or both verts (which ever is not already in a spanning tree)
           ;; as being in a tree and
           ;; decrement the counter of connected vertices yet to be discovered
           ask both-ends with [ tested? = false ]
           [ set tested? true
             set verts-to-test verts-to-test - 1
           ]
           ;; "merge the forests"
           ;; i.e. connect the entire set of vertices in subtree 2 to subtree 1.
           ;; this is accomplished by assiging subtree 1 to the subtree variable
           ;; of all vertices in subtree 2.
           ;; # one way to do that is to use a one-line with-clause:
           ;; ----  ask vertices with [ subtree = subtree-2 ][set subtree subtree-1 ]
           ;; but that address all the vertices, every time we merge a subtree.
           ;; whether we are adding 1 vertice to the subtree or a hundred.
           ;; in a large network, that seems like a lot of extra work.
           ;; # another way to do it is to start with the subtree 2 end-point,
           ;; and traverse the spanning sub-tree away from the subtree 1 end-point
           ;; putting the vertices into the subtree as we go along
           ;; this is a lot more code, even if done recursively.
           ;; this is a non-recursive implementation.
           ;; for smaller networks, its not very efficient,
           ;; but luckily, that doesn't seem to matter as much
           ;; for larger networks, I think it is more efficient.

           ;; flow through the vertices in subtree-2, assigning them to subtree 1
           ;; ## need to test speed ##
           ask vertices with [ subtree = subtree-2 ][set subtree subtree-1 ]
           ;ask end2
           ;[ ;; assign to subtree 1
           ;  set subtree subtree-1
           ;  ;; get set of subtree 2 vertices
           ;  let connected-vertices edge-neighbors with [ subtree = subtree-2 ]
           ;  ;; if any, assign them to subtree 1, get next set
           ;  while [ any? connected-vertices ]
           ;  [ ask connected-vertices [ set subtree subtree-1 ]
           ;    set connected-vertices (turtle-set [ edge-neighbors with [ subtree = subtree-2 ] ] of connected-vertices)
           ;  ]
           ; ]
         ]

         ;; run-slowly mode is eye-candy to show the edges
         ;; being connected to the spanning-tree one by one

         if slow? and not netlogo-web? and in-tree?
         [ vis-display-edge false ; color the edge
          repeat 100 [ layout-spanning-tree  display ]
         ]
       ]
     ]
   ]
end 

to-report in-loop? [ a b c]
   ;; a recursive procedure to detect if an edge between node B and C
   ;; will form a loop in the network that contains A B and C.
   ;; Node A starts out as nobody, and B is passed as A in recursive calls.
   ;; this lets us remember the direction B is coming from as we recursively
   ;; traverse the network, and prevents the traversal from backing up.

   let result false
   ask b
   [ ;; get set of b's edges that are in the tree
     let tree-edges my-edges with [ in-tree? ]
     ifelse not any? tree-edges
     [ ;; if no edges from b in the tree, no loop!
       set result false ]
     [ ;; get set of b's vertices attached to b's in-tree edges,
       ;; that are NOT edges back the way we came (back to a)
       ;; these may be routes futher along the tree
       let tree-verts (turtle-set [ other-end ] of tree-edges) with [ self != a ]
       ifelse not any? tree-verts
       [ ;; if no way out of here, no loop!
         set result false
       ]
       [ ;; are any of these vertices that might be routes out of here
         ;; actually C?
         ifelse any? tree-verts with [ self = c ]
         [ ;; yes! egad! we've found a loop back to C!
           set result true
         ]
         [ ;; search further along these routes
           ;; see if any of them lead to c
           ifelse any? tree-verts with [ in-loop? b self c ]
           [ set result true ]
           [ set result false ]
         ]
       ]
     ]
   ]
   report result
end 

to vis-network-center
   ;; attempts to center the network in the view
   ;; then scale the graph to fill the view.
   ;; doesn't work as expected...
   ;; ## abandoned pending further work ##
   let cx  mean [ xcor ] of vertices
   let cy  mean [ ycor ] of vertices
   ask vertices [ carefully [ setxy (xcor - cx) (ycor - cy) ][]]
end 

to vis-network-scale
   stop
  let max-x  max [ abs xcor ] of vertices
   let max-y  max [ abs ycor ] of vertices
   let max-v  max list max-x max-y
   let scale  max-pxcor / max-v
   ask vertices [ carefully [ setxy xcor * scale ycor * scale ][]]
end 

to vis-network-rotate
  stop
  ask vertices
   [ facexy 0 0
     lt 90
     let d .1 * patch-size * distancexy 0 0 / world-width
     if can-move? d [ jump d ]
   ]
end 

to vis-display-edge [ show-only-tree? ]
   let pixel 1 / patch-size
   ;; modifies the display parameters of a single edge
   ifelse in-tree?
   [ set color green - 2  set label weight set hidden? false
   ]
  [ set color [ 128 0 0 50 ] ;
    set label weight set hidden? show-only-tree?
   ]
   ifelse in-tree? [ set thickness 2 * pixel ] [ set thickness 0 ]
end 

to vis-network-show-all
   ;; modifies edge and vertice display parameters
   ;; to show all the edges
   ask edges [ vis-display-edge false ]
   ask vertices [ set label "" hide-turtle ]
end 

to vis-network-spanning-tree-only
   ;; modifies edge and vertice display parameters
   ;; to show only the discovered spanning tree
   ;; if no spanning tree has been found yet,
   ;; all the edges are hidden
   ask edges [ vis-display-edge true ]
   ask vertices [ set color 15 + 10 * (who mod 12) set size 2 set label "" show-turtle ]
end 

to split-network-on-y-axis
   ;; delete edges along the y axis, thus turning a giant component
   ;; into at least 2 smaller component.
   ;; depending on the topology of the current network
   ;; may create 2 or more components,
   ;; as well as any number of unconnected vertices

   ;; first, scale and center the graph
   vis-network-center
   vis-network-scale

   ;; find edges that have one vertex to the left of y-axis (x < 0)
   ;; and the other vertex on or to the right of y-axis (x >= 0)
   ;; kill those vertices.
   ;; this will split the network into at least two components
   ;; and may create orphan vertices
   ask edges with [     first sort ([ xcor] of both-ends) < 0
                    and last sort ([ xcor] of both-ends) >= 0 ]
   [ die ]
end 

to-report limitx [ xx ]
   ;; report an xcor, making sure it is within the view limits
   report ( max ( list min-pxcor min ( list max-pxcor xx ) ) )
end 

to-report limity [ yy ]
   ;; report a ycor, making sure it is within the view limits
   report ( max ( list min-pycor min ( list max-pycor yy ) ) )
end 

to vis-network-color
   ;; does two things
   ;; pretty-colors the graph,
   ;; but also does a thing where it finds two endpoints with the largest possible number of hops between them.
   ;; more than one longest route can exist--this procedure finds one of them, and
   ;; will randomly select among them
   if not any? edges with [ in-tree? = true ]
   [ go ]
   let depth 1
   ask vertices [ set color 0 ]
   ask edges [ set color 0 ]
   ask one-of (vertices with [ count my-edges with [ in-tree?] = 1 ]);  [ who ]
   [ trav-set-color depth ]

   let bus-end-1 max-one-of vertices [ label ]
   let max-depth-1 [ label ] of bus-end-1


   set depth 1
   ask vertices [ set color 0 set size .5 ]
   ask edges [ set color 0 ]
   ask bus-end-1 [ trav-set-color depth ]

   let bus-end-2 max-one-of vertices [ label ]
   let max-depth-2 [ label ] of bus-end-2

   set depth 1
   ask vertices [ set color 0 set size .5 ]
   ask edges [ set color 0 ]
   ask bus-end-2 [ trav-set-color depth ]

   set bus-end-1 max-one-of vertices [ label ]
   set max-depth-1 [ label ] of bus-end-2


   ask bus-end-1 [ set size 3 ]
   ask bus-end-2 [ set size 3 ]
end 

to trav-set-color [ depth ]
   ;; traverse the graph, setting colors and incrementing a counter as we go.
   set color 5 + 10 * depth
   set label depth
   ask my-edges with [ in-tree? and color = 0 ]
   [ set color 5 + 10 * depth
     set label depth
     ask other-end
     [ if color = 0
       [ trav-set-color depth + 1 ]
     ]
   ]
end 

to layout-spanning-tree
  layout-spanning-tree-basic
end 

to layout-spanning-tree-basic
   let $rod layout-length
   ;; auto-layout the spanning tree
   ifelse not any? edges with [ in-tree? = true ]
   [
     layout-spring vertices (edges) layout-pull $rod layout-push
   ]
   [
     layout-spring vertices (edges with [ in-tree? = true ]) layout-pull $rod layout-push
   ]
   vis-network-center
   vis-network-scale
   vis-network-rotate
end 

to layout-spanning-tree-button
  if netlogo-web? [ stop ]
   layout-spanning-tree
   monitor-mouse
   set gui-message ""
end 

to-report background-animate
   monitor-push-pull
   ifelse ( background-animate? )
   [
     ;; run by a monitor, this procedure monitors some gui events
     ;; and handles them, even when no buttons are pressed
     ifelse gui-message = ""
     [ set gui-message "idle" ]
     [ layout-spanning-tree
       display
       monitor-mouse
       display
       set gui-message "active"
       display
     ]
     report gui-message
   ]
  [ report "idle" ]
end 

to monitor-mouse
   ;; detect and perform dragging of vertice in the view with the mouse
   ifelse is-vertex? dragged
   [ ifelse mouse-down?
     [ ask dragged [ setxy mouse-xcor mouse-ycor ask link-neighbors [ set color white ] ]
     ]
     [ ask dragged [ setxy mouse-xcor mouse-ycor ask link-neighbors [ set color 15 + 10 * (who mod 12) ] ]
       set dragged nobody
     ]
   ]
   [ if mouse-down?
     [ ask patch mouse-xcor mouse-ycor
      [ set dragged one-of vertices in-radius ( 20 / patch-size) ]
     ]
   ]
end 

to monitor-push-pull
   ;; if in synch mode, watch the layout push and pull sliders for changes
   ;; if either slider changes, change the other slider to match
   ( if-else
     ( synch? and layout-push != oldpush )
     [ set oldpush layout-push
       set layout-pull layout-push
       set oldpull layout-pull
     ]
     ( synch? and layout-pull != oldpull )
     [ set oldpull layout-pull
       set layout-push layout-pull
       set oldpush layout-push
     ]
   )
end 

; ask vertices [ let x (sum [ weight ] of my-edges with [ in-tree? ]) set size min (list 3 (x * .5)) set label precision x 2 ]
