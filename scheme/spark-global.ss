;; Defines a few global functions used by Spark.
;; Copyright (C) 2007-2010 Vijay Mathew Pandyalakal

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License along
;; with this program; If not, see <http://www.gnu.org/licenses/>.

;; Please contact Vijay Mathew Pandyalakal if you need additional 
;; information or have any questions.
;; (Electronic mail: vijay.the.schemer@gmail.com)

;; Adapted from http://community.schemewiki.org/?amb
 
;; backtracking.

(define amb-fail
  (lambda ()
    (error "Amb tree exhausted")))
	
(define-syntax amb 
  (syntax-rules () 
    ((amb) (amb-fail))                      ; Two shortcuts. 
    ((amb expression) expression) 
    
    ((amb expression ...) 
     (let ((fail-save amb-fail)) 
       ((call-with-current-continuation ; Capture a continuation to 
	 (lambda (k-success)           ;   which we return possibles. 
	   (call-with-current-continuation 
	    (lambda (k-failure)       ; K-FAILURE will try the next 
	      (set! amb-fail k-failure)   ;   possible expression. 
	      (k-success              ; Note that the expression is 
	       (lambda ()             ;   evaluated in tail position 
		 expression))))       ;   with respect to AMB. 
	   ... 
	   (set! amb-fail fail-save)      ; Finally, if this is reached, 
	   fail-save)))))))            ;   we restore the saved FAIL. 

(define (amb-require condition) 
  (if (not condition) 
      (amb-fail)))

;; :~
