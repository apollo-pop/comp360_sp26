#lang racket
(require 2htdp/image)
(require 2htdp/universe)

;;; 1: Particle Basics

; particle accessors
(define (particle-x lst)
  (car lst)
  )
(define (particle-y lst)
  (car (cdr lst))
  )
(define (particle-vx lst)
  (car (cdr (cdr lst)))
  )
(define (particle-vy lst)
  (car (cdr (cdr (cdr lst))))
  )
(define (particle-life lst)
  (car (cdr (cdr (cdr (cdr lst)))))
  )


; tests
(define test-particle (list 100 200 3 -5 60))
(particle-x test-particle)     ; => 100
(particle-y test-particle)     ; => 200
(particle-vx test-particle)    ; => 3
(particle-vy test-particle)    ; => -5
(particle-life test-particle)  ; => 60

; make-particle
(define (make-particle x y vx vy life)
  (list x y vx vy life)
  )
; tests
(make-particle 50 100 2 -3 30)  ; => (list 50 100 2 -3 30)

; update-particle
(define (update-particle lst)
  (list (+ (particle-x lst) (particle-vx lst)) (+ (particle-y lst) (particle-vy lst)) (particle-vx lst)
	(particle-vy lst) (- (particle-life lst) 1))
  )
; tests
(update-particle (list 100 200 3 -5 60))  ; => (list 103 195 3 -5 59)
(update-particle (list 0 0 1 1 10))       ; => (list 1 1 1 1 9)

; particle-alive?
(define (particle-alive? lst)
  (cond
    [(> (particle-life lst) 0) "#t"]
    [else "#f"]))
     
; tests
(particle-alive? (list 0 0 0 0 5))   ; => #t
(particle-alive? (list 0 0 0 0 0))   ; => #f
(particle-alive? (list 0 0 0 0 -1))  ; => #f

; draw-particle
(define (draw-particle lst bg)
  (define (scaler life)
    (cond
      [(> life 30) 255]
      [(< life 0) 0]
      [else (* (/ 255 30) life)]))
  (place-image (circle 5 "solid" (make-color 0 0 0 (scaler (particle-life lst)))) 
		       (particle-x lst) (particle-y lst) bg))

; tests
(define bg (rectangle 400 400 "solid" "gray"))
(define (draw-world w)
  (draw-particle (list 200 200 0 0 60) bg)  ; draws a bright particle
  (draw-particle (list 200 200 0 0 10) bg))  ; draws a faded particle

(big-bang 0
    [to-draw draw-world])



; 2: Closures

; make-spawner
(define (make-spawner x y v-min v-max life)
  (lambda ()
    (make-particle x y (+ v-min (random (- v-max v-min))) (+ v-min (random (- v-max v-min))) life)))
  
; tests
(define fountain (make-spawner 200 300 1 5 60))
(fountain)  ; => a particle at (200, 300) with random velocity, life=60
(fountain)  ; => another particle (different random velocity)

; make-gravity

; tests


; make-wind

; tests


; make-friction

; tests


; make-attractor

; tests


; compose-forces

; tests


; 3: Tail Recursion

; update-all-particles

; tests


; apply-force-to-all

; tests


; filter-alive

; tests


; draw-all-particles

; tests


; 4: Simulation!

; simulation-step


; simulation-step-with-spawning


; run-simulation


; 5: Your Scene!



;;; My Scene: I got extensive help from Claude AI.
;;; even so, the vast majority of this code is my own.
;;; I used Claude for guidance, hints, and debugging.

;(require racket/random)
;(define WIDTH 800)
;(define HEIGHT 800)
;
;(define (make-random-spawner x y v-min v-max life images)
;  (lambda () (make-particle x y (random v-min v-max) (random v-min v-max) life (car (random-sample images 1)))))
;
;(define shape-makers
;  (list
;   (lambda (a) (circle 5 "solid" (color 0 255 0 a)))
;   (lambda (a) (star 10 "solid" (color 255 255 0 a)))
;   (lambda (a) (rectangle 10 10 "solid" (color 255 0 0 a)))))
;
;(define my-spawner (curryr make-random-spawner -5 5 80 shape-makers))
;
;  
;(define my-forces (compose-forces (make-gravity 0.3) (make-friction 0.90)))
;
;(define (tick-handler state)
;  (list (simulation-step-with-spawning (first state)
;                                       (apply compose-forces (fourth state))
;                                       (my-spawner (second state) (third state)) ; move the spawner according to the state
;                                       5)
;        (second state)
;        (third state)
;        (fourth state)))
;
;
;
;(define (draw-handler state)
;  (draw-all-particles (first state) (rectangle WIDTH HEIGHT "solid" "black")))
;
;(define (normalize p)
;  (let ((magnitude (sqrt (+ (expt (car p) 2) (expt (cdr p) 2)))))
;    (if (zero? magnitude)
;        (cons 0 0)
;        (cons (/ (car p) magnitude) (/ (cdr p) magnitude)))))
;
;(define (make-repeller x y size)
;  (lambda (p)
;    ; calculate the direction from x, y to the particle
;    ; normalize
;    ; push the particle by the normalized * size
;    (let* ((direction (cons (- (particle-x p) x) (- (particle-y p) y)))
;           (normalized (normalize direction)))
;      (make-particle (particle-x p)
;                     (particle-y p)
;                     (+ (particle-vx p) (* (car normalized) size))
;                     (+ (particle-vy p) (* (cdr normalized) size))
;                     (particle-life p)
;                     (particle-image p)))))
;           
;(define (mouse-handler state x y event)
;  (let ((repeller (make-repeller x y 1)))
;    (cond
;      ((equal? event "button-down")
;       (list (first state) x y (cons repeller (fourth state))))
;      ((equal? event "button-up")
;       (list (first state) x y (cdr (fourth state))))
;      (else
;       (list (first state) x y (fourth state))))))
;  
;
;(big-bang (list '() 0 0 (list my-forces))  ; initial state: no particles
;  [on-tick tick-handler]
;  [to-draw draw-handler]
;  [on-mouse mouse-handler])
