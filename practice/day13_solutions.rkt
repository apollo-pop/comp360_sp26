#lang racket
;;; COMP 360 - Day 13 Practice Problems
;;; Closures, Callbacks, Currying, and GUI Integration

;;; Key concepts:
;;; - Closures capture the environment where they are defined
;;; - Callbacks are functions passed to a library, called when events occur
;;; - button% callbacks receive two arguments: (button event)
;;; - curry fixes arguments from the LEFT:  (curry f a) => (lambda (b) (f a b))
;;; - curryr fixes arguments from the RIGHT: (curryr f b) => (lambda (a) (f a b))
;;; - send calls methods on objects: (send obj method-name args ...)


;;; ============================================================
;;; PROBLEM 1: Closure/Curry/Lambda Tracing
;;; ============================================================

;;; For each snippet below, predict the output WITHOUT running
;;; the code. Then uncomment to verify.

;;; 1a:
(define make-adder (lambda (n) (lambda (x) (+ n x))))
(define add5 (make-adder 5))
(define add10 (make-adder 10))

(add5 3)
(add10 3)
(add5 (add10 0))

;;; What is (add5 3)?
;;; Answer: 8
;;; What is (add10 3)?
;;; Answer: 13
;;; What is (add5 (add10 0))?
;;; Answer: 15
;;; Explanation (what does each closure capture?):
; make-adder creates a closure which captures the value of the variable x
; for add5, that's 5
; for add10, that's 10


;;; 1b:
(define mystery
  (let ((x 1))
    (lambda (y)
      (let ((result (+ x y)))
        (set! x (+ x 1))
        result))))

(mystery 10)
(mystery 10)
(mystery 10)

;;; What are the three results?
;;; (mystery 10) => first call:  11
;;; (mystery 10) => second call: 12
;;; (mystery 10) => third call:  13
;;; Explanation (what happens to x across calls?):
;;; In other words, does x get reset to 1 every call or not?

; No, x doesn't reset every call: since mystery evaluates to a lambda,
; x is only defined once when mystery is defined.
; every time mystery is -called- the lambda mutates x


;;; 1c:
(define apply-twice (lambda (f) (lambda (x) (f (f x)))))
(define inc (lambda (x) (+ x 1)))
(define double (lambda (x) (* x 2)))

((apply-twice inc) 5)
((apply-twice double) 3)
((apply-twice (apply-twice inc)) 0)

;;; What is ((apply-twice inc) 5)?
;;; Answer: 7
;;; What is ((apply-twice double) 3)?
;;; Answer: 12
;;; What is ((apply-twice (apply-twice inc)) 0)?
;;; Answer: 4
;;; Explanation (for the last one, what function does
;;;   (apply-twice inc) return? Then what does apply-twice
;;;   do to THAT function?):
;   Effectively: (inc (inc (inc (inc 0))))


;;; 1d:
(define (compose f g) (lambda (x) (f (g x))))
(define add1 (curry + 1))
(define dbl (curry * 2))

((compose add1 dbl) 5)
((compose dbl add1) 5)
((compose add1 add1) 5)

;;; What is ((compose add1 dbl) 5)?
;;; Answer: (add1 (dbl 5)) => 11
;;; What is ((compose dbl add1) 5)?
;;; Answer: 12
;;; What is ((compose add1 add1) 5)?
;;; Answer: 7
;;; Explanation (does the order of f and g matter?):
; Yes!!


;;; ============================================================
;;; PROBLEM 2: Fractal Scene Gallery
;;; ============================================================

;;; In this problem you will build a GUI that displays your
;;; fractal scenes from Project 2. Each scene gets a button;
;;; clicking the button updates a label with the scene title
;;; and displays the scene.
;;;
;;; You will need to import YOUR project 2 file. If your
;;; drawing functions are in "project2.rkt", you can use:
;;;
;;;   (require "project2.rkt")
;;;
;;; ...but only if you (provide ...) the functions you need
;;; in that file. Alternatively, you can copy your drawing
;;; functions into this file.

;;; Ex: (provide sierpinski) will expose sierpinski publicly

;;; Uncomment these when you're ready:
(require racket/gui/base)
(require (except-in 2htdp/image make-color make-pen))
(require "../project_solutions/project2_solution.rkt")
(require (only-in pict pict->bitmap)) 


