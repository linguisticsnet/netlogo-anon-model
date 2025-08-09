;; Two reference models. Fist inventory of patch states based on Frascarelli 2012, second based on Rizzi & Bocci 2017
;; Jul 2025 v


globals [row num-states previous-states changes-made swap-done state-mappings precedence-hierarchy simulation-done]

patches-own [state letter]
extensions [table]


; SETUP OPTIONS
; Patches can be generated randomly or selected manually.
; There's also a predefined setup (test setup) for quick debugging


to setup
  if reference-model = "Frascarelli 2012" [ setup-frascarelli ]
  if reference-model = "Rizzi & Bocci 2017" [ setup-rizzi ]
end

to setup-manual
  if reference-model = "Frascarelli 2012" [ setup-manual-frascarelli ]
  if reference-model = "Rizzi & Bocci 2017" [ setup-manual-rizzi ]
end

to setup-predefined
  if reference-model = "Frascarelli 2012" [ setup-predefined-frascarelli ]
  if reference-model = "Rizzi & Bocci 2017" [ setup-predefined-rizzi ]
end


; SEMI-RANDOM SETUP
to setup-frascarelli
  clear-all
  set simulation-done false
  setup-state-mappings
  setup-precedence
  set-patch-size 40
  set num-states 7
  set row max-pycor
  set previous-states []

  ;; Step 1: Optionally include Force, Int, or Fin (clause-typing elements)
  let include-special? random-float 1 < 0.7
  let special-state nobody

  if include-special? [
    set special-state one-of [1 4 7]  ;; Force (1), Int (4), Fin (7)
    let special-patch one-of patches with [pycor = row]
    ask special-patch [
      set state special-state
      set letter state-to-letter state
      set pcolor state-to-color state
      update-label
    ]
  ]

  ;; Step 2: Assign remaining patches
  let remaining-states [2 3 5 6]  ;; Shift, Contr, Foc, Fam

  ask patches with [pycor = row and (state = nobody or state = 0)] [
    let random-state one-of remaining-states
    set state random-state
    set letter state-to-letter state
    set pcolor state-to-color state
    update-label
  ]

  reset-ticks
end

to setup-rizzi
  clear-all
  set simulation-done false  ; Reset the flag to indicate simulation is not done
  setup-state-mappings
  setup-precedence
  set-patch-size 40
  set num-states 7  ;; Total states
  set row max-pycor
  set previous-states []

  ;; Step 1: Randomly decide whether to include a subordinating clause-typing element (Force, Fin, Int, QEmb)
  let include-special? random-float 1 < 0.7  ;; 70% chance to include a special element
  let special-state nobody

  if include-special? [
    ;; Randomly choose one of Force (1), Int (3), QEmb (6), or Fin (7)
    set special-state one-of [1 3 6 7]

    ;; Assign the special state to a single random patch in the row
    let special-patch one-of patches with [pycor = row]
    ask special-patch [
      set state special-state
      set letter state-to-letter state
      set pcolor state-to-color state
      update-label
    ]
  ]

  ; Step 2: Randomly decide whether to include a "Mod" patch (60% chance, currently)
  let include-mod? random-float 1 < 0.6
  let mod-patch nobody  ; Initialize mod-patch as nobody

  if include-mod? [
    ; Select one patch to be "Mod"
    set mod-patch one-of patches with [pycor = row]
    ask mod-patch [
      set state 5  ; "Mod" corresponds to state 5
      set letter state-to-letter state
      set pcolor state-to-color state
      update-label
    ]
  ]

  ;; Step 3: Assign valid states to all remaining patches
  let remaining-states [2 4]  ;; Possible states: Top (2), Foc (4)   This will only generate initial configs which contain no mutually exclusive elements
  ;; let remaining-states [2 4 1 3 6 7]  ;; This will generate all types of initial configs, including those that contain mutually exclusive elements

  ask patches with [pycor = row and (state = nobody or state = 0)] [
    let random-state one-of remaining-states  ;; Randomly select a state
    set state random-state
    set letter state-to-letter state
    set pcolor state-to-color state
    update-label
  ]


  reset-ticks
end

;to update-label   ;; use this for quick debugging: it shows patch states as numbers rather than linguistic labels
;  ifelse table:has-key? state-mappings state [
;    let rank precedence-rank state
;    set plabel word "" rank
;  ] [
;    set plabel ""
;  ]
;end


