#lang racket
(require racket/gui/base)

; make a filter function that filters only numbers greater than 10
(define (greater-than-10 lst) (filter (lambda (x) (> x 10)) lst))
(greater-than-10 '(5 15 20 30 4))

; what if I want to make a greater-than-x function?
(define (greater-than-10-2 lst) (filter (curryr > 10) lst)) ; the curry is the same as this (lambda (x) (> x 10))
(greater-than-10-2 '(5 15 20 30 4))

(define greater-than (compose (curry filter) (curryr >))) ; can handle any threshold and filter a list
; containing only elements greater than the threshold
((greater-than 10) '(5 15 20 30 4))


(define function
  (let ((times-called 0)) ; defines a local variable
    (lambda ()
      (set! times-called (+ 1 times-called)) ; mutates the local variabl
      times-called))) ; notice there are TWO expressions here: 1) mutation, 2) return value
(function)
(function)
(function)

(define frame (new frame% (label "Do you see what I mean?"))) ; % typically denotes a "class" (as you know them)


(define btn (new button%
                 (parent frame)
                 (label "Click Me!") ; label attribute
                 (callback (lambda (button event) ; callback attribute: calls the provided function on click
                             (send btn set-label  ; calls the set-label method with value of calling the function
                                   (number->string (function)))))))

;; we could also just substitute function into the callback argument instead!

(send frame show #t) ; calls the show method on the frame with argument true


;;; now let's implement a stack!

; define the stack "class" as a function
; define a local variable as the actual stack data (a list)
; define a "dispatcher": something that can turn symbols into functions (ex: ((S 'push) 5) should push 5 onto S
;;; - empty?
;;; - push
;;; - pop
;;; - else
; define those functions
; return the dispatcher so that we can "call functions" on the stack
(define (stack)
  (let ((the-stack '()))
    (define (dispatcher method-name) ; dispatcher is functionally as . operator in Java or Python
      (cond ((equal? method-name 'empty?) empty?)
            ((equal? method-name 'push) push)
            ((equal? method-name 'pop) pop)
            (else "Error!")))
    (define (push x)
      (cons x the-stack))
    (define (pop)
      (let ((top (car the-stack)))
        (set! the-stack (cdr the-stack))
        top))
    dispatcher))

(define S (stack))
((S 'push) 5)



    


  ;;; let's explore set! a little more

  (define b 3) 
  (define f (lambda (x) (* 2 (+ x b)))) 
  (define c (+ b 4)) 
  (set! b 5)
  (define z (f 4))   
  (define w c)       
  ; what will b, c, z, w contain?