# Project 4: Logo — A Turtle Graphics Language

**COMP 360: Programming Languages**

---

## Expected Effort

This project is moderate in difficulty. I expect you to spend between 5 and 10 hours. If you can't complete the project within 10 hours, let yourself stop working.

Your effort now will pay off in the future.

---

## AI Assistance Disclosure

**You must disclose use of AI on this assignment.** If you opt to use AI for this project, I will ask to see your conversation history.

---

## Grading and Submission

This project is **due the week of March 9**. You can bring me your code anytime that week during my office hours. Grading should take no more than 10 minutes.

Your grade will be based on how much of the project you completed, how much time you spent, and how well you understand your own code.

My solutions will become available on March 13.

---

## Background: Logo and Turtle Graphics

In 1967, Seymour Papert, Wally Feurzeig, and Cynthia Solomon developed a programming language called **Logo** at Bolt, Beranek and Newman in Cambridge, Massachusetts. Papert — a mathematician who had studied under Jean Piaget — wanted a language where children could learn mathematics by *doing* rather than by watching. Logo was designed to be "low floor, high ceiling": easy enough for an eight-year-old to write a first program, expressive enough for serious mathematical exploration.

Logo's most famous feature is **turtle graphics**. The metaphor is concrete and physical: imagine a small mechanical turtle sitting on a large sheet of paper, holding a pen. You give it commands — *move forward 100 steps*, *turn right 90 degrees*, *lift the pen* — and it draws a picture as it moves. This direct, embodied metaphor made geometry intuitive and interactive in a way that no textbook could match.

Papert's 1980 book *Mindstorms: Children, Computers, and Powerful Ideas* popularized Logo and its educational philosophy worldwide. Logo spread into schools through the 1980s and 90s, and its influence has never really faded: Python's `turtle` module, Scratch's motion blocks, and the block-based geometry tools in countless educational apps all trace their lineage to Papert's turtle.

Here is a complete program in our Logo dialect that draws a square:

```
; square.turtle
#lang "project4.rkt"
PENDOWN
FORWARD 100
RIGHT 90
FORWARD 100
RIGHT 90
FORWARD 100
RIGHT 90
FORWARD 100
```

And one that draws a five-pointed star (once you implement `REPEAT`):

```
; star.turtle
#lang "project4.rkt"
PENDOWN
REPEAT 5
  FORWARD 120
  RIGHT 144
END
```

In this project, you will implement the Logo interpreter as a Racket **domain-specific language** (DSL).

---

## Overview

Recall the `funstacker` example from class. Its core is a stack machine driven by `for/fold`:

```racket
(define (handle-args . args)
  (for/fold ([stack-acc empty])
            ([arg (in-list args)]
             #:unless (void? arg))
    (cond
      [(number? arg) (cons arg stack-acc)]
      [(or (equal? * arg) (equal? + arg))
       (define op-result (arg (first stack-acc) (second stack-acc)))
       (cons op-result (drop stack-acc 2))])))
```

Numbers push onto the stack. Operators pop values, compute a result, and push it back. The accumulator is the stack itself.

Your Logo language works the same way — with a different accumulator. Instead of a number stack, the accumulator is the **turtle state**: position, heading, pen status, drawing color, and the image being built up.

The parallel is exact:

| Funstacker | Logo |
|---|---|
| A **number** → pushes to stack | A **number** → saves as next command's argument |
| An **operator** (`+`, `*`) → pops two values, computes | A **command** (`FORWARD`, `RIGHT`) → consumes the pending argument, updates state |
| Accumulator: a list of numbers | Accumulator: the full turtle state |

Your `handle-turtle-cmds` will look nearly identical to `handle-args`.

---

## Getting Started

This project has a different structure from Projects 1–3. You will write two kinds of files:

1. **`project4.rkt`** — the language implementation. This is what you submit and what I grade. It defines how Logo programs are read and executed.

2. **`.turtle` files** — programs written *in your language*. You'll create these to test your implementation as you go. Every `.turtle` file begins with `#lang "project4.rkt"`.

To test a `.turtle` file in DrRacket:
1. Create a new file (e.g., `test.turtle`) in the same folder as `project4.rkt`
2. Make sure the first line is exactly: `#lang "project4.rkt"`
3. Write your Logo program below that line
4. Run it — your `project4.rkt` controls what happens

**Note:** You will need the `beautiful-racket` package if it is not already installed. Run this in the DrRacket REPL (or terminal):

```racket
(require (planet dmac/spin)) ; not this
```

