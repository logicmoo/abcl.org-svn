;;; test-utilities.lisp
;;;
;;; Copyright (C) 2005 Peter Graves
;;; $Id: test-utilities.lisp,v 1.4 2005-10-30 09:47:33 asimon Exp $
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

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package '#:regression-test)
    (load "rt-package.lisp")))

(in-package #:regression-test)

(export '(signals-error with-registered-exception))

(defmacro signals-error (form error-name)
  `(locally (declare (optimize safety))
     (handler-case ,form
       (error (c) (typep c ,error-name))
       (:no-error (&rest ignored) (declare (ignore ignored)) nil))))

(defmacro with-registered-exception (exception condition &body body)
  `(unwind-protect
       (progn 
         (java:register-java-exception ,exception ,condition)
         ,@body)
    (java:unregister-java-exception ,exception)))