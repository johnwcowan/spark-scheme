(import (net) (reactor)
	(fcgi))

(define (on-client-connect acceptor client-conn)
  (printf "FCGI client connected.~n") (flush-output)
  (let ((client-socket (car client-conn)))
    (acceptor-add-watch acceptor client-socket 'for-read)))
    
(define (on-client-read acceptor client-socket)
  (printf "Incoming FCGI request ... ~n")
  (flush-output)
  (try
   (let ((req (fcgi-recv client-socket)))    
     (printf "~a~n" (fcgi-request->string req))
     (let* ((num1 (string->number (fcgi-request-parameter req "num1")))
	    (num2 (string->number (fcgi-request-parameter req "num2")))
	    (res (+ num1 num2))
	    (out (open-output-string)))
       (fprintf out "<html><body><b>~a + ~a = ~a</b></body></html>"
		num1 num2 res)
       (fcgi-send req (get-output-string out))))
   (catch (lambda (ex)
	    (printf "Error: ~a~n" ex)))
   (finally 
    (printf "Closing client resources.~n") (flush-output)
    (acceptor-remove-watch acceptor client-socket 'for-read)
    (socket-close client-socket))))

(define (on-server-timeout acceptor)
  (printf "Waiting for client, timedout.~n")
  (flush-output))

(define fcgi-server (socket-acceptor))
(acceptor-port! fcgi-server 8888)
(acceptor-on-client-connect! fcgi-server on-client-connect)
(acceptor-on-client-read! fcgi-server on-client-read)
(acceptor-on-server-timeout! fcgi-server on-server-timeout)
(acceptor-open fcgi-server #t (list 3 0))
(define count 0)
(let loop ()
  (try
   (acceptor-watch fcgi-server)
   (if #t;;(< count 10)
       (begin
	 (set! count (+ count 1))))
   (catch (lambda (ex) (printf "~a~n" ex))))
  (loop))

(printf "FCGI server exiting ...~n") (flush-output)
(acceptor-close fcgi-server)
