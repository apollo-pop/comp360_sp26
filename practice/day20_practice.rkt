#lang br/quicklang
;;; COMP 360 - Day 20 Practice
;;; Extending funstacker
;;;
;;; For each problem below, modify funstacker.rkt in the notes/funstacker folder.
;;; Remember: funstacker uses for/fold -- no mutation, no set!
;;;
;;;
;;; ============================================================
;;; PROBLEM 1: Exponentiation
;;; ============================================================
;;;
;;; Add support for exponentiation using Racket's built-in expt function.
;;;
;;; 1a: The current handler applies op like this:
;;;
;;;       (arg (first stack-acc) (second stack-acc))
;;;
;;;     For + and *, order doesn't matter. For expt, it does.
;;;     If the stack is (3 2 ...) when expt is processed (i.e. 3 was pushed last),
;;;     which argument should be the base and which the exponent?
;;;     Write the correct (expt ...) expression using first/second.
;;; Answer:
;;;
;;; 1b: Add expt to the cond in handle-args. You'll need a separate branch
;;;     (not the same as the + / * branch) because of the argument order.
;;;     Add expt to the provide list as well.
;;;
;;; Test with:
;;;   #lang reader "funstacker.rkt"
;;;   2
;;;   3
;;;   expt
;;;   ; expected: 8
;;;
;;; 1c: Trace the for/fold accumulator after each iteration for the program above.
;;;
;;;     arg       stack-acc (after this step)
;;;     2         ???
;;;     3         ???
;;;     expt      ???
;;;
;;; 1d: What does the program output?
;;; Answer:
;;;
;;; 1e: Write a funstacker program to compute (3^2)^2 = 81.


;;; ============================================================
;;; PROBLEM 2: dump
;;; ============================================================
;;;
;;; Add a dump operator that displays the top of the stack and
;;; resets the stack to empty, so computation can continue fresh.
;;;
;;; In the mutable stacker, resetting required set!. In funstacker,
;;; the stack is the for/fold accumulator -- you can reset it by
;;; simply returning empty from that branch.
;;;
;;; 2a: You can add custom functions in a number of ways.
;;;     The important thing: dump (not 'dump) will show up in your
;;;     module. So you need to provide a dump variable/function.
;;;     Your dump can be bound to -anything- so that (equal? arg dump) fires.
;;;     (Can you verify this?)  
;;; Answer:
;;;
;;; 2b: Add a dump branch to the cond in handle-args:
;;;       - display the top of the stack
;;;       - return empty (the new accumulator)
;;;     Provide dump.
;;;
;;; Test with:
;;;   #lang reader "funstacker.rkt"
;;;   3
;;;   5
;;;   +
;;;   dump
;;;   10
;;;   2
;;;   *
;;;   ; expected output: 8 then 20
;;;
;;; 2c: Trace the for/fold accumulator step by step for the program above.
;;;
;;;     arg       stack-acc (after this step)
;;;     3         ???
;;;     5         ???
;;;     +         ???
;;;     dump      ???  (and what is printed here?)
;;;     10        ???
;;;     2         ???
;;;     *         ???
;;;
;;; 2d: The expander always does (display (first HANDLE-ARGS-EXPR)) at the end.
;;;     What happens if dump is the last operation in the program and the
;;;     stack is empty when the expander tries to display?
;;; Answer:


;;; ============================================================
;;; PROBLEM 3: for/fold -> foldl
;;; ============================================================
;;;
;;; Rewrite the for/fold loop with a foldl function call.
;;; Remember: (foldl folding-func base lst)
;;;    where folding-func takes two arguments: a value of lst and an accumulator
;;;    and base is the base case