;to update-label
;  set plabel letter; Show the label (=constituent type)
;end

; Use this version of "to update-label" for running the code on Netlogoweb web,
; otherwise the labels will not appear centered
to update-label
  set plabel (word letter " "); Show the label (=constituent type)
end


; MANUAL SETUP
to setup-manual-frascarelli
  clear-all
  set simulation-done false  ; Reset the flag to indicate simulation is not done
  setup-state-mappings
  setup-precedence
  set-patch-size 40
  set num-states 7  ;; Total states
  set row max-pycor
  set previous-states []

  ;; Prompt the user to enter the sequence in a single line
  let input-sequence user-input "Enter the sequence (e.g., 'Shift Fam Force Fam Contr Fam'):"

  print (word "User entered sequence: " input-sequence)

  ;; Split the input string into a list of patch descriptors
  let descriptors split-string input-sequence " "
  print (word "Parsed descriptors: " descriptors)

  ;; Assign the state based on each descriptor
  ask patches with [pycor = row] [
    let patch-index (pxcor - min-pxcor)
    print (word "Patch index: " patch-index)

    ifelse patch-index < length descriptors [
      ;; Parse the descriptor to get the patch type
      let descriptor item patch-index descriptors

      ;; Assign state based on descriptor
      let assigned-state label-to-state descriptor
      ifelse assigned-state = -1 [
        print (word "Unknown descriptor: " descriptor ". Skipping patch.")
      ] [
        set state assigned-state
        set letter state-to-letter state
        set pcolor state-to-color state
        update-label
        print (word "State set to: " state " Letter: " letter " Color: " pcolor)
      ]
    ] [
      ;; For patches that exceed the length of the pattern, set them to default/neutral values
      set state -1  ;; Indicates no state assigned
      set pcolor black
      set plabel ""
      print "Patch set to default state."
    ]
  ]

  reset-ticks
end


to setup-manual-rizzi
  clear-all
  set simulation-done false  ; Reset the flag to indicate simulation is not done
  setup-state-mappings
  setup-precedence
  set-patch-size 40
  set num-states 7  ;; Total states
  set row max-pycor
  set previous-states []

  ;; Prompt the user to enter the sequence in a single line
  let input-sequence user-input "Enter the sequence (e.g., 'QEmb Top Top Foc Mod'):"

  print (word "User entered sequence: " input-sequence)

  ;; Split the input string into a list of patch descriptors
  let descriptors split-string input-sequence " "
  print (word "Parsed descriptors: " descriptors)

  ;; Assign the state based on each descriptor
  ask patches with [pycor = row] [
    let patch-index (pxcor - min-pxcor)
    print (word "Patch index: " patch-index)

    ifelse patch-index < length descriptors [
      ;; Parse the descriptor to get the patch type
      let descriptor item patch-index descriptors

      ;; Assign state based on descriptor
      let assigned-state label-to-state descriptor
      ifelse assigned-state = -1 [
        print (word "Unknown descriptor: " descriptor ". Skipping patch.")
      ] [
        set state assigned-state
        set letter state-to-letter state
        set pcolor state-to-color state
        update-label
        print (word "State set to: " state " Letter: " letter " Color: " pcolor)
      ]
    ] [
      ;; For patches that exceed the length of the pattern, set them to default/neutral values
      set state -1  ;; Indicates no state assigned
      set pcolor black
      set plabel ""
      print "Patch set to default state."
    ]
  ]

  reset-ticks
end


; Helper function to split a string by spaces
to-report split-string [str delimiter]
  if delimiter = "" [ report [] ]  ; Prevent infinite loop by returning an empty list
  if not member? delimiter (list " " "," "\n" "\t") [
    user-message "Delimiter should be a space, comma, newline, or tab."
    report []  ; Return an empty list to exit the procedure
  ]
  let result []
  let current-str str
  while [current-str != ""] [
    let pos position delimiter current-str
    ifelse pos != false [
      set result lput substring current-str 0 pos result
      set current-str substring current-str (pos + 1) length current-str
    ] [
      set result lput current-str result
      set current-str ""
    ]
  ]
  report result
end