Actually, run this in the terminal or DrRacket's package manager:

```
raco pkg install beautiful-racket
```

The starter `project4.rkt` includes `#lang br/quicklang` and the following provided helpers — you do not need to implement these:

- `CANVAS-WIDTH`, `CANVAS-HEIGHT`, `BLANK-CANVAS` — canvas size constants
- `next-x`, `next-y` — turtle movement math
- `draw-line` — draws a line segment on an image
- `list-set` — replaces an element in a list by index
- `tokenize` — breaks a line of text into Racket datums
- `turtle-module-begin` / `#%module-begin` — the macro that extracts your final image

---

## Part 1: Reading the Program

When Racket encounters `#lang "project4.rkt"`, it calls your `read-syntax` function to parse the program into a module. Finish implementing it.

### Problem 1.1: read-syntax

The function receives the program as a list of strings (one per line). Your job:

1. Filter out blank lines and comment lines (lines whose first non-whitespace character is `;`)
2. Tokenize each remaining line using the provided `tokenize` helper
3. Flatten all tokens into a single list and splice them into the module datum

Complete the two missing pieces in `read-syntax`:

```racket
(define (read-syntax path port)
  (define src-lines (port->lines port))
  (define filtered  ...)  ; remove blank and comment lines
  (define src-datums ...) ; tokenize each line, flatten into one list
  (define module-datum
    `(module turtle-mod "project4.rkt"
       (handle-turtle-cmds ,@src-datums)))
  (datum->syntax #f module-datum))
```

*Hint:* Use `filter` with a predicate that checks `(string-trim line)` — is it empty? Does it start with `";"`? Use `string=?` and `string-prefix?`.

*Hint:* `(map tokenize filtered)` gives you a list of lists. Use `(apply append ...)` to flatten it into one list.

*Test:* Temporarily add `(displayln src-datums)` inside `read-syntax` and run a small `.turtle` file. Make sure you see a flat list of symbols and numbers, with no blank entries.

### Problem 1.2: Understanding #%module-begin

The `turtle-module-begin` macro is provided for you:

```racket
(define-macro (turtle-module-begin EXPR)
  #'(#%module-begin
     (display (state-image EXPR))))
```

`EXPR` here is `(handle-turtle-cmds ...)` — the single expression produced by `read-syntax`. The macro calls `handle-turtle-cmds`, extracts the image from the final state using `state-image`, and displays it. DrRacket renders `2htdp/image` images inline in the output area.

**Question (no code required):** In the funstacker example, `#%module-begin` called `(first HANDLE-ARGS-EXPR)`. Why `first`? Why does the turtle version use `state-image` instead?

---

## Part 2: Turtle State

The turtle state holds everything needed to interpret Logo commands. Represent it as a 7-element list:

```
(list x y angle pen-down? color image pending)
  ;    0  1   2      3       4     5      6
```

- `x`, `y` — turtle position (numbers)
- `angle` — heading in radians (`0` = rightward; `(- (/ pi 2))` = upward)
- `pen-down?` — boolean; `#t` means draw as the turtle moves
- `color` — a color string like `"black"` or `"red"`
- `image` — the accumulated `2htdp/image` being drawn on
- `pending` — the most recent number seen; consumed by the next movement command

### Problem 2.1: State Accessors

Write seven accessor functions. Use `list-ref` or the `car`/`cadr`/... family.

```racket
(define test-s (list 10 20 0 #t "blue" BLANK-CANVAS 50))

(state-x test-s)       ; => 10
(state-y test-s)       ; => 20
(state-angle test-s)   ; => 0
(state-pen? test-s)    ; => #t
(state-color test-s)   ; => "blue"
(state-image test-s)   ; => BLANK-CANVAS
(state-pending test-s) ; => 50
```

### Problem 2.2: State Updaters

Write seven updater functions. Each takes a state and a new value and returns a new state with that one field replaced. Use the provided `list-set` helper.

```racket
(state-x (set-x test-s 99))       ; => 99
(state-y (set-y test-s 99))       ; => 99
(state-pen? (set-pen test-s #f))  ; => #f
(state-color (set-color test-s "green")) ; => "green"
; ... and so on for set-angle, set-image, set-pending
```

### Problem 2.3: initial-state

Write `initial-state`, the starting state for every Logo program: turtle centered on the canvas, pen up, color black, blank canvas, no pending argument.

