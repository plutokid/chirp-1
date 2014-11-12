(defpackage #:chirp.config
  (:use :cl
	:envy)
  (:export #:configure))

(in-package #:chirp.config)

(setf (config-env-var) "APP_ENV")

(defun db-spec (env &optional (host "localhost"))
  (list host (format nil "chirp_~a" (string-downcase env)) "" ""))

(defun production-db-spec ()
  "Best kind of ugly as sin"
  (destructuring-bind (user password host port db)
      (multiple-value-bind (string values)
	  (ppcre:scan-to-strings
	   "postgres://([a-z]+):([a-zA-Z0-9]+)@([a-zA-Z0-9\-\.]+):([0-9]+)/([a-zA-Z0-9]+)"
	   (asdf::getenv "DATABASE_URL"))
	(coerce values 'list))
    (print (list host db user password port))))

(defun read-secrets ()
  (let ((base-pathname (asdf:component-pathname (asdf:find-system :chirp))))
    (handler-case
	(read-from-string
	 (alexandria:read-file-into-string
	  (merge-pathnames ".crypto.sexp"
			   base-pathname)))
      (error () (list :random-salt (asdf::getenv "RANDOM_SALT"))))))

(defun configure ()


  (defconfig :common
      (let ((base-pathname (asdf:component-pathname (asdf:find-system :chirp))))
	`(:application-root ,base-pathname
			    :database-type :postgresql)))

  (defconfig |development|
      `(:debug t
	       :connection-spec ,(db-spec :dev)
	       ,@(read-secrets)))

  (defconfig |test|
      `(:debug t
	       :connection-spec ,(db-spec :test)
	       ,@(read-secrets)))

  (defconfig |production|
      `(:debug nil
	       :connection-spec ,(production-db-spec)
	       :random-salt ,(asdf::getenv "RANDOM_SALT"))))

;; (defconfig :default
;;     `(,@|development|))
