#lang br/quicklang

(define (handle [arg #f]) ; optional argument which defaults to #f
  (cond (equal? arg +) (push-stack! (+ (pop-stack!) (pop-stack!)))
        (equal? arg *) (push-stack! (* (pop-stack!) (pop-stack!)))
        (number? arg) (push-stack! arg)))