```racket
(state-x initial-state)       ; => 250  (center of 500x500 canvas)
(state-y initial-state)       ; => 250
(state-angle initial-state)   ; => (- (/ pi 2))  (pointing upward)
(state-pen? initial-state)    ; => #f
(state-color initial-state)   ; => "black"
(state-pending initial-state) ; => 0
```

*Note:* In `2htdp/image`, y increases downward. An angle of `(- (/ pi 2))` points in the negative-y direction — upward on screen — which is Logo's traditional starting direction.

---

## Part 3: Command Dispatch

### Problem 3.1: handle-cmd

Write `handle-cmd` that takes a state and a single token and returns the updated state. This is the heart of your language — the direct parallel to the `cond` inside `handle-args`.

```racket
(define (handle-cmd state token)
  (cond
    [(number? token) ...]   ; store as pending argument
    [(equal? token 'FORWARD) ...]
    [(equal? token 'BACK) ...]
    [(equal? token 'RIGHT) ...]
    [(equal? token 'LEFT) ...]
    [(equal? token 'PENDOWN) ...]
    [(equal? token 'PENUP) ...]
    [else state]))          ; unknown token: ignore
```

For **FORWARD**: move the turtle `(state-pending state)` steps in its current direction. If the pen is down, draw a line from the old position to the new one. Use the provided `next-x`, `next-y`, and `draw-line` helpers.

For **BACK**: move the turtle `(state-pending state)` steps in the *opposite* direction (negate the distance, or add `pi` to the angle temporarily).

For **RIGHT**: rotate clockwise by `(state-pending state)` degrees. In screen coordinates (y-down), clockwise rotation *adds* to the angle. Convert degrees to radians with `(* deg (/ pi 180))`.

For **LEFT**: rotate counter-clockwise. Subtract from the angle.

```racket
; Tests (run these against your implementation):
(state-pending (handle-cmd initial-state 100))    ; => 100
(state-pen? (handle-cmd initial-state 'PENDOWN))  ; => #t
(state-pen? (handle-cmd initial-state 'PENUP))    ; => #f

; After PENDOWN then FORWARD 100, turtle should move up 100 pixels:
(define s1 (handle-cmd initial-state 'PENDOWN))
(define s2 (handle-cmd s1 100))
(define s3 (handle-cmd s2 'FORWARD))
(state-x s3)  ; => 250.0       (x unchanged when heading straight up)
(state-y s3)  ; => 150.0       (moved up 100 pixels)
```

**Your image should update correctly!** If you try `(state-image s3)` after the sequence above, you should see a line drawn on the canvas.

### Problem 3.2: handle-turtle-cmds

Write `handle-turtle-cmds` that processes a whole Logo program. It takes any number of tokens as arguments and folds over them using `handle-cmd`, starting from `initial-state`.

```racket
(define (handle-turtle-cmds . tokens)
  ...)
(provide handle-turtle-cmds)
```

Compare to the funstacker pattern side-by-side:

```racket
; Funstacker:                          ; Your turtle language:
(for/fold ([stack-acc empty])          (for/fold ([state initial-state])
          ([arg (in-list args)])                  ([token (in-list tokens)])
  (cond ...))                            (handle-cmd state token))
```

*Test:* Once this is working, run your first `.turtle` file! Here is a square:

```
#lang "project4.rkt"
PENDOWN
FORWARD 100
RIGHT 90
FORWARD 100
RIGHT 90
FORWARD 100
RIGHT 90
FORWARD 100
```

And a triangle:

```
#lang "project4.rkt"
PENDOWN
FORWARD 120
RIGHT 120
FORWARD 120
RIGHT 120
FORWARD 120
```

---

## Part 4: Extensions

### Problem 4.1: COLOR

Add a `COLOR` command. When the program contains `COLOR red`, subsequent lines should be drawn in red. Color names in Logo are plain symbols (`red`, `blue`, `green`, `orange`, etc.) — not strings.

The challenge: color names are symbols, not numbers, so they arrive in the token stream like any other symbol. You need to decide how to handle them. A few options:

- Detect known color symbols in the `cond` and immediately update `(state-color state)`
- Treat color names as a kind of "pending argument" in the same slot as numbers, and have `COLOR` consume it
- Add a second "pending" slot to your state

Pick the approach you find cleanest and add a brief comment explaining your choice.

```
#lang "project4.rkt"
COLOR red
PENDOWN
FORWARD 100
RIGHT 90
COLOR blue
FORWARD 100
RIGHT 90
COLOR green
FORWARD 100
RIGHT 90
COLOR orange
FORWARD 100
```

