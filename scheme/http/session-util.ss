;; Some utilities that makes working with sessions easier.
;; Copyright (C) 2007, 2008, 2009 Vijay Mathew Pandyalakal
 
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

(library http-session-util

	 (export http-value http-value! 
		 http-call http-keep-alive!
		 http-keep-alive?
		 make-default-session-state)

	 (define *keep-alive* "__keep_alive__")
	 (define *session-id* "__sesssion_id__")

	 (define http-value
	   (case-lambda
	    ((state name) (http-value state name null))
	    ((state name def-value) (hash-table-get state name def-value))))

	 (define (http-value! state name value)
	   (hash-table-put! state name value))	 

	 (define (http-call proc)
	   (if (not (procedure? proc))
	       (raise "http-call failed. Not a procedure.")
	       (raise proc)))

	 (define http-keep-alive!
	   (case-lambda
	    ((state) (http-keep-alive! state #t))
	    ((state flag)
	     (hash-table-put! state *keep-alive* flag))))

	 (define (http-keep-alive? state)
	   (hash-table-get state *keep-alive* #f))
	 
	 (define (make-default-session-state id)
	   (let ((state (make-hash-table 'equal)))
	     (hash-table-put! state *session-id* id)
	     (hash-table-put! state *keep-alive* #f)
	     state)))