; TEST SETUP
to setup-predefined-frascarelli
  clear-all
  set simulation-done false  ; Reset the flag to indicate simulation is not done
  setup-state-mappings
  setup-precedence
  set-patch-size 40
  set num-states 7
  set row max-pycor
  set previous-states []

  ;; Predefined pattern:
  let predefined-pattern [5 2 4 2 1 2]  ;

  ;; Set the first row based on the predefined pattern
  ask patches with [pycor = row] [
    let index (pxcor - min-pxcor)

    ;; Only set state for patches within the predefined pattern length
    if index < length predefined-pattern [
      set state item index predefined-pattern
      set letter state-to-letter state
      set pcolor state-to-color state
      set previous-states lput state previous-states  ; Store the state in the list

      update-label  ; update the label
    ]
    ;; For patches beyond the predefined pattern, set them to empty
    if index >= length predefined-pattern [
      set state -1  ; empty patches beyond the pattern
      set pcolor black
      set plabel ""
    ]
  ]

  reset-ticks
end

to setup-predefined-rizzi
  clear-all
  set simulation-done false  ; Reset the flag to indicate simulation is not done
  setup-state-mappings
  setup-precedence
  set-patch-size 40
  set num-states 7
  set row max-pycor
  set previous-states []

  ;; Predefined pattern:
  let predefined-pattern [5 2 4 2 1 2]  ;

  ;; Set the first row based on the predefined pattern
  ask patches with [pycor = row] [
    let index (pxcor - min-pxcor)

    ;; Only set state for patches within the predefined pattern length
    if index < length predefined-pattern [
      set state item index predefined-pattern
      set letter state-to-letter state
      set pcolor state-to-color state
      set previous-states lput state previous-states  ; Store the state in the list

      update-label  ; update the label
    ]
    ;; For patches beyond the predefined pattern, set them to empty
    if index >= length predefined-pattern [
      set state -1  ; empty patches beyond the pattern
      set pcolor black
      set plabel ""
    ]
  ]

  reset-ticks
end

; "GO" OPTIONS

to go
  if update-method = "Cascade" [ go-cascade ]
  if update-method = "Pairwise" [ go-pairwise ]
end

;; Cascade

to go-cascade
  ;; Check if the simulation is already complete
  if simulation-done [
    user-message "Simulation has already reached its final state."
    stop  ; Stop further execution
  ]

  print (word "Current row: " row)  ; Debugging: Print current row number

  ;; Check if the row has reached the bottom (final row processing)
  if row = min-pycor [
    print "Reached the final row."
    tick  ; Ensure the final row is visually updated before stopping
    stop  ; End the simulation
  ]

  ;; Skip applying rules to the first row (row = max-pycor)
  if row != max-pycor [
    ;; Reset the changes tracker for the current row and swap limiter
    set changes-made false
    set swap-done false  ; Reset swap limiter for this row

    ;; Apply the rules based on the chosen method (Cascade)
    update-cascade

    ;; If no changes were made in the current row, process the final row and stop
    if not changes-made [
      print "No changes made. This is the final row."
      set simulation-done true  ; Set the flag to true
      user-message "Simulation has already reached its final state."
      tick  ; Ensure the final row is visually updated before stopping
      stop  ; End the simulation
    ]
  ]

  ;; Print the current row for debugging
  print (word "Moving to row: " row)  ; debugging: track row movement
  set row row - 1  ; Move to the next row

  ;; Initialize the next row based on the previous row's states
  ask patches with [pycor = row + 1] [
    let current-state state
    ask patch-at 0 -1 [
      set state current-state
      set letter state-to-letter state
      set pcolor state-to-color state
      update-label  ; Update the label
    ]
  ]

  ;; At the end of the go procedure, print the states of the rows
  print-row-states
  tick  ; Advance the tick for NetLogo's time progression
end