### Problem 4.2: SETPOS

Add a `SETPOS` command that teleports the turtle to an absolute position without drawing, regardless of pen state.

`SETPOS` requires *two* arguments: `SETPOS 100 200` moves the turtle to (100, 200). Since each token arrives one at a time, you'll need to think about how to accumulate two pending values. A list as the `pending` slot is one approach.

### Problem 4.3: REPEAT (Stretch Goal)

Add support for `REPEAT n ... END` blocks. This is the most challenging extension.

The difficulty: `for/fold` processes one token at a time with no lookahead. It can't naturally "group" a block of tokens and repeat it.

**Strategy:** Pre-process the token list *before* the fold. Write a function `expand-repeats` that finds every `REPEAT n ... END` sequence and replaces it with `n` copies of the inner tokens:

```racket
; Example:
(expand-repeats '(PENDOWN REPEAT 3 FORWARD 50 RIGHT 120 END))
; => '(PENDOWN FORWARD 50 RIGHT 120 FORWARD 50 RIGHT 120 FORWARD 50 RIGHT 120)
```

Then call `expand-repeats` on your token list before the fold in `handle-turtle-cmds`.

*Hint:* Write this recursively. When you see `'REPEAT` at the head of the list, grab the count (next element), collect tokens until `'END`, replicate the block, and recurse on the remainder. The base case is an empty list.

*Added Challenge:* Make `expand-repeats` handle nested `REPEAT`s (a `REPEAT` inside a `REPEAT`). You'll need to track nesting depth when collecting the inner block.

---

## Part 5: Your Logo Program

Write a Logo program that produces an interesting image. It should use at least three different commands and produce something you'd be proud to show off.

Some ideas:

- **Geometric patterns:** concentric squares, hexagonal grids, nested polygons
- **Stars:** a five-pointed star uses `RIGHT 144`; a six-pointed star uses two overlapping triangles
- **Spirograph-like curves:** use `REPEAT` with a small turn angle and many iterations
- **Abstract art:** don't overthink it — systematic repetition alone produces striking images

Here is a program that draws overlapping squares at increasing scales to get you inspired:

```
#lang "project4.rkt"
PENDOWN
FORWARD 50  RIGHT 90  FORWARD 50  RIGHT 90  FORWARD 50  RIGHT 90  FORWARD 50
RIGHT 10
FORWARD 60  RIGHT 90  FORWARD 60  RIGHT 90  FORWARD 60  RIGHT 90  FORWARD 60
RIGHT 10
FORWARD 70  RIGHT 90  FORWARD 70  RIGHT 90  FORWARD 70  RIGHT 90  FORWARD 70
RIGHT 10
FORWARD 80  RIGHT 90  FORWARD 80  RIGHT 90  FORWARD 80  RIGHT 90  FORWARD 80
```

Make something you'd enjoy looking at and that you're able to explain!

---

## Tips for Success

1. **Start with Part 2.** Your state accessors and updaters need to work before anything else can. Test them thoroughly before moving on.

2. **Test `handle-cmd` token by token.** Before running a `.turtle` file, call `handle-cmd` directly in DrRacket with `initial-state` and individual tokens. Watch the state evolve.

3. **Trace a square on paper first.** Write out exactly what the state should look like after each command in the square example: x, y, angle, pen. Then verify your code matches.

4. **Screen coordinates go downward.** `FORWARD` while facing "up" *decreases* y. The initial angle `(- (/ pi 2))` makes this work. If your turtle moves the wrong direction, check your angle arithmetic.

5. **Degrees vs. radians.** The `pending` slot stores a number in degrees (as the user wrote it). Your `handle-cmd` must convert to radians before updating the angle. A RIGHT 90 should change the angle by `(/ pi 2)`.

6. **Use `(displayln state)` inside `handle-cmd`.** Watching the state evolve is the fastest way to catch off-by-one errors in your angle or position math.

---

## Resources

- [2htdp/image documentation](https://docs.racket-lang.org/teachpack/2htdpimage.html)
- [Beautiful Racket / br/quicklang documentation](https://beautifulracket.com/) — the library powering `read-syntax` and `define-macro`
- [Logo programming language (Wikipedia)](https://en.wikipedia.org/wiki/Logo_(programming_language))
- [Turtle graphics (Wikipedia)](https://en.wikipedia.org/wiki/Turtle_graphics)
- *Mindstorms: Children, Computers, and Powerful Ideas* — Seymour Papert, 1980 (worth skimming!)
