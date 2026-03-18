#lang br/quicklang

; expander stub: it does nothing but display the produced module datum
(define-macro (bf-module-begin PARSE-TREE)
  #'(#%module-begin
     'PARSE-TREE))
(provide (rename-out [bf-module-begin #%module-begin]))