to update-cascade

  print "Mode: Cascade " ; Print confirmation of PaCascade

  ;; Get all patches in the current row and sort them by pxcor in descending order
  let patches-in-row sort-on [pxcor] patches with [pycor = row]

  ;; Reverse the list to get right-to-left order
  let reversed-patches-in-row reverse patches-in-row

  ;; Use foreach instead of ask to iterate through the list of patches
  foreach reversed-patches-in-row [current-patch ->
    if not swap-done [  ; Only proceed if no swap has happened yet
      ask current-patch [
        let left-patch patch-at -1 0  ;; Get the patch to the left
        if left-patch != nobody and pxcor > min-pxcor [ ; prevent wrapping around
          print (word "Evaluating patch in cascade: (" pxcor ", " pycor ")")

          ;; Use the helper function to print the formatted state
          print-patch-state self left-patch

          ;; Apply the rule logic to the current patch and its left neighbor
          apply-rule  ;; Apply the rule logic to the current patch and its left neighbor
          if changes-made [set swap-done true]  ; Stop after the first swap
           check-mutual-exclusiveness
        ]
      ]
    ]
  ]
end

;; Pairwise

to go-pairwise
  if simulation-done [
    user-message "Simulation has already reached its final state."
    stop
  ]

  print (word "Current row: " row)

  ;; Determine how many pairs we can evaluate
  let num-pairs (max-pxcor - min-pxcor)

  ;; Stop once we've evaluated all pairs
  if (max-pycor - row) > num-pairs [
    print "All pairs have been evaluated. Derivation complete (Pairwise)."
    set simulation-done true
    user-message "Pairwise derivation complete."
    tick
    stop
  ]

  if row != max-pycor [
    set changes-made false
    set swap-done false
    update-pairwise
  ]

  print (word "Moving to row: " row)
  set row row - 1

  ask patches with [pycor = row + 1] [
    let current-state state
    ask patch-at 0 -1 [
      set state current-state
      set letter state-to-letter state
      set pcolor state-to-color state
      update-label
    ]
  ]

  print-row-states
  tick
end


to update-pairwise
  print "Mode: Strict Pairwise (Fixed one pair per step)"  ;; millionth version of paiwise!

  ;; Determine the right-hand patch of the pair to be evaluated in this row.
  ;; This formula shifts the evaluated pair one position to the left on each new row.
  ;; In row 9: (right-pxcor = 5), row 8: 4, row 7: 3, etc.
  ;; This ensures that only one fixed pair is evaluated per row — right-to-left.
  let right-pxcor (max-pxcor - (max-pycor - row) + 1)
  let left-pxcor (right-pxcor - 1)

  ;; Instead of skipping the last pair, allow (0,1) and prevent left-pxcor from going below 0
  if (right-pxcor <= max-pxcor and left-pxcor >= 0) [
    let right-patch patch right-pxcor row
    let left-patch patch left-pxcor row

    if right-patch != nobody and left-patch != nobody [
      ask right-patch [
        print-patch-state self left-patch
        apply-rule
        if changes-made [ set swap-done true ]
        check-mutual-exclusiveness
      ]
    ]
  ]
end

;; Print Patch States

to print-patch-state [current-patch left-patch]
  ;; Define label for the current patch
  let current-label [letter] of current-patch
  print (word "Current patch at (" [pxcor] of current-patch ", " [pycor] of current-patch "): " current-label)

  ;; Define label for the left patch if it exists
  ifelse left-patch != nobody [
    let left-label [letter] of left-patch
    print (word "Left patch at (" [pxcor] of left-patch ", " [pycor] of left-patch "): " left-label)
  ] [
    print "Left patch is nobody."
  ]
end


to apply-rule
  let left-patch patch-at -1 0  ; Neighbor to the left
  let right-boundary? pxcor = max-pxcor  ; Check if this is the rightmost patch
  let left-boundary? pxcor = min-pxcor  ; Check if this is the leftmost patch

  ;; Print the state of the current patch and its left neighbor
  print-patch-state self left-patch

  ;; Only proceed if there's a left patch and we are not at the left boundary
  ifelse left-patch != nobody and not left-boundary? [

    ;; Check whether we should swap based on the defined rules
    let swap? should-swap? [state] of left-patch state

    ;; Debugging output
    if not swap? [print "No swap needed between current patch and left patch."]
    if swap? [print "Swap condition met."]

    ;; Perform the swap if conditions are met and no other swap has occurred
    if swap? and not swap-done [
      print "Swap will occur with left neighbor"

      ;; Store current state to swap values
      let temp-state state

      ;; Update the current patch with values from the left patch
      set state [state] of left-patch
      set letter state-to-letter state
      set pcolor state-to-color state
      update-label

      ;; Update the left patch with stored values from the current patch
      ask left-patch [
        set state temp-state
        set letter state-to-letter state
        set pcolor state-to-color state
        update-label
      ]

      print "Swap completed"
      set changes-made true  ; A swap was made, so mark changes
      set swap-done true  ; Prevent further swaps in this row
      print "Changes were made in the current row."
    ]
  ] [
    ;; If no left patch or at boundary, print this message
    print "Left patch is nobody or at boundary."
  ]
