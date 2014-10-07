(in-package #:chirp)

(defvar *db* nil)

;; (setf *db* (make-instance 'clack.middleware.clsql:<clack-middleware-clsql>
;; 			  :connection-spec '("localhost"
;; 					     "chirper"
;; 					     "chirper"
;; 					     "chirpchirp")))

(setf *db* (make-instance 'clack.middleware.clsql:<clack-middleware-clsql>
			  :connection-spec "test.sqlite3"
			  :database-type :sqlite3))
