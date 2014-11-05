;;;; package.lisp

(defpackage #:chirp
  (:use #:cl
	#:who
	#:clack
	#:split-sequence
	#:alexandria
	#:clack.app.route)
  (:import-from #:clsql
		#:select
		#:file-enable-sql-reader-syntax
		#:def-view-class
		#:update-records-from-instance)
  (:export #:start
	   #:stop))

(in-package #:chirp)

(use-package :chirp cl-emb:*function-package*)