end

to setup-state-mappings
  set state-mappings table:make

  if reference-model = "Frascarelli 2012" [
    table:put state-mappings 1 ["Force" red "Force"]
    table:put state-mappings 2 ["Shift" sky "Shift"]
    table:put state-mappings 3 ["Contr" pink "Contr"]
    table:put state-mappings 4 ["Int" green "Int"]
    table:put state-mappings 5 ["Foc" gray "Foc"]
    table:put state-mappings 6 ["Fam" violet "Fam"]
    table:put state-mappings 7 ["Fin" orange "Fin"]
  ]

  if reference-model = "Rizzi & Bocci 2017" [
    table:put state-mappings 1 ["Force" red "Force"]
    table:put state-mappings 2 ["Top" blue "Top"]
    table:put state-mappings 3 ["Int" pink "Int"]
    table:put state-mappings 4 ["Foc" green "Foc"]
    table:put state-mappings 5 ["Mod" gray "Mod"]
    table:put state-mappings 6 ["QEmb" violet "QEmb"]
    table:put state-mappings 7 ["Fin" orange "Fin"]
  ]
end


to-report state-to-letter [s]
  if table:has-key? state-mappings s [
    report item 0 table:get state-mappings s
  ]
  report ""  ;; Default for unexpected states
end

to-report state-to-color [s]
  if table:has-key? state-mappings s [
    report item 1 table:get state-mappings s
  ]
  report black  ;; Default color for unexpected states
end

to-report label-to-state [input-label]
  foreach table:keys state-mappings [key ->
    let entry table:get state-mappings key
    if item 2 entry = input-label [report key]
  ]
  report -1  ;; Return -1 for unknown labels
end

to setup-precedence
  set precedence-hierarchy table:make

  if reference-model = "Frascarelli 2012" [
    table:put precedence-hierarchy 1 1
    table:put precedence-hierarchy 2 2
    table:put precedence-hierarchy 3 3
    table:put precedence-hierarchy 4 4
    table:put precedence-hierarchy 5 5
    table:put precedence-hierarchy 6 6
    table:put precedence-hierarchy 7 7
  ]

  if reference-model = "Rizzi & Bocci 2017" [
    table:put precedence-hierarchy 1 1
    table:put precedence-hierarchy 2 999
    table:put precedence-hierarchy 3 2
    table:put precedence-hierarchy 4 3
    table:put precedence-hierarchy 5 4
    table:put precedence-hierarchy 6 5
    table:put precedence-hierarchy 7 6
  ]
end


to-report should-swap? [left-state right-state]
  if left-state = right-state [report false]

  if reference-model = "Frascarelli 2012" [
    let pairs [
      [1 2] [1 3] [1 4] [1 5] [1 6] [1 7]
      [2 3] [2 4] [2 5] [2 6] [2 7]
      [3 4] [3 5] [3 6] [3 7]
      [4 5] [4 6] [4 7]
      [5 6] [5 7]
      [6 7]
    ]
    report member? (list right-state left-state) pairs
  ]

  if reference-model = "Rizzi & Bocci 2017" [
    let pairs [
      [1 2] [1 3] [1 4] [1 5] [1 6] [1 7]
      [3 4] [3 5] [3 6] [3 7]
      [4 5] [4 6] [4 7]
      [5 6] [5 7]
      [6 7]
      [2 7]
    ]
    report member? (list right-state left-state) pairs
  ]

  report false
end


