#lang racket
(require "sicp-lang.rkt")
(require "util.rkt" "print-tree.rkt")
(provide (all-defined-out))

;; vectors
(define (make-vect x y)
  (cons x y))
(define (vect-xcor v)
  (car v))
(define (vect-ycor v)
  (cdr v))

(define (vect-scale s v)
  (make-vect (* s (vect-xcor v))
             (* s (vect-ycor v))))
(define (vect-add v w)
  (make-vect (+ (vect-xcor v)
                (vect-xcor w))
             (+ (vect-ycor v)
                (vect-ycor w))))
(define (vect-sub v w)
  (vect-add v (vect-scale w -1)))


;; sets
(define (make-set x type)
  ((get 'make type) x))

(define (element-of-set? x set)
  (apply-generic 'element? x set))
(define (adjoin-set x set)
  (apply-generic 'adjoin x set))
(define (intersection-set s1 s2)
  (apply-generic 'intersection s1 s2))
(define (union-set s1 s2)
  (apply-generic 'union s1 s2))
(define (print-set set)
  (apply-generic 'print set))

(define (make-set-package-installation
         type make-set elem? adjoin inter union print)
  (put 'make type make-set)
  (put 'element? (list #f type) (tag-result elem? #f))
  (put 'adjoin (list #f type) (tag-result adjoin type))
  (put 'intersection (list type type) (tag-result inter type))
  (put 'union (list type type) (tag-result union type))
  (put 'print (list type) print)
  (format "~s-package installed" type))

(define (install-set-package)
  ;; internal definitaions
  ;; these definitions need not to consider the type-tag of the return-value,
  ;; for I convert them into procedures returning tagged-data in the definition
  ;; of MAKE-SET-PACKAGE-INSTALLATION

  (define (make-set lst)
    (attach-tag 'set (select-distinct lst)))

  (define (element-of-set? x set)
    (cond ((null? set) false)
          ((equal? x (car set)) true)
          (else (element-of-set? x (cdr set)))))

  (define (adjoin-set x set)
    (if (element-of-set? x set)
        set
        (cons x set)))

  (define (intersection-set s1 s2)
    (cond ((or (null? s1) (null? s2)) nil)
          ((element-of-set? (car s1) s2)
           (cons (car s1)
                 (intersection-set (cdr s1) s2)))
          (else (intersection-set (cdr s1) s2))))

  (define (union-set s1 s2)
    (cond ((null? s1) s2)
          ((null? s2) s1)
          ((element-of-set? (car s1) s2)
           (union-set (cdr s1) s2))
          (else (cons (car s1)
                      (union-set (cdr s1) s2)))))

  ;; API
  (make-set-package-installation
   'set
   make-set
   element-of-set?
   adjoin-set
   intersection-set
   union-set
   display))

(define (install-reduplicate-set-package)
  ;; internal definitions
  (define (make-redupset lst)
    (attach-tag 'reduplicate-set lst))

  (define (element-of-redupset? x set)
    (cond ((null? set) false)
          ((equal? x (car set)) true)
          (else (element-of-redupset? x (cdr set)))))

  (define (adjoin-redupset x set)
    (cons x set))

  (define (intersection-redupset s1 s2)
    (define (select x set)
      (define (iter done left)
        (cond ((null? left) (cons nil done))
              ((eq? x (car left)) (cons (list x) (append done (cdr left))))
              (else (iter (cons (car left) done) (cdr left)))))
      (iter nil set))
    (if (null? s1)
        nil
        (let ((select-result (select (car s1) s2)))
          (let ((selected (car select-result))
                (left (cdr select-result)))
            (append selected
                    (intersection-redupset (cdr s1) left))))))

  (define (union-redupset s1 s2)
    (append s1 s2))

  ;; API
  (make-set-package-installation
   'duplicate-set
   make-redupset
   element-of-redupset?
   adjoin-redupset
   intersection-redupset
   union-redupset
   display))

(define (install-ordered-set-package)
  ;;internal definitions
  (define (make-ordset lst)
    (attach-tag 'ordered-set
                (sort (select-distinct lst))))

  (define (element-of-ordset? x set)
    (cond ((null? set) false)
          ((smaller? x (car set)) false)
          ((equal? x (car set)) true)
          (else (element-of-ordset? x (cdr set)))))

  (define (adjoin-ordset x set)
    (cond ((null? set) (list x))
          ((bigger? (car set) x) (cons x set))
          ((equal? x (car set)) set)
          (else (cons (car set)
                      (adjoin-ordset x (cdr set))))))

  (define (intersection-ordset s1 s2)
    (if (or (null? s1) (null? s2))
        nil
        (let ((x1 (car s1)) (x2 (car s2)))
          (cond ((bigger? x1 x2)
                 (intersection-ordset s1 (cdr s2)))
                ((equal? x1 x2)
                 (cons x1 (intersection-ordset (cdr s1) (cdr s2))))
                (else
                 (intersection-ordset (cdr s1) s2))))))

  (define (union-ordset s1 s2)
    (cond ((null? s1) s2)
          ((null? s2) s1)
          (else
           (let ((x1 (car s1)) (x2 (car s2)))
             (cond ((bigger? x1 x2)
                    (cons x2 (union-ordset s1 (cdr s2))))
                   ((eq? x1 x2)
                    (cons x1 (union-ordset (cdr s1) (cdr s2))))
                   (else
                    (cons x1 (union-ordset (cdr s1) s2))))))))

  ;; API
  (make-set-package-installation
   'ordered-set
   make-ordset
   element-of-ordset?
   adjoin-ordset
   intersection-ordset
   union-ordset
   display))

(define (install-binary-tree-package)
  ;;internal definitions
  (define (make-bt lst)
    (attach-tag 'binary-tree
                (set->btree
                 (select-distinct lst))))

  ;; API
  (make-set-package-installation
   'binary-tree
   make-bt
   entry-of-btree?
   adjoin-btree
   intersection-btree
   merge-btree
   print-btree))

;; test
(define s1 '[1 4 6 2 4 3 8 9])
(define s2 '[7 4 5 8 4 2 0 6])
; don't test two packages at once!
(define (test-set)
  (install-set-package)
  (set! s1 (make-set s1 'set))
  (set! s2 (make-set s2 'set)))
(define (test-redupset)
  (install-reduplicate-set-package)
  (set! s1 (make-set s1 'reduplicate-set))
  (set! s2 (make-set s2 'reduplicate-set)))
(define (test-ordset)
  (install-ordered-set-package)
  (set! s1 (make-set s1 'ordered-set))
  (set! s2 (make-set s2 'ordered-set)))
(define (test-bt)
  (install-binary-tree-package)
  (set! s1 (make-set s1 'binary-tree))
  (set! s2 (make-set s2 'binary-tree)))

;; binary trees
(define (make-btree left entry right)
  (list left entry right))
(define (make-bleaf x)
  (make-btree nil x nil))
(define (btree-left btree)
  (car btree))
(define (btree-entry btree)
  (cadr btree))
(define (btree-right btree)
  (caddr btree))

(define (bleaf? btree)
  (and (null? (btree-left btree))
       (null? (btree-right btree))))
(define (btree? item)
  (define btree/null?
    (lambda (x)
      (or (btree? x)
          (empty? x))))
  (and (list? item)
       (= (length item) 3)
       (btree/null? (btree-left item))
       (btree/null? (btree-right item))))

(define (ordered-set->btree set) ;convert an ordered set to a balanced btree
  (define (partial-tree elts n)
    (if (= n 0)
        (cons '() elts)
        (let ((left-size
               (quotient (- n 1) 2)))
          (let ((left-result
                 (partial-tree
                  elts left-size)))
            (let ((left-tree
                   (car left-result))
                  (non-left-elts
                   (cdr left-result))
                  (right-size
                   (- n (+ left-size 1))))
              (let ((this-entry
                     (car non-left-elts))
                    (right-result
                     (partial-tree
                      (cdr non-left-elts)
                      right-size)))
                (let ((right-tree
                       (car right-result))
                      (remaining-elts
                       (cdr right-result)))
                  (cons (make-btree left-tree
                                    this-entry
                                    right-tree)
                        remaining-elts))))))))
  (car (partial-tree
        set (length set))))

(define (set->btree set)
  (ordered-set->btree
   (sort set)))

(define (btree->set t) ;actually an ordered set
  (if (null? t)
      nil
      (append (btree->set
               (btree-left t))
              (list (btree-entry t))
              (btree->set
               (btree-right t)))))

(define (balance t) ;I am afraid its efficiency is very low
  (ordered-set->btree (btree->set t)))

(define (entry-of-btree? x t)
  (if (null? t)
      false
      (let ([entry (btree-entry t)]
            [left (btree-left t)]
            [right (btree-right t)])
        (cond [(smaller? x entry)
               (entry-of-btree? x left)]
              [(equal? x entry)
               true]
              [else
               (entry-of-btree? right)]))))

;; Be aware that these three procs below destroys the balance of the tree
(define (adjoin-btree x t)
  (cond ((empty? t) (make-bleaf x))
        ((eq? x (btree-entry t)) t)
        ((bigger? x (btree-entry t))
         (make-btree (btree-left t)
                     (btree-entry t)
                     (adjoin-btree x (btree-right t))))
        (else
         (make-btree (adjoin-btree x (btree-left t))
                     (btree-entry t)
                     (btree-right t)))))

(define (intersection-btree t1 t2)
  (if (or (null? t1) (null? t2))
      nil
      (let ((x1 (btree-entry t1))
            (x2 (btree-entry t2))
            (l1 (btree-left t1))
            (l2 (btree-left t2))
            (r1 (btree-right t1))
            (r2 (btree-right t2)))
        (cond ((bigger? x1 x2)
               (merge-btree
                (intersection-btree
                 (adjoin-btree x2 l2)
                 l1)
                (intersection-btree
                 r2
                 t1)))
              ((equal? x1 x2)
               (make-btree
                (intersection-btree
                 l1 l2)
                x1
                (intersection-btree
                 r1 r2)))
              (else
               (intersection-btree t2 t1))))))

(define (merge-btree t1 t2)
  (cond ((null? t2) t1)
        ((null? t1) t2)
        (else
         (let ((x1 (btree-entry t1))
               (x2 (btree-entry t2))
               (l1 (btree-left t1))
               (l2 (btree-left t2))
               (r1 (btree-right t1))
               (r2 (btree-right t2)))
           (cond ((bigger? x1 x2)
                  (merge-btree
                   r2
                   (make-btree
                    (merge-btree l1 (adjoin-btree x2 l2))
                    x1
                    r1)))
                 ((equal? x1 x2)
                  (make-btree
                   (merge-btree l1 l2)
                   x1
                   (merge-btree r1 r2)))
                 (else
                  (merge-btree t2 t1)))))))

(define (btree-map proc btree)
  (if (null? btree)
      null
      (make-btree
       (btree-map proc (btree-left btree))
       (proc (btree-entry btree))
       (btree-map proc (btree-right btree)))))


;; dicts (using btree)
(define (make-entry key content)
  (cons key content))
(define (entry-key entry)
  (car entry))
(define (entry-content entry)
  (cdr entry))

(define (list->dict entry-list)
  (ordered-set->btree
   (sorting-tool
    entry-list
    (lambda (x y)
      (if (bigger? (entry-key x)
                   (entry-key y))
          1 0))
    1)))

(define (add-entry entry dict)
  (if (null? dict)
      (make-bleaf entry)
      (let ((new-key (entry-key entry))
            (this-key (entry-key (btree-entry dict)))
            (this-entry (btree-entry dict))
            (smaller (btree-left dict))
            (bigger (btree-right dict)))
        (cond ((equal? new-key this-key)
               (error "this key already exists: " new-key))
              ((bigger? new-key this-key)
               (make-btree smaller this-entry
                           (add-entry entry bigger)))
              (else
               (make-btree (add-entry entry smaller)
                           this-entry bigger))))))

(define (del-entry key dict)
  (if (null? dict)
      (error "no record has this key: " key)
      (let ((this-key (entry-key (btree-entry dict)))
            (this-entry (btree-entry dict))
            (smaller (btree-left dict))
            (bigger (btree-right dict)))
        (cond ((equal? key this-key)
               (merge-btree smaller bigger))
              ((bigger? key this-key)
               (make-btree smaller this-entry
                           (del-entry key bigger)))
              (else
               (make-btree (del-entry key smaller)
                           this-entry bigger))))))

(define (lookup given-key dict)
  (if (null? dict)
      #f
      (let ((this-key (entry-key (btree-entry dict))))
        (cond ((eq? given-key this-key)
               (btree-entry dict))
              ((bigger? given-key this-key)
               (lookup given-key (btree-right dict)))
              (else
               (lookup given-key (btree-left dict)))))))


;; data-directed programming
(define (attach-tag type-tag contents)
  (cond ((or (number? contents)
             (symbol? contents)
             (string? contents))
         contents)
        (else
         (cons type-tag contents))))

(define (type-tag datum)
  (cond ((pair? datum)
         (car datum))
        ((number? datum)
         'scheme-number)
        ((symbol? datum)
         'scheme-symbol)
        ((string? datum)
         'scheme-string)
        (else
         (error "Bad tagged datum -- TYPE-TAG" datum))))

(define (contents datum)
  (cond  ((pair? datum)
          (cdr datum))
         ((or (number? datum)
              (symbol? datum)
              (string? datum))
          datum)
         (else
          (error "Bad tagged datum -- CONTENTS" datum))))

(define (tag-result op tag)
  (define (operation . arg)
    (attach-tag tag
                (apply op arg)))
  operation)

; 2D tables
(define (make-table)
  (let ((local-table (list '*table*)))
    (define (lookup key-1 key-2)
      (let ((subtable (assoc key-1 (cdr local-table))))
        (if subtable
            (let ((record (assoc key-2 (cdr subtable))))
              (if record
                  (cdr record)
                  false))
            false)))
    (define (insert! key-1 key-2 value)
      (let ((subtable (assoc key-1 (cdr local-table))))
        (if subtable
            (let ((record (assoc key-2 (cdr subtable))))
              (if record
                  (set-cdr! record value)
                  (set-cdr! subtable
                            (cons (cons key-2 value)
                                  (cdr subtable)))))
            (set-cdr! local-table
                      (cons (list key-1
                                  (cons key-2 value))
                            (cdr local-table)))))
      'ok)
    (define (dispatch m)
      (cond ((eq? m 'lookup-proc) lookup)
            ((eq? m 'insert-proc!) insert!)
            (else (error "Unknown operation -- TABLE" m))))
    dispatch))

(define operation-table (make-table))
(define get (operation-table 'lookup-proc))
(define put (operation-table 'insert-proc!))

; used in the definition of a generic procedure
(define (apply-generic op . args)
  (let ((type-tags (map type-tag args)))
    (let ((proc (get op type-tags)))
      (if proc
          (apply proc (map contents args))
          (error
            "No method for these types:
             APPLY-GENERIC"
            (list op type-tags))))))
