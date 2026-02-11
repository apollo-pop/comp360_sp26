#lang racket
;;; COMP 360 - Day 12 Practice Problems
;;; Closures with Mutation, Callbacks, and Mutable State

;;; Key concepts:
;;; - set! mutates a variable in the current environment
;;; - set! does not return a value; use begin for sequencing
;;; - Closures can capture mutable state (let over lambda pattern)
;;; - Callbacks: functions passed to a library, called when events occur
;;; - Dispatch pattern: closures returning a "method selector" function
;;; - cons cells are immutable in Racket; mcons cells are mutable


;;; ============================================================
;;; PROBLEM 1: Closure Review — make-counter-from
;;; ============================================================

;;; 1a: Write a function (make-counter-from start step) that returns
;;; a function which returns the next value in a sequence each time
;;; it's called. The first call returns start, the next returns
;;; start + step, then start + 2*step, etc.

(define (make-counter-from start step)
  'todo)

;;; Test cases (uncomment to test):
; (define by-threes (make-counter-from 0 3))
; (by-threes)   ; => 0
; (by-threes)   ; => 3
; (by-threes)   ; => 6
;
; (define from-ten (make-counter-from 10 -1))
; (from-ten)    ; => 10
; (from-ten)    ; => 9
; (from-ten)    ; => 8


;;; ============================================================
;;; PROBLEM 2: Simple UI with Callbacks
;;; ============================================================

;;; This problem uses Racket's GUI library. Uncomment the require
;;; below when you're ready to run it.

(require racket/gui/base)

;;; 2a: Create and show a frame with the label "Toggle App".


;;; 2b: Add a message widget that initially displays "OFF".
;;; Then add a "Toggle" button whose callback alternates the
;;; message between "ON" and "OFF" each time it's clicked.
;;;
;;; The callback must use a closure to track the boolean state.
;;; Do NOT use any top-level variables for the state.
;;;
;;; Hint: The callback receives two arguments (button event).
;;; Use (send msg set-label ...) to update the message.

; (define msg (new message% (parent frame) (label "OFF")))
;
; (define toggle-btn
;   (new button% (parent frame)
;     (label "Toggle")
;     (callback 'todo)))   ; replace 'todo with your closure


;;; 2c: Add a "Log" button whose callback prints
;;; "Button pressed N times" to the console each click, where
;;; N increases each time. Use a closure for the counter.

; (define log-btn
;   (new button% (parent frame)
;     (label "Log")
;     (callback 'todo)))   ; replace 'todo with your closure


;;; 2d: Add a "Reset" button that sets the toggle back to "OFF"
;;; and the log counter back to 0.
;;;
;;; Hint: You need the toggle and log closures to expose a way
;;; to reset themselves. Consider having each return TWO functions
;;; (the callback and a resetter), or use the dispatch pattern
;;; from the new-stack example in the notes.
;;;
;;; Sketch your approach here, then implement it:
;;; Approach:

; (define reset-btn
;   (new button% (parent frame)
;     (label "Reset")
;     (callback 'todo)))   ; replace 'todo with your closure

;;; Finally, show the frame:
; (send frame show #t)


;;; ============================================================
;;; PROBLEM 3: Mutable State — make-history (Dispatch Pattern)
;;; ============================================================

;;; Write a function (make-history) that returns a dispatch function
;;; (like the new-stack example from class) supporting three methods:
;;;
;;;   'record  — takes a value and adds it to the history
;;;   'current — returns the most recently recorded value,
;;;              or "nothing yet" if the history is empty
;;;   'undo!   — reverts to the previous value
;;;              (error if nothing to undo)
;;;
;;; Use set! to mutate a local list that stores the history.

(define (make-history)
  'todo)

;;; Test cases (uncomment to test):
; (define h (make-history))
; ((h 'current))              ; => "nothing yet"
; ((h 'record) "draft 1")
; ((h 'record) "draft 2")
; ((h 'current))              ; => "draft 2"
; ((h 'undo!))
; ((h 'current))              ; => "draft 1"
; ((h 'undo!))
; ((h 'current))              ; => "nothing yet"
; ((h 'undo!))                ; => error: "Nothing to undo"


;;; Follow-up questions:

;;; 3a: What variable(s) does the closure capture?
;;; Draw (or describe) the environment diagram after (make-history)
;;; is called.
;;; Answer:

;;; 3b: Could you implement make-history without set!? Why or why not?
;;; Answer:

;;; 3c: What would happen if you used cons/car/cdr for the internal
;;; history list but accidentally tried to call set-mcar! on it?
;;; Answer:
