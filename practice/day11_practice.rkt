#lang racket
;;; COMP 360 - Day 11 Practice Problems
;;; Closures and Currying

;;; Key concepts:
;;; - A closure = code + the environment when the function was defined
;;; - Currying: partially applying a function to get a new function
;;;   that accepts the remaining arguments
;;; - (curry f x1 x2 ...) fixes args from the LEFT
;;; - (curryr f x1 x2 ...) fixes args from the RIGHT
;;; - When you write (lambda (y) (f x y)), you can replace it with (curry f x)
;;; - When you write (lambda (y) (f y x)), you can replace it with (curryr f x)


;;; ============================================================
;;; PROBLEM 1: Closure Tracing
;;; ============================================================

;;; For each snippet below, predict the output WITHOUT running
;;; the code. Then uncomment to verify.

;;; 1a:
; (define make-scale
;   (lambda (factor offset)
;     (let ((adj (+ factor offset)))
;       (lambda (x)
;         (* adj x)))))
;
; (define p (make-scale 2 1))
; (define q (make-scale 3 -1))
;
; (p 5)
; (q 5)

;;; What is (p 5)?
;;; Answer:
;;; What is (q 5)?
;;; Answer:
;;; Explanation (what is adj bound to in each closure?):


;;; 1b:
; (define make-checker
;   (lambda (lo hi)
;     (let ((mid (/ (+ lo hi) 2)))
;       (lambda (x)
;         (if (> x mid) 'upper 'lower)))))
;
; (define check-grade (make-checker 0 100))
; (define check-age (make-checker 0 18))
;
; (check-grade 80)
; (check-grade 40)
; (check-age 12)
; (check-age 3)

;;; What are the four results?
;;; (check-grade 80) =>
;;; (check-grade 40) =>
;;; (check-age 12)   =>
;;; (check-age 3)    =>
;;; Explanation (what is mid bound to in each closure?):


;;; ============================================================
;;; PROBLEM 2: Closure Trace with Nested Environments
;;; ============================================================

;;; Trace through the following code step by step.
;;; For each line, describe what happens (binding, frame creation,
;;; closure creation, variable lookup).

; 1  (define k 10)
; 2  (define (build a b)
; 3    (let ((sum (+ a b)))
; 4      (lambda (x) (* sum (+ x k)))))
; 5  (define fn1 (build 2 3))
; 6  (define fn2 (build 1 1))
; 7  (fn1 0)
; 8  (fn2 5)

;;; Step by step:
;;; Line 1:
;;; Line 2-4:
;;; Line 5 (what frame(s) created? what is sum? what closure is returned?):
;;; Line 6 (what frame(s) created? what is sum? what closure is returned?):
;;; Line 7 (what frame created? what is the result?):
;;; Line 8 (what frame created? what is the result?):
;;;
;;; What is (fn1 0)?
;;; Answer:
;;; What is (fn2 5)?
;;; Answer:


;;; ============================================================
;;; PROBLEM 3: Writing Closures
;;; ============================================================

;;; 3a: Write a function (make-grader cutoff) that returns a function
;;; which takes a score and returns 'pass if the score is >= cutoff,
;;; and 'fail otherwise.

