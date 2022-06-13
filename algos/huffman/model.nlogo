breed [ symbols symbol ]       ;; Each symbol turtle represents a letter or other symbol in the message without redundancy.
breed [ nodes node ]           ;; Nodes connect to each other and to symbols with directed links to build the tree.
breed [ encoders encoder ]     ;; Encoders traverse the tree to build the code table, encode, or decode a message.
breed [ labelers labeler ]     ;; Labelers are just used to make the symbol labels appear below rather than on the symbol.

directed-link-breed [ zero-links zero-link ]                  ;; Zero-links are red and represent a "0" symbol.
directed-link-breed [ one-links one-link ]                    ;; One-links are blue and represent a "1" symbol.
undirected-link-breed [ normal-links normal-link ]            ;; These are used for connecting labelers to symbols.

globals [
  user-string                  ;; user entered string to be encoded
  message-length               ;; length of the user-string
  available-colors             ;; list of colors available for symbols at setup
  space                        ;; variable for spacing turtles in tree layouts            
  table-started?               ;; true while the code table is being built
  tree-built?                  ;; true when there is a complete Huffman tree in the world
]

turtles-own [
  tier                         ;; Tiers tell where in the tree the turtle is. Tier 0 represents individual symbols. 
                               ;; Higher tiers represent groups of symbols and nodes.
  group                        ;; identifies group members named after the highest tiered ancestor
]

symbols-own [
  symbol-name                  ;; the english letter (or other symbol) the symbol turtle represents
  frequency                    ;; number of times the symbol appeared in the message
  rank                         ;; stores a symbol's rank with regards to frequency, rank 1 = lowest
  code                         ;; binary code for this symbol
]

nodes-own [
  frequency                    ;; sum of frequencies of symbols under this node
  has-parent?                  ;; false if turtle is the topmost node of a group, true otherwise
  width                        ;; number of symbols under this node
  parent                       ;; the immediate ancestor of the node
]

