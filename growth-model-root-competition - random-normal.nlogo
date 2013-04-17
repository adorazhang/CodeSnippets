
;; A Plant Growth and Competition Model Based on Two-layer ZOI (Zone of Influence) Model

;; By Qiao Zhang ( adora91 at gmail dot com )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals [ xid yid mean-yield mutated-plant-yield mutatedA ]

;; direction: bool; True -> left, increase A
;;                  False -> right, decrease A

patches-own [ r Bmax B Bs Br RESs RESr Rs Rr Aown ratio yield tr ts deltaB ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  
  __clear-all-and-reset-ticks
;  
;  let x 0
;  let y 0
;  while [x < max-pxcor] 
;  [
;    set y 0
;    repeat n ^ (1 / 2)
;    [
;      ask patch x y
;      [ set pcolor green ]
;      set y y + (world-height / n ^ (1 / 2))
;    ]
;    set x x + (world-height / (n ^ (1 / 2) * (3 ^ (1 / 2))))
;  ]
;  set x (world-height / n ^ (1 / 2)) * (3 ^ (1 / 2) / 2)
;  while [x < max-pxcor] 
;  [
;    set y 0.5 * (world-height / n ^ (1 / 2))
;    repeat n ^ (1 / 2)
;    [
;      ask patch x y
;      [set pcolor green]
;      set y y + (world-height / n ^ (1 / 2))
;    ]
;    set x x + (world-height / n ^ (1 / 2)) * (3 ^ (1 / 2))
;  ]

  let filename ""
  ifelse mutation = True
  [ set filename "find-optimal-A-with-random-mutation.txt" ]
  [ set filename "find-optimal-A-without-mutation.txt" ]
  if file-exists? filename
  [ file-delete filename ]
  file-open filename
  ;; print heading
  ifelse mutation = True
  [ file-print "Mean Yield, Mutated Yield, Global A, Mutated Plant A" ]
  [ file-print "Mean Yield, Global A" ]
  ask patches [set pcolor white] ;; background color
  
  set mutatedA 0
  set xid 0
  set yid 0
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to print-file
  
  ifelse mutation = True
  [        
    file-type precision mean-yield 0
    file-type ", "
    file-type precision mutated-plant-yield 0
    file-type ", "
    file-type A
    file-type ", "
    file-print mutatedA
  ]
  [
    file-type precision mean-yield 0
    file-type ", "
    file-print A
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to output

  let plants patches with [ pcolor = green or pcolor = red ]
  show [deltaB] of one-of plants
  
end


;to print-whole-process
;  
;  if ticks = 1
;  [ file-print "Mean Yield, Mean Biomass, Mean deltaB, B Root, B Shoot" ]
;  
;  let plants patches with [ pcolor = green or pcolor = red]
;  
;    file-type precision mean [yield] of plants 0
;    file-type ", "
;    file-type precision mean [B] of plants 0
;    file-type ", "
;    file-type precision mean [deltaB] of plants 0
;    file-type ", "
;    file-type precision mean [Br] of plants 0
;    file-type ", "
;    file-print precision mean [Bs] of plants 0
;  
;  
;end


to debug
  
  let plants patches with [ pcolor = green or pcolor = red ]
  
  show mean-yield
  show mutated-plant-yield

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to one-generation
    
  repeat time
  [
    tick
    growth
  ]
  ;debug
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to pick-a-random-plant-and-mutate
  
  if xid != 0 and yid != 0
  [
    ask patch xid yid
    [ set pcolor green ]
  ]
  
  initialization
  
  ask one-of patches with [pcolor = green] ;; pick one patch and mutate
  [ 
    set pcolor red
    set xid [pxcor] of self
    set yid [pycor] of self
    set Aown mutatedA
  ]
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to generate-a-random-A

  let t random-normal A step-length
  
  while [ t < 0 ]
  [ set t random-normal A step-length ]
  
  set mutatedA t
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to check-if-apply-mutation
  
  if mutated-plant-yield > mean-yield
  [
    set A mutatedA
  ]
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to go-with-mutation
  
  set mean-yield 0
  set mutated-plant-yield 0
  let mean-sum 0
  let mutated-sum 0
  
  generate-a-random-A
  
  repeat replicates
  [
    reseeding
    initialization
    pick-a-random-plant-and-mutate
    one-generation
    let plants patches with [ pcolor = green ]
    set mean-sum ( mean-sum + ( mean [yield] of plants ) )
    set mutated-sum ( mutated-sum + ( [yield] of patch xid yid ) )
  ]
  set mean-yield mean-sum / replicates
  set mutated-plant-yield mutated-sum / replicates
  
  print-file
  check-if-apply-mutation
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to go-without-mutation
  
  let mean-yield-sum 0
  set mean-yield 0
  
  repeat replicates
  [
    reseeding
    initialization
    one-generation
    let plants patches with [ pcolor = green ]
    set mean-yield-sum ( mean-yield-sum + mean [yield] of plants )
  ]
  
  set mean-yield mean-yield-sum / replicates
  
  print-file
  set A A + step-length
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to go
  
  ifelse mutation = True
  [  
    if ticks = time * number-of-As * replicates
    [ 
      file-close
      stop
    ]
    go-with-mutation
  ]
  [  
    if ticks = time * number-of-As * replicates
    [ 
      file-close
      stop
    ]
    go-without-mutation
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to growth
    
  ask patches 
  [
    set ts 0
    set tr 0
  ]
  
  ask patches with [pcolor = green or pcolor = red]
  [
    set Rs ( ( (Bs ^ (2 / 3)) / pi) ^ (1 / 2) ) ;; Radius of shoot ZOI
    set Rr ( ( (Br ^ (2 / 3)) / pi) ^ (1 / 2) )
    let zone-shoot patches in-radius Rs
    let zone-root patches in-radius Rr
    
    
    ;; begin computing resources uptaken by shoots (RESs) and roots (RESr)
    ask zone-root
    [ set tr tr + ( ( [Br] of myself ) ^ root-asymmetric ) ]
      
;    ask zone-shoot
;    [ set ts ts + ( ( [Bs] of myself ) ^ shoot-asymmetric ) ;; myself is the center plant ]
;    set RESs sum [([Bs] of myself) ^ shoot-asymmetric / ts] of zone-shoot with [ts != 0]    

    set RESs Bs ^ ( 2 / 3 )
    set RESr ( sum [([Br] of myself) ^ root-asymmetric / tr] of zone-root with [tr != 0] ) * ( 1 - stress-level )
    
    let resource 0
    ifelse RESs > RESr
    [set resource RESr]
    [set resource RESs]
    
    set deltaB r * (resource - ( B ^ 2 ) / Bmax ^ ( 4 / 3) )
    
    if deltaB > 0
    [
      ifelse ticks mod time >= vegetation-growth-time
      [  ;; reproductive growth
        set yield yield + deltaB
      ]
      [  ;; vegetation growth
        set ratio ( Aown * RESs ) / ( Aown * RESs + RESr )
        set Br Br + deltaB * ratio
        set Bs Bs + deltaB * (1 - ratio)
        set B Br + Bs
      ]
    ]
  ]
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to reseeding

  ask patches [set pcolor white] ;; background color
  ask n-of n patches
  [ set pcolor green ] ;; plant color
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to initialization
  
  ask patches with [pcolor = green] ;; uniformalization
  [
    set yield 0
    set RESs 0
    set RESr 0
    set Aown A
    set r growth-rate
    set B 100
    set Bs 20
    set Br 80
    set Bmax 20000
  ]
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@#$#@#$#@
GRAPHICS-WINDOW
394
8
914
549
-1
-1
10.0
1
10
1
1
1
0
1
1
1
0
50
0
50
1
1
1
ticks
30.0

BUTTON
224
222
361
256
NIL
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
224
266
362
302
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
109
78
282
111
time
time
1
300
150
1
1
NIL
HORIZONTAL

INPUTBOX
28
327
101
387
number-of-As
10
1
0
Number

SLIDER
30
146
175
179
growth-rate
growth-rate
0.1
1
1
0.1
1
NIL
HORIZONTAL

INPUTBOX
32
32
92
92
n
100
1
0
Number

SLIDER
30
190
176
223
stress-level
stress-level
0
1
0.5
0.1
1
NIL
HORIZONTAL

INPUTBOX
28
243
116
303
shoot-asymmetric
0
1
0
Number

SWITCH
262
176
358
209
mutation
mutation
0
1
-1000

INPUTBOX
120
242
209
302
root-asymmetric
1
1
0
Number

SLIDER
109
29
280
62
vegetation-growth-time
vegetation-growth-time
0
time
100
1
1
NIL
HORIZONTAL

INPUTBOX
114
326
289
386
A
2
1
0
Number

INPUTBOX
298
326
362
386
step-length
0.1
1
0
Number

INPUTBOX
297
31
359
91
replicates
100
1
0
Number

TEXTBOX
30
126
350
164
----------------------------------------------------
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
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
NetLogo 5.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="d" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <steppedValueSet variable="d" first="4.5" step="0.5" last="9.5"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
