#lang br/quicklang

(define (read-syntax path port)
  (define src-lines (port->lines port))
  (define src-datums (format-datums '~a src-lines))
  (define module-datum `(module stacker-mod "funstacker.rkt"
                          (handle-args ,@src-datums)))
  (datum->syntax #f module-datum))
(provide read-syntax)

(define-macro (stacker-module-begin HANDLE-EXPR ...)
  #'(#%module-begin
     'HANDLE-EXPR ...
     (display (first stack))))
(provide (rename-out [stacker-module-begin #%module-begin]))

(define stack '())

(define (pop-stack!)
  (define top (car stack))
  (set! stack (cdr stack))
  top)

(define (push-stack! a)
  (set! stack (cons a stack)))

(define (handle [arg #f])
  (cond ((equal? arg +) (push-stack! (+ (pop-stack!) (pop-stack!))))
        ((equal? arg *) (push-stack! (* (pop-stack!) (pop-stack!))))
        ((number? arg) (push-stack! arg))))

(provide handle)

(provide + *)