breed [ mergers merger ]
breed [ elements element ]

elements-own [ value ]
mergers-own [ merge-group ]
globals
[
  group-count     ;; Number of groups (lists) of elements
  group-list      ;; List of lists of elements
  step-number     ;; Number of complete merge steps finished
  current-loc     ;; Group position of next element to be drawn, used by single-sort
  current-group   ;; Group number of next element to be drawn, used by single-sort
  current-count   ;; Element number of next element to be drawn, used by single-sort
]

;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;

to setup
  ca
  set current-count 1
  set current-loc 0
  set current-group 0
  set step-number 0
  set group-list []
  set group-count number-of-elements
  setup-elements
end 

to setup-elements
  set-default-shape turtles "circle"
  create-elements number-of-elements
  [
    set size 5
    set value (random (4 * number-of-elements))
    ;; (list self) creates a list with its sole item being the turtle itself
    set group-list lput (list self) group-list
  ]
  draw
end 

;;;;;;;;;;;;;;;;;;;;;;;;
;; Runtime Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Do one set of group merges.  That is, have each pair of neighboring groups merge.

to step-row
  ;; Finish displaying current step if need be
  if (current-count > 1)
  [
    draw
    set current-count 1
    set current-loc 0
    set current-group 0
    stop
  ]
  ;; Stop if the first group contains all elements which means all elements
  ;; have been sorted.
  if (length (item 0 group-list) = number-of-elements)
    [ stop ]
  set step-number (step-number + 1)
  combine-groups
  draw
end 

;;;;;;;;;;;;;;;;;;;;;;;;
;; Merging Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;

to combine-groups
  let num 0
  ;; Create a merger for every two groups
  ;; Each merger will combine two groups
  create-mergers (group-count / 2)
  [
    set merge-group num
    set num (num + 2)
  ]
  ask mergers
  [
    merge (item merge-group group-list) (item (merge-group + 1) group-list) merge-group
    die
  ]
  ;; Remove empty groups (-1's) from our list
  set group-list remove -1 group-list
  set group-count length group-list
end 

;; Merge lists 1 and 2 into one list, maintaining order

to merge [ list1 list2 location ] ;; mergers procedure
  let new-list []
  ;; Sort the lists into new-list until either list1 or list2 is empty.
  ;; The groups are merged into increasing/decreasing order depending on
  ;; whether the increasing-order switch in on/off.
  let item1 0
  let item2 0
  while [(not empty? list1) and (not empty? list2)]
  [
    set item1 item 0 list1
    set item2 item 0 list2
    ifelse ( [value] of item1 < [value] of item2 )
    [
      set new-list lput item1 new-list
      set list1 but-first list1
    ]
    [
      set new-list lput item2 new-list
      set list2 but-first list2
    ]
  ]
  ;; One of the lists is always going to be non-empty after the above loop.
  ;; Put the remainder of the non-empty list into new-list.
  ifelse (empty? list1)
    [ set new-list sentence new-list list2 ]
    [ set new-list sentence new-list list1 ]
  ;; Copy the new-list into the appropriate location in group-list.
  ;; [(a+b) b c d] becomes [(a+b) -1 c d]
  ;; The -1's will be removed once the entire step is complete.
  ;; We do this instead of removing it here to keep order and length intact.
  set group-list (replace-item location group-list new-list)
  set group-list (replace-item (location + 1) group-list -1)
end 

;;;;;;;;;;;;;;;;;;;;;;;;
;; Display Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;

to step-item
  ;; If we have finished this round of sorting, reset our values
  if (current-count > number-of-elements)
  [
    set current-count 1
    set current-loc 0
    set current-group 0
  ]
  ;; Do a round of sorting before we display if necessary
  if (current-count = 1)
  [
    ;; Stop if the first group contains all elements which means all elements
    ;; have been sorted.
    if (length (item 0 group-list) = number-of-elements)  [stop]
    set step-number (step-number + 1)
    combine-groups
    ;; To display the step number.
    ask patch (min-pxcor + 2) (max-pycor - 5 - (step-number * 10))
      [set plabel-color green set plabel step-number]
  ]
  ;; Display the current element with its new position and color.
  let tcolor [color] of first (item current-group group-list)
  ask (item current-loc (item current-group group-list))
  [
    set pcolor color
    set color tcolor
    set ycor (max-pycor - 5 - (10 * step-number))
    set xcor (min-pxcor + (current-count * ((2 * max-pxcor) / (number-of-elements + 1))))
    ask patch-at 0 4 [set plabel-color white set plabel [value] of myself]
  ]
  ;; Update information about which turtle to display next
  set current-count (current-count + 1)
  ifelse(length (item current-group group-list) = (current-loc + 1))
  [
    set current-loc 0
    set current-group (current-group + 1)
  ]
  [ set current-loc (current-loc + 1) ]
end 

;; Move the turtles to their appropriate locations

to draw
  let list-loc 0
  let element-num 1
  ;; Evenly space the elements across the view
  let separation ((2 * max-pxcor) / (number-of-elements + 1))
  ;; To display the step number.
  ask patch (min-pxcor + 2) (max-pycor - 5 - (step-number * 10))
    [set plabel-color green set plabel step-number]
  while [list-loc < group-count]
  [
    let current-list item list-loc group-list
    let tcolor [color] of first current-list
    while [not empty? current-list]
    [
      ask (item 0 current-list)
      [
        ;; To keep track of what group an element belonged to before the current step,
        ;; we leave the color and display the value at it's previous place.
        if (step-number != 0) [ set pcolor color]
        set color tcolor
        set ycor (max-pycor - 5 - (10 * step-number))
        set xcor (min-pxcor + (element-num * separation))
        ask patch-at 0 4 [set plabel-color white set plabel [value] of myself]
      ]
      set element-num (element-num + 1)
      set current-list but-first current-list
    ]
    set list-loc (list-loc + 1)
  ]
end 


; Copyright 2005 Uri Wilensky.
; See Info tab for full copyright and license.