;;; --- 2a: Define your scenes ---
;;; Each scene is a pair: a title string and a function that
;;; produces the image. Using a thunk (zero-argument lambda)
;;; delays the drawing until the button is clicked.
;;;
;;; Use your own drawing scenes from Project 2.
;;; Or use these (you'll have to provide helpers!)

(define scenes
  (list
   (cons "Sierpinski Triangle"
         (lambda () (sierpinski-triangle
                     (cons 150 10) (cons 10 290) (cons 290 290) 5)))
   (cons "Koch Snowflake"
         (lambda () (koch-snowflake (cons 150 150) 120 4)))
   (cons "Fractal Plant"
         (lambda () (draw-l-system
                     "X"
                     (list (cons #\X "F+[[X]-X]-F[-FX]+X")
                           (cons #\F "FF"))
                     4 4 (/ (* 25 pi) 180) 150 280 (- (/ pi 2)))))))


;;; --- 2b: Create the frame and layout ---
;;; Set up a frame and a vertical panel to hold the widgets.

(define frame (new frame% (label "Fractal Gallery")
                   (width 400) (height 500)))
(define panel (new vertical-panel% (parent frame)))


;;; --- 2c: Create the title label ---
;;; This label displays the name of the currently selected scene.
;;; It should start with a default message.

(define title-label (new message% (parent panel)
                         (label "Select a scene")))


;;; --- 2d: Create a canvas to display images ---
;;; A canvas% lets you draw images. The paint-callback is called
;;; whenever the canvas needs to redraw itself.
;;;
;;; We'll store the current image in a variable that the
;;; paint-callback reads. When a button is clicked, we update
;;; the image and tell the canvas to refresh.
;;;
;;; Read this code carefully!!

(define current-image #f)

(define canvas (new canvas% (parent panel)
                    (min-width 300) (min-height 300)
                    (paint-callback
                     (lambda (canvas dc)
                       (when current-image
                         ;; Draw the bitmap of image at coordinates (0, 0)
                         (send dc draw-bitmap current-image 0 0))))))

(define (image->bitmap img)
  (let* ([width  (image-width img)]
         [height (image-height img)]
         [bm (make-bitmap width height)]
         [dc (new bitmap-dc% [bitmap bm])])
    (send dc draw-bitmap (pict->bitmap img) 0 0)
    bm))
;;; --- 2e: Create a button for each scene ---
;;; Write a function (make-scene-button scene) that takes one
;;; entry from the scenes list (a pair of title and thunk) and
;;; creates a button in the panel.
;;;
;;; When clicked, the button should:
;;;   1. Update title-label with the scene's title
;;;   2. Set current-image to the result of calling the scene's thunk
;;;   3. Tell the canvas to refresh using (send canvas refresh)
;;;
;;; Hint: Use (car scene) for the title and ((cdr scene)) to
;;; call the thunk and get the image.

(define (make-scene-button scene)
  (new button% (parent panel)
       (label (car scene))
       (callback (lambda (button event)
                   (send title-label set-label (car scene))
                   (set! current-image (image->bitmap ((cdr scene))))
                   (send canvas refresh)))))    ; replace 'todo with your callback, recall what arguments a button callback needs!


;;; --- 2f: Create all the buttons ---
;;; Use map to call make-scene-button on every
;;; scene in your scenes list.
; for saving images to files
(define (save-2htdp-image img filename)
  (let* ([width (image-width img)]
         [height (image-height img)]
         [bm (make-bitmap width height)]
         [dc (new bitmap-dc% [bitmap bm])])
    ; Draw the 2htdp image onto the bitmap's drawing context
    (send dc draw-bitmap (pict->bitmap img) 0 0)
    ; Save to file
    (send bm save-file (string-append filename ".png") 'png)))

; use the above function and your scenes list
; to save all of your scenes to files:
; use (car scene) as the filename
; and (cdr scene) as the image
(map (lambda (scene) (save-2htdp-image ((cdr scene)) (car scene))) scenes)
(map make-scene-button scenes)


;;; --- 2g: Show the frame ---

(send frame show #t)


;;; CHALLENGE: Can you add a "Random Scene" button that picks
;;; a random scene from the list and displays it?
;;; Hint: (list-ref lst (random (length lst)))


;;; ============================================================
;;; PROBLEM 3: Understanding Curry — Step by Step
;;; ============================================================

;;; Currying lets you partially apply a function, producing a
;;; new function that "remembers" some arguments. This is useful
;;; when you need to pass a function somewhere (like map or
;;; filter) but the function takes more arguments than expected.

;;; --- 3a: Curry basics ---
;;; For each expression, write the equivalent lambda expression
;;; AND predict the result.

;;; Example:
;;;   (curry + 1)  is equivalent to  (lambda (x) (+ 1 x))
;;;   ((curry + 1) 5)  => 6

;;; Your turn:
;;; (curry * 3)        is equivalent to: (lambda (x) (* 3 x))
;;; ((curry * 3) 10)   => ? 30

;;; (curry string-append "hello ")  is equivalent to: (lambda (x) (string-append "hello " x))
;;; ((curry string-append "hello ") "world")  => "hello world"

;;; (curryr expt 2)    is equivalent to: (lambda (x) (expt x 2)
;;; ((curryr expt 2) 5)  => 5^2 = 25
;;; Hint: (expt base power). curryr fixes the RIGHTMOST argument.

;;; (curryr - 1)       is equivalent to: (lambda (x) (- x 1))
;;; ((curryr - 1) 10)  => 9
;;; How is this different from (curry - 1)?
;;; ((curry - 1) 10)   => -9


;;; --- 3b: Curry with map ---
;;; For each task, write the map call TWO ways:
;;; once with a lambda, once with curry/curryr.

(define nums '(1 2 3 4 5))
(define words '("hello" "world" "racket"))

;;; Task: Add 10 to every number in nums
;;; With lambda:
; (map (lambda (x) (+ x 10)) nums)
;;; With curry:
; (map (curry + 10) nums)

;;; Task: Multiply every number by -1
;;; With lambda:
; (map (lambda (x) (* -1 x)) nums)
;;; With curry:
; (map (curry * -1) nums)

;;; Task: Raise every number to the 3rd power
;;; Recall: (expt base power)
;;; With lambda:
; (map (lambda (x) (expt x 3)) nums)
;;; With curry or curryr (which do you need here and why?):
; (map (curryr expt 3) nums)

;;; Task: Append "!" to every string in words
;;; With lambda:
; (map (lambda (s) (string-append s "!")) words)
;;; With curry or curryr:
; (map (curryr string-append "!") words)


;;; --- 3c: Curry with filter ---
;;; For each task, write it with lambda AND with curry/curryr.

;;; Task: Keep only numbers greater than 3
;;; With lambda:
; (filter (lambda (x) (> x 3)) nums)
;;; With curry or curryr:
; (filter (curryr > 3) nums)

;;; Task: Keep only strings longer than 5 characters
;;; Hint: (string-length s) returns the length of s
;;; With lambda:
; (filter (lambda (s) (> (string-length s) 5)) words)
;;; Can this be done with a single curry/curryr? Why or why not?
;;; Answer: No, you need to compose two curries:
(filter (compose (curryr > 5) (curry string-length)) '("hey" "there" "friend"))



;;; --- 3d: Curry for building functions ---
;;; Sometimes curry is useful not with map/filter, but for
;;; creating reusable functions from general ones.

;;; Given:
(define (in-range? lo hi x) (and (>= x lo) (<= x hi)))

;;; Use curry to define a function that checks if a number
;;; is a valid percentage (between 0 and 100).
;;; Do NOT use lambda.

; (define valid-percent? 'todo)

;;; Test (uncomment to test):
; (valid-percent? 50)    ; => #t
; (valid-percent? -1)    ; => #f
; (valid-percent? 100)   ; => #t
; (valid-percent? 101)   ; => #f

;;; Now use your valid-percent? with filter:
; (filter valid-percent? '(-5 0 50 99 100 101 200))
; ; => '(0 50 99 100)


;;; --- 3e: When curry DOESN'T work ---
;;; Explain why you CANNOT use curry to replace this lambda:

; (map (lambda (x) (+ (* x x) 1)) '(1 2 3 4))

;;; Answer (why can't a single curry/curryr call replace this?):


;;; Could you do it with compose and curry combined? Try it:
; (map (compose 'todo 'todo) '(1 2 3 4))    ; => '(2 5 10 17)