(define (make-grader cutoff)
  'todo)

;;; Test cases (uncomment to test):
; (define pass60 (make-grader 60))
; (define pass90 (make-grader 90))
; (pass60 75)    ; => 'pass
; (pass60 50)    ; => 'fail
; (pass90 85)    ; => 'fail
; (pass90 95)    ; => 'pass


;;; 3b: Write a function (make-clamp lo hi) that returns a function
;;; which takes a number and clamps it to the range [lo, hi].
;;; i.e., returns lo if x < lo, hi if x > hi, otherwise x.

(define (make-clamp lo hi)
  'todo)

;;; Test cases (uncomment to test):
; (define clamp-percent (make-clamp 0 100))
; (clamp-percent 50)    ; => 50
; (clamp-percent -10)   ; => 0
; (clamp-percent 150)   ; => 100
; (define clamp-byte (make-clamp 0 255))
; (clamp-byte 300)      ; => 255


;;; ============================================================
;;; PROBLEM 4: Currying - Write It Both Ways
;;; ============================================================

;;; For each problem below, FIRST write the solution using an
;;; explicit lambda, THEN rewrite using curry/curryr.
;;; This may help you see when currying is a practical alternative.

;;; 4a: Write a call to map that triples every element of lst.

(define lst-4a '(1 2 3 4 5))

;;; With lambda:
; (map ??? lst-4a)

;;; With curry:
; (map ??? lst-4a)


;;; 4b: Write a call to filter that keeps only numbers less than 10.

(define lst-4b '(3 7 10 15 2 9))

;;; With lambda:
; (filter ??? lst-4b)

;;; With curry or curryr (which reads more naturally here?):
; (filter ??? lst-4b)


;;; 4c: Write a call to map that appends "!" to every string.
;;; (string-append joins strings together)

(define lst-4c '("hello" "world" "racket"))

;;; With lambda:
; (map ??? lst-4c)

;;; With curry or curryr:
; (map ??? lst-4c)


;;; 4d: Write a call to map that raises every number to the 3rd power.
;;; Recall (expt base power).

(define lst-4d '(2 3 4 5))

;;; With lambda:
; (map ??? lst-4d)

;;; With curry or curryr (think carefully about argument order!):
; (map ??? lst-4d)


;;; ============================================================
;;; PROBLEM 5: Currying Higher-Order Functions
;;; ============================================================

;;; These problems show where currying really shines: partially
;;; applying higher-order functions like foldr, andmap, ormap.

;;; 5a: Define product-list, a function that takes a list and returns
;;; the product of all elements. (Like sum-list but with * and 1.)

;;; Without currying:
(define (product-list-ok lst) (foldr * 1 lst))

;;; With currying (point-free):
; (define product-list 'todo)

;;; Test (uncomment to test):
; (product-list '(1 2 3 4 5))    ; => 120


;;; 5b: Define all-positive?, a function that returns #t if every
;;; element in a list is greater than 0.

;;; Without currying:
(define (all-positive?-ok lst)
  (andmap (lambda (x) (> x 0)) lst))

;;; With currying (point-free):
; (define all-positive? 'todo)

;;; Test (uncomment to test):
; (all-positive? '(1 2 3))     ; => #t
; (all-positive? '(1 -2 3))   ; => #f


;;; 5c: Define contains-zero?, a function that returns #t if any
;;; element in the list is equal to 0.

;;; Without currying:
(define (contains-zero?-ok lst)
  (ormap (lambda (x) (= x 0)) lst))

;;; With currying (point-free):
; (define contains-zero? 'todo)

;;; Test (uncomment to test):
; (contains-zero? '(1 2 0 4))   ; => #t
; (contains-zero? '(1 2 3 4))   ; => #f


;;; 5d: Define string-list, a function that takes a list of numbers
;;; and converts each to a string using number->string.
;;; Recall (map f lst) applies f to every element.

;;; Without currying:
(define (string-list-ok lst)
  (map number->string lst))

;;; With currying (point-free):
; (define string-list 'todo)

;;; Test (uncomment to test):
; (string-list '(1 2 3))   ; => '("1" "2" "3")


;;; ============================================================
;;; PROBLEM 6: Closure + Currying Combined
;;; ============================================================

;;; 6a: Write a function (make-filter-above n) that returns a function
;;; which takes a list and filters out all elements <= n.

;;; Without currying:
(define (make-filter-above-ok n)
  (lambda (lst)
    (filter (lambda (x) (> x n)) lst)))

;;; With currying (replace both lambdas):
; (define make-filter-above 'todo)

;;; Test (uncomment to test):
; (define above5 (make-filter-above 5))
; (above5 '(1 3 5 7 9))    ; => '(7 9)


;;; 6b: Write a function (make-mapper f) that returns a function
;;; which maps f over any list it receives. Do it both ways.

;;; Without currying:
(define (make-mapper-ok f)
  (lambda (lst) (map f lst)))

;;; With currying:
; (define make-mapper 'todo)

;;; Test (uncomment to test):
; (define double-all (make-mapper (curry * 2)))
; (double-all '(1 2 3 4))    ; => '(2 4 6 8)


;;; ============================================================
;;; ADDITIONAL CHALLENGE: Compose + Curry Pipeline
;;; ============================================================

;;; Using compose, curry, and/or curryr, write a SINGLE expression
;;; (no lambda allowed!) that takes a list of numbers and returns
;;; the sum of all the even numbers in the list.
;;;
;;; Hint: break it into steps:
;;;   1. filter to keep only even numbers (even? is a built-in)
;;;   2. fold to sum them
;;; Then compose those two steps.

; (define sum-evens 'todo)

;;; Test (uncomment to test):
; (sum-evens '(1 2 3 4 5 6))    ; => 12
; (sum-evens '(1 3 5))          ; => 0
