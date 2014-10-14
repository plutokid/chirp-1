;;;; package.lisp

(defpackage #:chirp
  (:use #:cl
	#:who
	#:clack
	#:split-sequence
	#:alexandria)
  (:import-from #:clsql
		#:select
		#:file-enable-sql-reader-syntax
		#:def-view-class
		#:update-records-from-instance))

(in-package #:chirp)

(defvar *app* (make-instance 'ningle:<app>))

(setf (ningle:route *app* "/")
      "Welcome.")

(setf (ningle:route *app* "/user/:user" :method :get)
      'show-user)

(setf (ningle:route *app* "/tags/:tag" :method :get) 'show-tag)

(defvar *acceptor*)

(defun start ()
  (setf *acceptor*
	(clackup
	 (clack.builder:builder
	  clack.middleware.session:<clack-middleware-session>
	  clack.middleware.csrf:<clack-middleware-csrf>
	  (clack.middleware.clsql:<clack-middleware-clsql>
	   :connection-spec '("test.sqlite3")
	   :database-type :sqlite3)
	  *app*))))

(defun stop ()
  (clack:stop))
