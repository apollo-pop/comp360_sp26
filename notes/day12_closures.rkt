#lang racket
(require racket/gui/base)


(define function
  (let ((times-called 0)) ; defines a local variable
    (lambda ()
      (set! times-called (+ 1 times-called)) ; mutates the local variabl
      times-called))) ; notice there are TWO expressions here: 1) mutation, 2) return value


(define frame (new frame% (label "Example"))) ; % typically denotes a "class" (as you know them)


(define btn (new button% (parent frame)
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



;;; let's explore set! a little more

(define b 3) 
(define f (lambda (x) (* 2 (+ x b)))) 
(define c (+ b 4)) 
(set! b 5)
(define z (f 4))   
(define w c)       
; what will b, c, z, w contain?