encoders-own [
  bit-code                     ;; string of '1's and '0's edited by the encoders as they traverse the tree
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Main Procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all  
  set-default-shape symbols "pentagon"
  set-default-shape nodes "circle"
  
  set table-started? false
  set tree-built? false
  set user-string user-input "Type a short message"
  set message-length length user-string

  make-symbols                                                
  make-starter-nodes
  make-symbol-labels
  reset-ticks
end

to build-tree  
  ifelse count nodes with [ has-parent? = false ] > 1 [
    make-new-node
    wait speed
    reorder-groups
   ]
  [ set tree-built? true
    hatch-encoder
    stop ]
end

to generate-table  
  if count encoders = 0 [
    if table-started? [set table-started? false stop]
    hatch-encoder
    wait speed
  ]
  set table-started? true
  ask encoders [
    ifelse color = blue [
      ifelse heading = 0 [ ;; arrow down
        ifelse count symbols-here = 0 [ 
          move-to one-of [ out-one-link-neighbors ] of one-of nodes-here
          set bit-code word bit-code "1"
          set label bit-code
        ][ ;; if there is a symbol here
          ask symbols-here [ 
            set code [bit-code] of one-of encoders
            let new-code code
            ask normal-link-neighbors [ set label new-code ]             
          ] 
          set heading 180
        ]
      ][ ;; if heading = 180 and arrow is up
        ifelse count symbols-here = 0 [
          set heading 0 
          set color red 
          move-to one-of [out-zero-link-neighbors] of one-of nodes-here
          set bit-code word bit-code "0"
          set label bit-code 
        ][ ;; if there is a symbol here
          move-to [parent] of one-of nodes-here 
          set bit-code but-last bit-code
          set label bit-code
        ]
      ]
    ][ ;;if color = red
      ifelse heading = 0 [ ;; arrow is down
        ifelse count symbols-here = 0 [
          move-to one-of [out-one-link-neighbors] of one-of nodes-here
          set bit-code word bit-code "1"
          set color blue
          set label bit-code
        ][ ;; if there is a symbol here
          ask symbols-here [ 
            set code [bit-code] of one-of encoders
            let new-code code
            ask normal-link-neighbors [ set label new-code ] 
          ]
          set heading 180
        ]
      ][ ;; if heading = 180 and arrow is up
        ifelse count symbols-here = 0 [
          ifelse [has-parent?] of one-of nodes-here [
            set bit-code but-last bit-code
            set label bit-code
            if [parent] of one-of nodes-here = one-of [in-one-link-neighbors] of one-of nodes-here [ set color blue] 
            move-to [parent] of one-of nodes-here
          ] [ print-out die ]
        ][ ;; if there is a symbol here
          move-to [parent] of one-of nodes-here 
          set bit-code but-last bit-code
          set label bit-code
        ]
      ]
    ]
  ] 
end

to encode
  let counter message-length
  let string user-string
  let code-string ""
  while [counter > 0] [
    set code-string word code-string [code] of one-of symbols with [symbol-name = first string]
    set string but-first string
    set counter counter - 1
  ]
  set encoded-message code-string
end

to decode
  let string encoded-message
  let bit""
  set decoded-message""

  while [length string > 0] [  
    if count encoders = 0 [
      ask node max [ who ] of nodes [ 
        hatch-encoders 1 [ 
          set shape "encoder" 
          set size 3 
          set bit-code"" 
          set label bit-code 
          set color blue 
          set heading 0
        ]
      ]
      
    ]
    wait speed
    ask encoders [
      while [count symbols-here = 0] [
        set bit first string
        set string but-first string
        ifelse bit = "1" [
          ask encoders [ move-to one-of [out-one-link-neighbors] of one-of nodes-here] ][
        ifelse bit = "0" [
          ask encoders [ move-to one-of [out-zero-link-neighbors] of one-of nodes-here] ]
        [ user-message "Encoded messages must have '0' and '1' only"]
        ]    
      wait speed
      ]
      let next-letter [symbol-name] of one-of symbols-here
      set decoded-message word decoded-message next-letter
      move-to node max [ who ] of nodes
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Support Procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to make-symbols
;; Make a symbol turtle for each symbol in the string where its frequency variable reflect the letter's frequency in the message.
  set available-colors shuffle filter [(? mod 10 >= 3) and (? mod 10 <= 7)] n-values 140 [?]
  let string user-string
  while [ length string > 0 ] [
    let current-symbol first string
    
    ifelse count symbols with [ symbol-name = current-symbol ] = 0 [ 
      create-symbols 1 [ 
        set size 2
        set color first available-colors
        set symbol-name first string
        set frequency 1
        set code ""
      ]
      set available-colors but-first available-colors
      set string but-first string
    ]
    [
      ask symbols with [ symbol-name = current-symbol ] [ set frequency frequency + 1 ]
      set string but-first string
    ]
  ]
  
;; Order symbols according to their frequencies and space them appropriately.
  let ordered-symbol-list sort-by [[frequency] of ?1 < [frequency] of ?2] symbols
  set space world-width / ( count symbols + 1 )
  let counter 1
  while [ length ordered-symbol-list > 0 ] [
    ask first ordered-symbol-list [ 
      set xcor -1 * max-pxcor + counter * space 
      set rank counter
      ]
    set ordered-symbol-list but-first ordered-symbol-list
    set counter counter + 1
  ]
 
  ask symbols [ 
    set ycor -16 
    set heading 0
    set label symbol-name
    set tier 0
  ]
end

to make-starter-nodes
  ask symbols [ 
    hatch-nodes 1 [
      set label frequency
      set color black
      set size 1
      set has-parent? false
      set width 1
      set group who
    ]
  set group [who] of one-of nodes-here
  ]
end

to make-symbol-labels
  ask symbols [ hatch-labelers 1 [ 
    set color black
    set group [who] of one-of nodes-here
    create-normal-link-with one-of other symbols-here ;[ hide-link ]
    set heading 180
    fd 3
    ]
  ]
end

to-report find-lowest
  let low-freq-turtles nodes with [not has-parent? and frequency = min [frequency] of nodes with [not has-parent?] ]
  let leftmost low-freq-turtles with-min [ xcor ]
  report one-of leftmost
end

to make-new-node
  let lowest find-lowest
  ask lowest [ set has-parent? true ]

  let next-lowest find-lowest
  ask next-lowest [ set has-parent? true ]
  
  create-nodes 1 [
    set color green 
    set group who
    set has-parent? false
    create-one-link-to lowest [ set color blue ] 
    set frequency [ frequency ] of lowest
    create-zero-link-to next-lowest [ set color red ] 
    set frequency frequency + [ frequency ] of next-lowest
    set label frequency
    set xcor 0.5 * [xcor] of lowest + 0.5 * [xcor] of next-lowest
    ifelse [tier] of lowest > [tier] of next-lowest 
      [ set tier 1 + [tier] of lowest ]
      [ set tier 1 + [tier] of next-lowest ]
    set ycor -16 + tier * space
    set width sum [ width ] of out-link-neighbors with [ breed = nodes ]
  ]
  
  ask lowest [ set parent one-of nodes with-max [who] ]
  ask next-lowest [ set parent one-of nodes with-max [who] ]
  
  ask turtles [
    if group = [who] of lowest or group = [who] of next-lowest [ 
      set group [who] of one-of nodes with-max [who] 
    ]  
  ]
end



to reorder-groups
  let groups-to-move-right [who] of nodes with [ not has-parent? and frequency < [frequency] of one-of nodes with-max [who] ] 
  let leftshift ( space * [width] of node max [ who ] of nodes )
  let rightshift ( space * sum [width] of nodes with [ member? who groups-to-move-right ] )
  ask turtles with [ group = max [ who ] of nodes ] [ set heading 90 fd rightshift ]
  ask turtles with [ member? group groups-to-move-right] [ set heading 270 fd leftshift ]
end


to hatch-encoder
  ask node max [ who ] of nodes [ 
     hatch-encoders 1 [ 
       set shape "encoder" 
       set size 3 
       set bit-code"" 
       set label bit-code 
       set color blue 
       set heading 0
     ]
  ]
end



to print-out 
  output-print "Symbol Frequency Code"
  let counter count symbols
  while [counter > 0] [
    ask symbols with [ rank = counter ] [ 
      output-type symbol-name
      output-type "         "
      output-type frequency
      output-type "       "
      output-print code
    ]
    set counter counter - 1
  ] 
  output-print "" 
  output-print ""
 
end
@#$#@#$#@
GRAPHICS-WINDOW
393
10
1058
642
24
22
13.37
1
15
1
1
1
0
0
0
1
-24
24
-22
22
0
0
1
ticks
30.0

BUTTON
9
45
195
78
setup/enter message
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
9
93
196
126
step through build-tree
build-tree
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
10
181
375
487
11

TEXTBOX
10
10
277
35
Huffman Coding
18
0.0
1

BUTTON
10
499
112
567
NIL
encode
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
199
93
376
126
build-tree
build-tree\nwait speed
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
198
45
285
78
reset
ask turtles [ die ]\nset tree-built? false\nmake-symbols                                                \nmake-starter-nodes\nmake-symbol-labels\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
574
112
641
decode message
decode
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
286
45
378
78
speed
speed
0
3
0.5
.5
1
NIL
HORIZONTAL

BUTTON
9
142
196
176
step through generate-table
ifelse tree-built? [\ngenerate-table ] [\nuser-message \"You must build a tree first\"\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
199
144
376
177
generate-table
ifelse tree-built? [\ngenerate-table wait speed ] [\nuser-message \"You must build a tree first\"\n]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
117
499
376
567
encoded-message
101110101100100011001000001000100011101010011001111
1
0
String

INPUTBOX
117
574
375
642
decoded-message
this is a message
1
0
String

@#$#@#$#@
## WHAT IS IT?

Huffman coding is an encoding method that gives the most efficient lossless variable-length binary encoding for particular probability distribution of symbols. This model demonstrate the process of generating a Huffman tree and encoding for the frequency distribution in a short message. Given a user-entered string, the model generates a turtle for each symbol, builds a Huffman tree, and generates a code table based of the frequencies of the symbols in the given message. It then gives an encoding of the message in binary and demonstrates how the encoded message can be decoded with the tree.

## HOW IT WORKS

Three kinds of turtles help to build the Huffman tree. Symbols represent the characters in the original message and form the leaves of the tree. Nodes are, unsurprisingly, the nodes of the Huffman tree. Each node is labeled with the sum of the frequencies of the symbols below it. In the genereate-table procedure, encoders travel over the tree, generating a code for each symbol. In the decode procedure, the encoders decode the message by starting at the top of the tree and reporting the symbols the encoded message leads them to.

## HOW TO USE IT

Start by clicking the "enter message" button. The model will prompt you to enter a message. The model works best with 10-25 different symbols with different frequencies. One or two sentences work well. 

Once you have entered a message click the "step through build-tree" button to build the tree at your own pace, or choose a speed and click "build-tree" to see the whole tree built automatically. The tree is finished when all of the symbols can be traced up to a single node at the top of the tree and an encoder is hatched at the topmost node. this node's frequency should be the sum of the all of the frequencies of the symbols. 

Generate a Huffman encoding by clicking the "step through generate-table" or "generate table" button. The encoders will traverse the tree, delivering a code label to each of the symbols. Once all of the symbols have a label and the entire tree has been traveled, the model will generate a table in the output box of the codes for all of the symbols in your message as well as a code for your entire message (in the encoded-message input box).


## THINGS TO TRY

Try several messages of different types. Messages with big differences in the frequencies of the characters general Huffman trees that look much different than those with relatively uniform frequency distributions.

Try to decode your message with the output table and code from the model on your own once you have seen the model do it. 


## CREDITS AND REFERENCES
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

blue arrow
false
0
Polygon -13345367 true false 90 165 135 75 105 90 120 0 60 0 75 90 45 75

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

encoder
true
0
Polygon -7500403 true true 150 150 225 75 180 75 195 0 105 0 120 75 75 75

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

red arrow
false
0
Polygon -2674135 true false 210 165 255 75 225 90 240 0 180 0 195 90 165 75

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@