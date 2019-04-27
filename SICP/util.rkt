#lang racket
(require "sicp-lang.rkt")
(provide (all-defined-out))


;;; some useful patterns

(define (fold comb init)
  (define (fast-comb item cnt)
    (cond ((zero? cnt) init)
          ((even? cnt) (fast-comb (comb item item) (/ cnt 2)))
          (else ((fold comb (comb item init)) item (dec cnt)))))
  fast-comb)

(define (compose f g)
  (lambda (x)
    (f (g x))))

(define repeated (fold compose identity))


;;; printing procedures

(define (data-table f min max dx)
  (define (iter x cnt)
    (define (data)
      (begin (display x)
             (display ": ")
             (display (f x))))
    (define (space)
      (if (zero? (remainder cnt 15))
          (newline)
          (display "   ")))
    (cond ((> x max) (newline))
          (else (data)
                (space)
                (iter (+ x dx) (inc cnt)))))   
  (iter min 1))

(define (print-list l)
  (define (print-content l)
    (print-list (car l))
    (cond ((not (null? (cdr l)))
           (display " ")
           (print-content (cdr l)))))
  (cond ((null? l) (display "()"))
        ((not (pair? l)) (display l))
        (else (display "(")
              (print-content l)
              (display ")"))))

(define (space n)
  (cond ((> n 0)
         (display " ")
         (space (dec n)))))


;;; procedures for lists, sequences and trees

(define (atom? x)
  (not (or (pair? x) (null? x))))

(define (filter predicate seq)
  (if (null? seq)
      nil
      (let ((rest (filter predicate 
                          (cdr seq))))
        (if (predicate (car seq))
            (cons (car seq) rest)
            rest))))

(define (accumulate op initial seq)
  (if (null? seq)
      initial
      (op (car seq)
          (accumulate op 
                      initial 
                      (cdr seq)))))

(define (deep-map proc lst)
  (map (lambda (sublst)
         (if (pair? sublst)
             (deep-map proc sublst)
             (proc sublst)))
       lst))

(define (flat-map proc seq)
  (accumulate append
              nil
              (map proc seq)))

(define (remove-all x lst)
    (filter (lambda (el) (not (eq? el x))) lst))

(define (flatten lst)
  (cond ((null? lst) nil)
        ((atom? lst) (list lst))
        (else (append (flatten (car lst))
                      (flatten (cdr lst))))))

(define (select-distinct lst)
  (define (iter set lst)
    (cond ((null? lst) set)
          ((member (car lst) set)
           (iter set (cdr lst)))
          (else (iter (cons (car lst) set)
                      (cdr lst)))))
  (iter nil lst))


;;; miscellaneous

(define (=number? exp num)
  (and (number? exp) (= exp num)))

;take in a single argument procedure and return the same procedure with the ability to display the time cost by calculation
(define (apply-time f show-result?)
  (define (start f x start-time)
    (if show-result?
        (begin (display (f x))
               (newline))
        (f x))
    (let ((elapsed-time (- (runtime) start-time)))
      (display "elapsed time: ")
      (display elapsed-time)))
  (lambda (x)
    (start f x (runtime))))
(define (timed f)
  (apply-time f #t))
(define (timer f)
  (apply-time f #f))

;convert a string with the proper format into the corresponding "cxxr" procedure like cadr, cddar, caaddr, etc.
(define (cxxr str)
  (define (recur str lst)
    (let ((first (string-ref str 0))
          (rest (substring str 1)))
      (cond ((eq? first #\a)
             (car (recur rest lst)))
            ((eq? first #\d)
             (cdr (recur rest lst)))
            ((eq? first #\r)
             lst)
            (else (error "Unrecognizable string: CXXR" str)))))
  (lambda (lst)
    (if (eq? (string-ref str 0) #\c)
        (recur (substring str 1) lst)
        (error "Unrecognizable string: CXXR" str))))

;find the first appearance of A in L and return the string that represents the name of the cxxr procedure to retrieve A from L
(define (give-cxxr-str a l)
  (define (searcher l)
    (cond ((null? l) #f)
          ((not (pair? l))
           (if (eq? a l)
               ""
               #f))
          (else (let ((a (searcher (car l)))
                      (d (searcher (cdr l))))
                  (cond (a (string-append a "a"))
                        (d (string-append d "d"))
                        (else #f))))))
  (let ((mid (searcher l)))
    (if mid
        (string-append "c" (searcher l) "r")
        "element not found")))