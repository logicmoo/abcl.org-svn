;;; boot.lisp
;;;
;;; Copyright (C) 2003 Peter Graves
;;; $Id: boot.lisp,v 1.75 2003-07-13 14:40:00 piso Exp $
;;;
;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License
;;; as published by the Free Software Foundation; either version 2
;;; of the License, or (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

(sys::%nodebug)

(sys::%in-package "COMMON-LISP")


(defmacro in-package (name)
  (list 'sys::%in-package (string name)))


(defmacro when (pred &rest body)
  (list 'if pred (if (> (length body) 1)
                     (append '(progn) body)
                     (car body))))

(defmacro unless (pred &rest body)
  (list 'if (list 'not pred) (if (> (length body) 1)
                                 (append '(progn) body)
                                 (car body))))

(defmacro defun (name lambda-list &rest body)
  (list 'sys::%defun (list 'QUOTE name) (list 'QUOTE lambda-list) (list 'QUOTE body)))

(defvar *features*
  '(:armedbear))


(defun make-package (package-name &key nicknames use)
  (sys::%make-package package-name nicknames use))


;;; READ-CONDITIONAL (from OpenMCL)

(defconstant *keyword-package*
  (find-package "KEYWORD"))

(defun read-conditional (stream subchar int)
  (cond (*read-suppress* (read stream t nil t) (values))
        ((eql subchar (read-feature stream)) (read stream t nil t))
        (t (let* ((*read-suppress* t))
             (read stream t nil t)
             (values)))))

(defun read-feature (stream)
  (let* ((f (let* ((*package* *keyword-package*))
              (read stream t nil t))))
    (labels ((eval-feature (form)
                           (cond ((atom form)
                                  (member form *features*))
                                 ((eq (car form) :not)
                                  (not (eval-feature (cadr form))))
                                 ((eq (car form) :and)
                                  (dolist (subform (cdr form) t)
                                    (unless (eval-feature subform) (return))))
                                 ((eq (car form) :or)
                                  (dolist (subform (cdr form) nil)
                                    (when (eval-feature subform) (return t))))
                                 (t (error "READ-FEATURE")))))
            (if (eval-feature f) #\+ #\-))))

(set-dispatch-macro-character #\# #\+ #'read-conditional)
(set-dispatch-macro-character #\# #\- #'read-conditional)


(dolist (name '("autoloads.lisp"
                "early-defuns.lisp"
                "backquote.lisp"
                "setf.lisp"
                "macros.lisp"
                "destructuring-bind.lisp"
;;                 "defmacro.lisp"
                "arrays.lisp"
                "compiler.lisp"
                "list.lisp"
                "sequences.lisp"
                "error.lisp"
                "defpackage.lisp"
                "defstruct.lisp"
                "loop.lisp"))
  (%load name))


;;; Miscellany.

(defun plusp (n)
  (> n 0))

(defun minusp (n)
  (< n 0))

(defun integerp (n)
  (typep n 'integer))

(defun read-from-string (string &optional eof-error-p eof-value
				&key (start 0) end preserve-whitespace)
  (%read-from-string string eof-error-p eof-value start end preserve-whitespace))

(defconstant call-arguments-limit 50)

(defconstant lambda-parameters-limit 50)

(defconstant multiple-values-limit 20)

(defconstant char-code-limit 96)

(defconstant internal-time-units-per-second 1000)


;; FIXME
(defun proclaim (decl)
  nil)


;; AND, OR (from CMUCL)

(defmacro and (&rest forms)
  (cond ((endp forms) t)
	((endp (rest forms)) (first forms))
	(t
	 `(if ,(first forms)
	      (and ,@(rest forms))
	      nil))))

(defmacro or (&rest forms)
  (cond ((endp forms) nil)
	((endp (rest forms)) (first forms))
	(t
	 (let ((n-result (gensym)))
	   `(let ((,n-result ,(first forms)))
	      (if ,n-result
		  ,n-result
		  (or ,@(rest forms))))))))


;; CASE (from CLISP)

(defun case-expand (form-name test keyform clauses)
  (let ((var (gensym)))
    `(let ((,var ,keyform))
       (cond
        ,@(maplist
           #'(lambda (remaining-clauses)
              (let ((clause (first remaining-clauses))
                    (remaining-clauses (rest remaining-clauses)))
                (unless (consp clause)
                  (error 'program-error "~S: missing key list" form-name))
                (let ((keys (first clause)))
                  `(,(cond ((or (eq keys 'T) (eq keys 'OTHERWISE))
                            (if remaining-clauses
                                (error 'program-error
                                       "~S: the ~S clause must be the last one"
                                       form-name keys)
                                't))
                           ((listp keys)
                            `(or ,@(mapcar #'(lambda (key)
                                              `(,test ,var ',key))
                                           keys)))
                           (t `(,test ,var ',keys)))
                     ,@(rest clause)))))
           clauses)))))

(defmacro case (keyform &body clauses)
  (case-expand 'case 'eql keyform clauses))


;; TYPECASE (from CLISP)

(defmacro typecase (keyform &rest typeclauselist)
  (let* ((tempvar (gensym))
         (condclauselist nil))
    (do ((typeclauselistr typeclauselist (cdr typeclauselistr)))
        ((atom typeclauselistr))
      (cond ((atom (car typeclauselistr))
             (error 'program-error
                    "invalid clause in ~S: ~S"
                    'typecase (car typeclauselistr)))
            ((let ((type (caar typeclauselistr)))
               (or (eq type T) (eq type 'OTHERWISE)))
             (push `(T ,@(or (cdar typeclauselistr) '(NIL))) condclauselist)
             (return))
            (t (push `((TYPEP ,tempvar (QUOTE ,(caar typeclauselistr)))
                       ,@(or (cdar typeclauselistr) '(NIL)))
                     condclauselist))))
    `(LET ((,tempvar ,keyform)) (COND ,@(nreverse condclauselist)))))


;;; PROG, PROG* (from GCL)

(defmacro prog (vl &rest body &aux (decl nil))
  (do ()
      ((or (endp body)
           (not (consp (car body)))
           (not (eq (caar body) 'declare)))
       `(block nil (let ,vl ,@decl (tagbody ,@body))))
      (push (car body) decl)
      (pop body)))

(defmacro prog* (vl &rest body &aux (decl nil))
  (do ()
      ((or (endp body)
           (not (consp (car body)))
           (not (eq (caar body) 'declare)))
       `(block nil (let* ,vl ,@decl (tagbody ,@body))))
      (push (car body) decl)
      (pop body)))


;; FIXME
(defun compute-restarts (&optional condition)
  nil)

;; FIXME
(defun restart-name (restart)
  nil)


(sys::%debug)
