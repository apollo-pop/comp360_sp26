#lang racket
;;; ============================================================
;;; COMP 360 - Midterm Exam 1
;;; ============================================================
;;;
;;; Name: ___________________________
;;; Date: ___________________________
;;;
;;; Instructions:
;;; - You may use DrRacket to write and test your code.
;;; - You may NOT use the internet, notes, or other resources.
;;; - Test cases are provided — uncomment them to verify your work.
;;; - Replace every 'todo with your solution.
;;; - Read each problem carefully before writing code.


;;; ============================================================
;;; QUESTION 1: count-satisfies
;;; ============================================================

;;; Write a recursive function (count-satisfies pred lst) that
;;; returns how many elements in lst satisfy the predicate pred.
;;;
;;; You may NOT use the built-in count, filter, or foldl/foldr.
;;;
;;; Examples:
;;;   (count-satisfies even? '(1 2 3 4 5))          => 2
;;;   (count-satisfies string? '(1 "a" 2 "b" 3))    => 2
;;;   (count-satisfies even? '())                    => 0
;;;   (count-satisfies positive? '(-3 -1 0 2 5))    => 2

(define (count-satisfies pred lst)
  'todo)

;;; Test cases (uncomment to test):
; (count-satisfies even? '(1 2 3 4 5))          ; => 2
; (count-satisfies string? '(1 "a" 2 "b" 3))    ; => 2
; (count-satisfies even? '())                    ; => 0
; (count-satisfies positive? '(-3 -1 0 2 5))    ; => 2


;;; ============================================================
;;; QUESTION 2: Fix the Scoping Bugs
;;; ============================================================

;;; Each snippet below has a scoping bug. Fix the code so it
;;; produces the expected output. You may only change the let/let*
;;; form — do not change the body expression or add new variables.

;;; --- 2a ---
;;; Expected result: 11
;;; Bug: the binding of y should see the NEW value of x, not the old one.

(define x-2a 10)

(let ([x 5]
      [y (+ x 1)])
  (+ x y))

;;; Your fix (rewrite the let/let* form so it evaluates to 11):
; 'todo


;;; --- 2b ---
;;; Expected result: "hello world"
;;; Bug: b should use the value of a defined in the same binding block.

(define a-2b "goodbye")

(let ([a "hello"]
      [b (string-append a " world")])
  b)

;;; Your fix (rewrite the let/let* form so it evaluates to "hello world"):
; 'todo


;;; --- 2c ---
;;; Expected result: 30
;;; Bug: the functions f and g need to be able to reference each other.
;;; Hint: which binding form allows mutually-visible definitions?

; (let ([f (lambda (n) (if (= n 0) 0 (+ n (g (- n 1)))))]
;       [g (lambda (n) (if (= n 0) 0 (+ n (f (- n 1)))))])
;   (f 10))

;;; Your fix (change the binding form so it evaluates to 30):
; 'todo


;;; ============================================================
;;; QUESTION 3: Rewrite Using Curry/Curryr
;;; ============================================================

;;; For each expression below, rewrite it using curry or curryr
;;; so that it produces the same result. Do NOT use lambda.

(define nums '(1 2 3 4 5))

;;; 3a: Add 10 to every number
;;; Original: (map (lambda (x) (+ x 10)) nums)
;;; Expected: '(11 12 13 14 15)

; (map 'todo nums)


;;; 3b: Keep only numbers greater than 3
;;; Original: (filter (lambda (x) (> x 3)) nums)
;;; Expected: '(4 5)
;;; Hint: (> x 3) means "is x greater than 3?"
;;;       Think about which argument position x fills.

; (filter 'todo nums)


;;; 3c: Raise every number to the 2nd power
;;; Original: (map (lambda (x) (expt x 2)) nums)
;;; Expected: '(1 4 9 16 25)
;;; Hint: (expt base power) — which argument are you fixing?

; (map 'todo nums)


;;; ============================================================
;;; QUESTION 4: Tail Recursion Conversion — zip
;;; ============================================================

;;; Here is a non-tail-recursive function that interleaves
;;; two lists into a single list:

(define (zip-not-tr lst1 lst2)
  (cond
    [(null? lst1) lst2]
    [(null? lst2) lst1]
    [else (cons (car lst1)
                (cons (car lst2)
                      (zip-not-tr (cdr lst1) (cdr lst2))))]))

;;; Examples:
;;;   (zip-not-tr '(1 2 3) '(a b c))     => '(1 a 2 b 3 c)
;;;   (zip-not-tr '(1 2) '(a b c d))     => '(1 a 2 b c d)
;;;   (zip-not-tr '() '(x y))            => '(x y)

;;; Convert zip to a tail-recursive version.
;;; Remember the methodology:
;;;   1. Create a helper with an accumulator
;;;   2. The old base case return value becomes the initial accumulator
;;;   3. Do the computation first, then make the recursive call last
;;;   4. You may need to reverse the accumulator at the end

(define (zip lst1 lst2)
  'todo)

;;; Test cases (uncomment to test):
; (zip '(1 2 3) '(a b c))     ; => '(1 a 2 b 3 c)
; (zip '(1 2) '(a b c d))     ; => '(1 a 2 b c d)
; (zip '() '(x y))            ; => '(x y)
; (zip '(1 2 3) '())          ; => '(1 2 3)


;;; ============================================================
;;; QUESTION 5: Closure — make-toggle
;;; ============================================================

;;; Write a function (make-toggle val1 val2) that returns a
;;; zero-argument function. Each time the returned function is
;;; called, it alternates between returning val1 and val2.
;;; The first call should return val1.
;;;
;;; Hint: You will need a mutable variable captured by the
;;; closure. Use set! to update it.
;;;
;;; Examples:
;;;   (define t (make-toggle "on" "off"))
;;;   (t)   ; => "on"
;;;   (t)   ; => "off"
;;;   (t)   ; => "on"
;;;   (t)   ; => "off"

(define (make-toggle val1 val2)
  'todo)

;;; Test cases (uncomment to test):
; (define t (make-toggle "on" "off"))
; (t)   ; => "on"
; (t)   ; => "off"
; (t)   ; => "on"
; (define t2 (make-toggle 0 1))
; (t2)  ; => 0
; (t2)  ; => 1
; (t)   ; => "off"  (t and t2 are independent)


;;; ============================================================
;;; QUESTION 6: Putting It All Together — make-transformer
;;; ============================================================

;;; 6a: Write a function (make-transformer ops) where ops is a
;;; list of single-argument functions. It returns a NEW function
;;; that applies every function in ops to its argument, from
;;; left to right.
;;;
;;; Hint: Think about foldl — the accumulator is the value
;;; being threaded through the functions.
;;;
;;; Examples:
;;;   (define t (make-transformer (list add1 add1 add1)))
;;;   (t 0)   ; => 3
;;;
;;;   (define t2 (make-transformer (list add1 (lambda (x) (* x 2)))))
;;;   (t2 5)  ; => 12   (because 5 -> 6 -> 12)

(define (make-transformer ops)
  'todo)

;;; Test cases (uncomment to test):
; (define t (make-transformer (list add1 add1 add1)))
; (t 0)    ; => 3
; (t 10)   ; => 13
;
; (define t2 (make-transformer (list add1 (lambda (x) (* x 2)))))
; (t2 5)   ; => 12
;
; (define empty-t (make-transformer '()))
; (empty-t 42)  ; => 42


;;; 6b: Now WITHOUT using lambda, use make-transformer and
;;; curry/curryr to build a function that takes a number and:
;;;   1. Adds 1
;;;   2. Multiplies by 10
;;;   3. Subtracts 5
;;;
;;; So (my-transform 3) => 35   because 3 -> 4 -> 40 -> 35

; (define my-transform (make-transformer (list 'todo 'todo 'todo)))

;;; Test cases (uncomment to test):
; (my-transform 3)    ; => 35
; (my-transform 0)    ; => 5
; (my-transform 10)   ; => 105
