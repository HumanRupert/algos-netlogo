breed [vertices vertex]

globals [
  highlighted-vertices   ;; auxiliary variable for adding/removing edges
  id-highlighted         ;; -||-, represents the other end of the edge
  FIFO                   ;; data structure for BFS algorithm
  LIFO                   ;; data structure for DFS algorithm
  ]

turtles-own [
  root?                  ;; whether the vertex is root or not
  ]


to setup
  ca
  set highlighted-vertices 0
  set id-highlighted 0
  set FIFO []
  set LIFO []
  ask patches [set pcolor green + 2]
end

to go-BFS
  if not any? vertices [
    user-message "You need first to create a graph to do this activity"
    stop
    ]
  if not any? turtles with [root?] [
    user-message "Choose root first"
    stop
  ]
  reset
  wait delay
  set FIFO lput turtles with [root?] FIFO
  ask first FIFO [set color orange wait delay]
  run-BFS
end

;Breadth-first search
to run-BFS
  ask first FIFO [
    foreach sort-by [ [?1 ?2] -> [who] of ?1 < [who] of ?2 ] link-neighbors with [color != orange][ ?1 ->
      ask ?1 [
        set color orange
        set FIFO lput ?1 FIFO
        ask first FIFO [
          ask link-with ?1 [
            set color blue
            set thickness 1
            output-print (word ([who] of end1 + 1) " -> " ([who] of end2 + 1))
          ]
        ]
        wait delay]
    ]
  ]
  set FIFO but-first FIFO
  if not empty? FIFO [run-BFS]
end

to go-DFS
  if not any? vertices [
    user-message "You need first to create a graph to do this activity"
    stop
    ]
  if not any? turtles with [root?] [
    user-message "Choose root first"
    stop
  ]
  reset
  wait delay
  set LIFO lput turtles with [root?] LIFO
  ask last LIFO [set color orange wait delay]
  run-DFS
end

;Depth-first search
to run-DFS
  ask last LIFO [
    if not any? link-neighbors with [color != orange] [set LIFO but-last LIFO stop]
    let i min-one-of (link-neighbors with [color != orange]) [who]
    ask min-one-of (link-neighbors with [color != orange]) [who]
    [
      set color orange
      set LIFO lput i LIFO
      ask item ((position i LIFO) - 1) LIFO [
        ask link-with i [
          set color blue
          set thickness 1
          output-print (word ([who] of end1 + 1) " -> " ([who] of end2 + 1))
        ]
      ]
      wait delay]
  ]
  if not empty? LIFO [run-DFS]
end

to reset
  clear-output
  set FIFO []
  set LIFO []
  set highlighted-vertices 0
  set id-highlighted 0
  ask links [set thickness 0 set color grey]
  ask turtles with [root?] [set color blue + 2]
  ask turtles with [root? = false] [set color yellow set size 3 set root? false]
end

to add-vertex
  if mouse-down? [
    create-vertices 1 [
      set shape "vertex"
      set size 3
      set color yellow
      set label who + 1
      set label-color white
      set root? false
      setxy mouse-xcor mouse-ycor
      while [mouse-down?] [
        setxy mouse-xcor mouse-ycor
        display
      ]
    ]
  ]
end

to add-edge
  if count vertices < 2[
    user-message "You need to have at least 2 vertices"
    stop
    ]
  if mouse-down? [
    let candidate min-one-of turtles [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of candidate < 2 [
      ask candidate [
        if highlighted-vertices = 0 [set id-highlighted who]
        if color = yellow [
          set highlighted-vertices highlighted-vertices + 1
          set color red
          if highlighted-vertices = 2 [
            create-link-with turtle id-highlighted
            set highlighted-vertices 0
            ask turtles with [color = red] [set color yellow]
          ]
        ]
      ]
      while[mouse-down?] [display]
    ]
  ]
end

to remove-vertex
  if not any? vertices [
    user-message "There are no vertices"
    stop
    ]
  if mouse-down? [
    let candidate min-one-of turtles [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of candidate < 2 [
      ask candidate [
        set color red
        ifelse user-yes-or-no? "Remove this vertex?" [die] [set color yellow]
      ]
      while [mouse-down?] [
        display
      ]
    ]
  ]
end

to remove-edge
  if not any? links [
    user-message "There are no edges"
    stop
    ]
  if mouse-down? [
    let candidate min-one-of turtles [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of candidate < 2 [
      ask candidate [
        if highlighted-vertices = 0 [set id-highlighted who]
        if color = yellow [
          set highlighted-vertices highlighted-vertices + 1
          set color red
          if highlighted-vertices = 2 [
            ifelse is-link? link id-highlighted who [
              ifelse user-yes-or-no? "Remove this edge?" [
                ask link id-highlighted who [die]
                set highlighted-vertices 0
                ask turtles with [color = red] [set color yellow]
              ]
              [
                set highlighted-vertices 0
                ask turtles with [color = red] [set color yellow]
                stop]
            ]

            [
              set highlighted-vertices 0
              ask turtles with [color = red] [set color yellow]
              stop]

          ]
        ]
      ]
      while[mouse-down?] [display]
    ]
  ]
end

to relocate-vertex
  if not any? vertices [
    user-message "There are no vertices"
    stop
    ]
  if mouse-down? [
    let candidate min-one-of turtles [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of candidate < 2 [
      watch candidate
      while [mouse-down?] [
        display
        ask subject [ setxy mouse-xcor mouse-ycor ]
      ]
      reset-perspective
    ]
  ]
end

to pick-root
  if not any? vertices [
    user-message "You need first to add at least one vertex"
    stop
    ]
  if mouse-down? [
    let candidate min-one-of turtles [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of candidate < 2 [
      ask candidate [
        ask turtles with [size = 4] [set size 3 set color yellow set root? false]
        set size 4
        set color blue + 2
        set root? true
      ]
      while [mouse-down?] [
        display
      ]
    ]
  ]
end