to check-mutual-exclusiveness
  ask patches with [pycor = row] [
    let right-patch patch-at 1 0  ; Neighbor to the right

    ;; Check mutual exclusivity only if the right patch exists and is not at the boundary
    if right-patch != nobody and pxcor < max-pxcor [
      ;; Get the states of the two patches
      let state-a state
      let state-b [state] of right-patch

      ;; ----------- Frascarelli 2012 constraints -----------
      if reference-model = "Frascarelli 2012" [

      ;; Check for Force–Fin adjacency
      if (state-a = 1 and state-b = 7) or (state-a = 7 and state-b = 1) [
        user-message "Derivation terminated: Force and Fin are adjacent."
        stop
      ]

      ;; Check for Force–Int adjacency
      if (state-a = 1 and state-b = 4) or (state-a = 4 and state-b = 1) [
        user-message "Derivation terminated: Force and Int are adjacent."
        stop
      ]

      ;; Check for Fin–Int adjacency
      if (state-a = 7 and state-b = 4) or (state-a = 4 and state-b = 7) [
        user-message "Derivation terminated: Fin and Int are adjacent."
        stop
      ]]

      ;; ----------- Rizzi & Bocci 2017 constraints -----------
      if reference-model = "Rizzi & Bocci 2017" [

      ;; Check for Force–Fin adjacency
      if (state-a = 1 and state-b = 7) or (state-a = 7 and state-b = 1) [
        user-message "Derivation terminated: Force and Fin are adjacent."
        stop
      ]

      ;; Check for Force–Int adjacency
      if (state-a = 1 and state-b = 3) or (state-a = 3 and state-b = 1) [
        user-message "Derivation terminated: Force and Int are adjacent."
        stop
      ]

            ;; Check for Force–QEmb adjacency
      if (state-a = 1 and state-b = 6) or (state-a = 6 and state-b = 1) [
        user-message "Derivation terminated: Force and QEmb are adjacent."
        stop
      ]

      ;; Check for Fin–Int adjacency
      if (state-a = 7 and state-b = 3) or (state-a = 3 and state-b = 7) [
        user-message "Derivation terminated: Fin and Int are adjacent."
        stop
      ]

      ;; Check for Fin–QEmb adjacency
      if (state-a = 7 and state-b = 6) or (state-a = 6 and state-b = 7) [
        user-message "Derivation terminated: Fin and QEmb are adjacent."
        stop
      ]

      ;; Check for Qemb–Int adjacency
      if (state-a = 6 and state-b = 3) or (state-a = 3 and state-b = 6) [
        user-message "Derivation terminated: QEmb and Int are adjacent."
        stop
    ]]]

    ]
end


to print-row-states
  print "Current model state:"
  let first-row-printed? false

  foreach n-values world-height [i -> max-pycor - i] [current-row ->
    let row-states []
    let sorted-patches sort-on [pxcor] patches with [pycor = current-row]

    ;; Collect the state for each patch in the row
    foreach sorted-patches [current-patch ->
      ask current-patch [
        let patch-label state-to-letter state
        set row-states lput (patch-label) row-states
      ]
    ]

    ;; Check if the row contains only "Rel0"
    if length filter [element -> element != "Rel0"] row-states > 0 [
      ;; Add a divider line only before the first row to mark the start of a block
      if not first-row-printed? [
        print "-----------------------------"
        set first-row-printed? true
      ]
      print (word "Row " current-row ": " (reduce [[result element] -> (word result " " element)] row-states))
    ]
  ]

  ;; Add a blank line after the block of rows for clarity
  print ""
end


























@#$#@#$#@
GRAPHICS-WINDOW
210
40
458
489
-1
-1
40.0
1
12
1
1
1
0
1
1
1
0
5
0
10
0
0
1
ticks
30.0

BUTTON
28
147
134
180
Random Setup
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
29
323
92
356
Go
go
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
29
368
141
401
Continuous Go
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

BUTTON
28
193
134
226
Manual Setup
setup-manual
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
30
292
180
310
\"Go\" Options
12
13.0
1

TEXTBOX
29
116
179
134
\"Setup\" Options
12
13.0
1

CHOOSER
28
456
166
501
update-method
update-method
"Pairwise" "Cascade"
0

TEXTBOX
27
428
177
446
Update Method Options
12
13.0
1

BUTTON
29
238
135
271
Test Setup
setup-predefined
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
28
47
166
92
reference-model
reference-model
"Rizzi & Bocci 2017" "Frascarelli 2012"
1

TEXTBOX
28
18
178
36
Reference Model
12
13.0
1

@#$#@#$#@
## WHAT IS IT?

This simulation models the behavior of linguistic elements (e.g., argument phrases, wh-elements, modifiers) in the **left periphery** of a sentence, inspired by principles from syntactic theory. 

