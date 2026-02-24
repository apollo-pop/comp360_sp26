#lang br/quicklang
;;; the reader:
;;; - must EXPORT a read-syntax function
;;;   (read-syntax path port) -> module as a syntax object
;;;   this function replaces the original source with this module
(define (read-syntax
         path
         port) ; generic interface for input/output, can be read/written
  (define src-lines (port->lines port)) ; converts all lines of input to list of strings
  (datum->syntax #f '(module lucy br ; this is code that describes the module
                       42)))
; code represented as a 'symbol, ex '(+ 1 1) is called an s-expression
; so the above reader produces the module:
; (module lucy br 42), where lucy is the module name and br is the expander
; (datum->syntax context code) converts a symbol into a syntax object

(provide read-syntax) ; exports the syntax reader

;;; the expander:
;;; - is invoked by the module the reader produces