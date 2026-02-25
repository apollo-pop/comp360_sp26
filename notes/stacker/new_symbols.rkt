#lang br

(define lines '(1 2 3 a b c foo bar + *)) ; recall the ' operator
(define new-datums (format-datums '(handle ~a) lines)) ; notice the ~ operator

(define module-datum `(module example my-lang ; notice the ` operator: allows ,@ to insert actual code
                        ,@new-datums))        ; splices the new-datums variable in


(define other-example `(module example my-lang ; notice the ` operator: allows ,@ to insert actual code
                        ,new-datums))          ; what happens without splicing?