The left periphery refers to the initial portion of a sentence where important syntactic and semantic elements are positioned. The model demonstrates how these elements interact and **organize dynamically** based on **localized rules**, without relying on a fixed, predefined template. The goal is to show how complex and well-formed structures can emerge from simple interactions between neighboring elements.


## HOW IT WORKS

The simulation represents linguistic elements as patches in a single row of a grid. Each patch corresponds to a specific type of left-peripheral constituent (e.g., modifier, topic, focus), and the simulation applies local rules to determine how these patches interact with one another.

Here’s how the process works:

- **Precedence Rules**: each patch is assigned a precedence rank. Higher-precedence elements can move ahead of lower-precedence elements by swapping positions with their neighbors.
- **Mutual Exclusivity Rules**: certain elements cannot appear adjacent to each other. If two mutually exclusive elements are neighbors, the simulation terminates when this conflict is detected.
- **Row Progression**: the simulation proceeds row by row, evaluating pairs of neighboring patches sequentially from right to left. This stepwise reorganization models how linguistic structures might emerge incrementally.

## HOW TO USE IT

- **Setup Buttons**: use the setup options (setup, setup-manual, setup-predefined) to initialize the grid with different configurations.
	- _Random Setup_: randomly places elements on the top row.
	- _Manual Setup_: allows the user to input specific elements manually.
	- _Test Setup_ : sets up a predefined sequence of elements.
- **Go Button**: starts the simulation, which will continue to run until: (i) it reaches the bottom of the grid, (ii) no further changes can be made, or (iii) a mutual exclusivity violation is detected.
- **Update Method Selector**: choose between "Strict Pairwise" and "Cascade" methods for updating the grid:
	- _Strict Pairwise_: evaluates and updates patches one pair at a time without revisiting previous configurations.
	- _Cascade_: allows changes in one pair to ripple backward and affect earlier patches.

## TYPES OF PATCH STATES

In the simulation, each patch represents a syntactic element in the left periphery, such as a question word, topic, or modifier. The type of patch state determines the role of the element and how it interacts with neighboring patches. The following patch states are included in the simulation:

- **Interrogative Complementizers (Int)**: words like *if* or *whether* that introduce a question.
- **Relative Pronouns (Rel)**: elements like *that* or *whom* that connect clauses or specify information.
- **Modifiers (Mod)**: words or phrases that provide additional details, such as *yesterday* or *suddenly*.
- **Wh-Elements (Wh)**: question words like *who*, *what*, or *where* in main clauses.
- **Contrastive Topics (CT)**: topics that highlight a contrast or alternative, such as "*As for John*, he stayed home."
- **Shifting Topics (ST)**: topics that mark a transition in the conversation, like "*Now*, about the party..."
- **Familiar Topics (Fam)**: topics that refer to information already known or shared in the discussion.
- **Focus Elements (Foc)**: words or phrases that emphasize new or important information, such as "It was *John* who solved the problem".
- **Embedded Wh-Elements (QEmb)**: question words that appear in embedded clauses, such as "I wonder *what* she said".

These patch states reflect the variety of syntactic elements that can occur in the **left periphery** of a sentence. Each type interacts according to precedence and exclusivity rules, determining its final position in the word order.



## THINGS TO NOTICE

- **Emergent Order**: observe how the patches rearrange themselves row by row to form a coherent word order based on precedence rules.
- **Mutual Exclusivity Conflicts**: notice how the simulation halts when two mutually exclusive elements are adjacent.
- **Update Methods**: compare the behaviors of the Cascade and Strict Pairwise modes to see how feedback and rigidity affect the resulting configuration.

## THINGS TO TRY

- Use the Manual Setup option to test specific combinations of elements and see how the simulation derives their order.
- Experiment with the Cascade and Strict Pairwise update methods to understand how each influences the final configuration.
- Modify the precedence rankings to explore alternative syntactic arrangements and observe their effects.


## RELATED MODELS

This simulation is inspired by **Cellular Automata** models, which use grids of cells to demonstrate how local interactions can lead to complex patterns. Similarly, this model uses local precedence and exclusivity rules to dynamically derive linguistic structures.


## AUTHOR

Elena Callegari, University of Iceland (2024)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
