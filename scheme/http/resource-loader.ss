;; Loads resources to be send to HTTP clients.
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

(library http-resource-loader

	 (export resource-loader resource-loader-load)

	 (import (http-session) 
		 (http-request-parser)
		 (http-globals))

	 (define-struct resource-loader-s (script-cache))

	 (define (resource-loader)
	   (make-resource-loader-s (make-hash-table 'equal)))

	 (define (resource-loader-load self web-server-conf
				       http-request session)
	   (let* ((uri (normalize-uri (http-request-uri http-request)))
		  (uri-data (parse-uri uri))
		  (root-uri (list-ref uri-data 0))
		  (sess-info (list-ref uri-data 1))
		  (res null)
		  (type (find-res-type root-uri
				       (hash-table-get web-server-conf 
						       'script-ext)))
		  (res null))
	     (set! res (load-resource self root-uri type web-server-conf))
	     (cond
	      ((eq? type 'script)
	       (let ((ids (parse-session-info sess-info)))
		 (cdr (execute-resource res root-uri 
					(list-ref ids 0)
					(list-ref ids 1)
					(http-request-data http-request)
					session))))
	      (else res))))

	 (define (load-resource self uri 
				type web-server-conf)
	   (case type
	     ((file) (read-fresh-file uri web-server-conf))
	     ((script) 
	      (let ((cached 
		     (hash-table-get (resource-loader-s-script-cache self)
				     uri null)))
		(if (not (null? cached)) cached
		    (read-fresh-script self uri))))))

	 (define (read-fresh-file uri web-server-conf)	   
	   (let ((sz (file-size uri)))		 
	     (if (> sz (hash-table-get web-server-conf 'max-response-size))
		 (raise "Response will exceed maximum limit."))
	     (let ((file null) (err null) (data null))
	       (try
		(set! file (open-input-file uri))
		(set! data (read-bytes sz file))
		(catch (lambda (ex) (set! err ex))))
	       (if (not (null? file)) (close-input-port file))
	       (if (not (null? err)) (raise err))
	       data)))
	 
	 (define (read-fresh-script self uri)
	   (let ((ret (load uri)))
	     (hash-table-put! (resource-loader-s-script-cache self)
			      uri ret)
	     ret))

	 (define (normalize-uri uri)
	   (if (char=? (string-ref uri 0) #\/)
	       (set! uri (string-append "." uri)))
	   (if (string=? uri "./")
	       (set! uri "./index.html"))
	   uri)

	 (define (find-res-type uri script-ext)
	   (let ((ext (filename-extension uri)))
	     (if (bytes? ext)
		 (if (bytes=? ext script-ext)
		     'script
		     'file)
		 'file)))

	 (define (parse-uri uri)
	   (let ((idx (string-find uri *sess-id-sep*)))
	     (if (= idx -1) 
		 (list uri null)
		 (list (substring uri 0 idx) 
		       (find-session-info uri (add1 idx))))))

	 (define (find-session-info uri start-idx)
	   (let ((idx (string-find uri start-idx *sess-id-sep*)))
	     (if (= idx -1) null
		 (substring uri start-idx idx))))

	 (define (parse-session-info sess-info)
	   (if (null? sess-info) (list -1 0)	       
	       (let ((idx (string-find sess-info ".")))
		 (if (= idx -1) (list -1 0)
		     (let ((num1 (string->number (substring sess-info 0 idx)))
		       (num2 (string->number (substring sess-info (add1 idx)))))
		       (list num1 num2))))))

	 (define (execute-resource res uri 
				   sess-id proc-count 
				   http-data session)
	   (let ((content 
		  (session-execute-procedure 
		   uri res sess-id 
		   proc-count http-data session)))
	     content)))
