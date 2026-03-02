#lang br
;;; pretend we have written a function: (read program-contents)
;;;
;;; the following code simulates the potential function
;;; of a reader:
;;; take the commands in the new language and READ them
;;; as racket expressions 
;;;
;;; what are the problems here?
(10)
(20)
(+)
(2)
(*)
;;; goal: (* (+ 10 20) 2)