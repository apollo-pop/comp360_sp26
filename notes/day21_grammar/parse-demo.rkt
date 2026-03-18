#lang racket
(require brag/support)
(require "parser.rkt")

(pretty-print
 (parse-to-datum "+++>[.]"))