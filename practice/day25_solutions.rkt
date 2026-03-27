#lang racket
;;; COMP 360 - Day 25 Practice
;;; Lexer Practice
;;;
;;; This practice builds your comfort with brag's lexer function.
;;; You'll trace, debug, and write lexer rules — culminating in a
;;; tokenizer for a small "MiniCalc" language that handles
;;; numbers, variable names, operators, and comments.
;;;
;;;
;;; Quick Reference -- Lexer Pattern Forms:
;;;
;;;   "abc"                 matches the exact string "abc"
;;;   (char-range "0" "9")  matches any character from 0 to 9
;;;   (char-set "+-*/")     matches any single character in the string
;;;   (union re ...)        matches if ANY sub-pattern matches (like | in regex)
;;;   (concatenation re ...)  matches each sub-pattern in sequence (like grouping)
;;;   (repetition lo hi re) matches re between lo and hi times
;;;                         (use +inf.0 for unlimited; like {lo,hi} in regex)
;;;   any-char              matches any single character (like . in regex)
;;;   whitespace            matches a space, tab, or newline
;;;   (from/to start end)   matches everything between start and end strings
;;;   (eof)                 matches end-of-input
;;;
;;;
;;; Quick Reference -- Action Expressions:
;;;
;;;   lexeme                the matched string
;;;   (next-token)          skip this match, try for the next token
;;;   (token 'TYPE lexeme)  return a typed token (the parser uses TYPE)
;;;   (token 'TYPE value)   return a typed token with a transformed value
;;;                         e.g. (token 'NUMBER (string->number lexeme))
;;;   input-port            the port being read
;;;
;;;
;;; Matching rules:
;;;   - MAXIMAL MUNCH: The lexer always picks the LONGEST match
;;;   - FIRST MATCH:   Ties are broken by the FIRST rule listed

(require brag/support)


;;; ============================================================
;;; PROBLEM 1: Trace -- A Multi-Rule Lexer
;;; ============================================================
;;;
;;; Consider this lexer:
;;;
;;;   (lexer
;;;    [(from/to "(*" "*)")                               (next-token)]   ; Rule 1: skip comments
;;;    [(repetition 1 +inf.0 (char-range "0" "9")) (token 'NUM lexeme)]   ; Rule 2: tokenize positive integers
;;;    [(char-set "+-*")                            (token 'OP lexeme)]   ; Rule 3: tokenize operators
;;;    [whitespace                                        (next-token)]   ; Rule 4: skip whitespace
;;;    [any-char                                          (next-token)])  ; Rule 5: skip everything else
;;;
;;; New forms used here:
;;;   (from/to "(*" "*)")  matches everything from (* up to and including *)
;;;                        The entire block is consumed as one match.
;;;   (repetition 1 +inf.0 (char-range "0" "9"))
;;;                        matches one or more digit characters.
;;;
;;; Part 1.1:
;;;   Replace each ??? above with a simple summary of what the rule does.


;;; Part 1.2:
;;;   Suppose we run this lexer on the input:
;;;
;;;     "5 (* hi *) 12+3"
;;;
;;; Trace through the lexer. For each step, write:
;;;   1. What the lexer tries to match starting at the current position
;;;   2. Which rule matches (and how many characters it consumes)
;;;   3. What the action produces (a token? or skip via next-token?)
;;;
;;; Remember: the lexer picks the LONGEST match. Ties go to the
;;; first rule listed.
;;;
;;;   Position   Input here    Rule   Chars consumed   Action / Result
;;;   0          "5 (* ..."    1      5                (token 'NUM 5)
;;;   1          " (* h..."    4      " "              skip
;;;   2          "(* hi ..."   2      (* hi *)         skip
;;;   12         " 12+3"       4      " "              skip
;;;   13         "12+3"        1      12               (token 'NUM 12)
;;;   15         "+3"          3      +                (token 'OP +)
;;;   16         "3"           2      3                (token 'NUM 3)
;;;
;;; What is the complete sequence of tokens returned?
;;; Answer: (token 'NUM 5) (token 'NUM 12) (token 'OP +) (token 'NUM 3)
;;;
;;; Bonus: At position 2, both Rule 1 and Rule 5 could start a
;;; match at "(". Why does Rule 1 win?
;;; Answer:


;;; ============================================================
;;; PROBLEM 2: Debug -- Fix the Broken Lexer
;;; ============================================================
;;;
;;; TOKENS are lexemes with additional information attached.
;;; For example, 32 is a lexeme, but (token 'NUMBER 32) might be the
;;; token the tokenizer actually produces.
;;;
;;; This additional information can be very helpful for the parser!
;;;
;;; This lexer should tokenize simple arithmetic like "32 + 5".
;;; It should:
;;;   - Return NUMBER tokens for integers
;;;   - Return OP tokens for +, -, *, /
;;;   - Skip whitespace
;;;   - Return eof at end of input
;;;
;;; It has bugs. Find and fix all of them.
;;; Hint: Trace through the input "32 + 5" with this lexer
;;;       and see what goes wrong.

; (define (make-buggy-tokenizer port)
;   (define (next-token)
;     (define calc-lexer
;       (lexer
;        [(repetition 1 +inf.0 (char-range "0" "9"))
;         (token 'OP lexeme)]
;        [(char-set "+-*/")
;         (token 'NUMBER lexeme)]
;        [whitespace lexeme]
;        [(eof) eof]))
;     (calc-lexer port))
;   next-token)

;;; Write the corrected version below:

(define (make-fixed-tokenizer port)
  (define (next-token)
    (define calc-lexer
      (lexer
       [(repetition 1 +inf.0 (char-range "0" "9"))
        (token 'NUMBER lexeme)]
       [(char-set "+-*/")
        (token 'OP lexeme)]
       [whitespace (next-token)]
       [(eof) eof]))
    (calc-lexer port))
  next-token)

;;; Uncomment to test:
'debug-tests
(define ip (open-input-string "32 + 5"))
(define tok (make-fixed-tokenizer ip))
(tok)  ; should produce a NUMBER token for "32"
(tok)  ; should produce an OP token for "+"
(tok)  ; should produce a NUMBER token for "5"
(tok)  ; should produce eof


;;; ============================================================
;;; Problem 3: Building the MiniCalc Tokenizer
;;; ============================================================
;;;
;;; For the next problems, you'll fill in the rules of a
;;; single lexer for a small calculator language.
;;; A MiniCalc program looks like this:
;;;
;;;     x = 10
;;;     y = x + 3 * 2
;;;     // this is a comment
;;;     result = y - 1
;;;
;;; Your tokenizer needs to produce these token types:
;;;   NUMBER    -- integer literals (one or more digits)
;;;   ID        -- variable names (start with a letter, then letters or digits)
;;;   OP        -- arithmetic operators: + - * /
;;;   ASSIGN    -- the = sign
;;;
;;; Whitespace and comments should be SKIPPED (not returned).

(define (make-minicalc-tokenizer port)
  (define (next-token)
    (define minicalc-lexer
      (lexer
       ;;; 3a. Write a pattern that matches one or more digits and returns
       ;;; a NUMBER token.
       ;;;
       ;;; You need:
       ;;;   (char-range "0" "9")     : matches one digit
       ;;;   (repetition 1 +inf.0 re) : matches re one or more times
       ;;;   (token 'NUMBER lexeme)   : creates a token with type NUMBER
       ;;;
       ;;; Replace 'todo with your pattern are token:
       ;;; NOTE: you must use (token NAME lexeme) here!

       [(repetition 1 +inf.0 (char-range "0" "9")) (token 'NUMBER lexeme)]

       ;;; 3b. Write a pattern that matches variable names:
       ;;;   - Must START with a letter (a-z or A-Z)
       ;;;   - Followed by ZERO or more letters or digits
       ;;;
       ;;; Combine these building blocks:
       ;;;   (union (char-range "a" "z") (char-range "A" "Z"))
       ;;;       - matches one letter (lower or upper)
       ;;;   (union ... (char-range "0" "9"))
       ;;;       - matches whatever is in ... or a single digit
       ;;;   (concatenation re1 re2)
       ;;;       - matches re1 then re2 in sequence
       ;;;   (repetition 0 +inf.0 re)
       ;;;       - matches re zero or more times
       ;;;
       ;;; Replace 'todo with your pattern:

       [(concatenation (union (char-range "a" "z")
                              (char-range "A" "Z"))
                       (repetition 0 +inf.0 (union
                                             (char-range "a" "z")
                                             (char-range "A" "Z")
                                             (char-range "0" "9"))))
        (token 'ID lexeme)]

       ;;; 3c: Match any of + - * / and return an OP token.
       ;;;     Use char-set, like the bf lexer uses for its commands.

       [(char-set "+-*/") (token 'OP lexeme)]

       ;;; 3d: Match the = character and return an ASSIGN token.
       ;;;     A plain string pattern works fine here.

       ["=" (token 'ASSIGN lexeme)]

       ;;; 3e: Skip comments that start with // and go to end of line.
       ;;;     Use (from/to a b) for the pattern,
       ;;;     and (next-token) for the action (to skip and keep going).

       [(from/to "//" "\n") (next-token)]

       ;;; 3f: Skip whitespace.
       ;;;     The built-in abbreviation whitespace matches spaces,
       ;;;     tabs, and newlines. Use (next-token) to skip.

       [whitespace (next-token)]

       ))
    (minicalc-lexer port))
  next-token)


;;; Uncomment to test your tokenizer:
'minicalc-tests
(define test-input (open-input-string "x = 10 + y // done\n"))
(define test-tok (make-minicalc-tokenizer test-input))
(test-tok)  ; expect: ID "x"
(test-tok)  ; expect: ASSIGN "="
(test-tok)  ; expect: NUMBER "10"
(test-tok)  ; expect: OP "+"
(test-tok)  ; expect: ID "y"
(test-tok)  ; expect: eof

;;; Bonus test -- try a multi-line program:
(define test2 (open-input-string "myvar1 = 1\n// skip me\nmyvar2 = a + 2"))
(define tok2 (make-minicalc-tokenizer test2))
(tok2)  ; ID "a"
(tok2)  ; ASSIGN "="
(tok2)  ; NUMBER "1"
(tok2)  ; ID "b"
(tok2)  ; ASSIGN "="
(tok2)  ; ID "a"
(tok2)  ; OP "+"
(tok2)  ; NUMBER "2"
(tok2)  ; eof


;;; ============================================================
;;; CHALLENGE: Keywords vs. Identifiers (Longest Match)
;;; ============================================================
;;;
;;; Lexer Principles:
;;;   MAXIMAL MUNCH: match as large a lexeme as possible!
;;;   FIRST MATCH: whichever rule matches first is the rule we follow!
;;;
;;;
;;; Suppose we want to add keywords "if" and "else" to MiniCalc.
;;; They should produce KEYWORD tokens, not ID tokens.
;;;
;;; A student adds these rules AFTER the identifier rule:
;;;
;;;   [... (token 'ID lexeme)]               ; existing ID rule
;;;   ["if"   (token 'KEYWORD lexeme)]        ; new
;;;   ["else" (token 'KEYWORD lexeme)]        ; new
;;;
;;;
;;; 6a: Why doesn't this work? When the input is "if", both the
;;;     ID rule and "if" rule match a 2-character string. Which
;;;     rule wins, and why?
;;; Answer: FIRST MATCH - if looks like an ID first!
;;;
;;; 6b: What if the input is "iffy"? Which rule matches, and what
;;;     token is produced?
;;; Answer: MAXIMAL MUNCH - iffy is longer than if!
;;;
;;; 6c: Describe how you would fix this so that "if" and "else"
;;;     produce KEYWORD tokens, but "iffy" still produces an ID.
;;; Answer: Just swap the rules!

;;; ============================================================
;;; EXTENSIONS: Additional Lexemes You Might Care About
;;; ============================================================
;;;
;;; (from/to #\" #\") would recognize strings.
;;; How do you handle escape characters? "hello \"world\""

;;; (repetition 1 +inf.0 (char-range "0" "9")) handles positive integers
;;; What about negative numbers? What about floating point numbers?
;;; What about e notation? 1000 = 1e3

;;; How would you handle multi-character operators? Compare = and ==.

;;; Brackets of all types could (should?) be handled as special tokens: LPAREN